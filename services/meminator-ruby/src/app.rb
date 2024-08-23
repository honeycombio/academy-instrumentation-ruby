require 'sinatra/base'
require 'open-uri'
require 'tempfile'
require 'open3'
require_relative 'observability'

class MeminatorApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10117'
  set :show_exceptions, false

  TRACER = OpenTelemetry.tracer_provider.tracer('MeminatorApp', '0.1.0')

  IMAGE_MAX_WIDTH_PX = 1000
  IMAGE_MAX_HEIGHT_PX = 1000
  IMAGE_RESIZE_DIMENSIONS = "#{IMAGE_MAX_WIDTH_PX}x#{IMAGE_MAX_HEIGHT_PX}"

  post '/applyPhraseToPicture' do
    request.body.rewind
    work = JSON.parse(request.body.read)
    logger.info "Received request: #{work}"

    phrase = work.fetch("phrase") { return [400, "Missing 'phrase' key in JSON request body."] }
    OpenTelemetry::Trace.current_span.set_attribute("app.phrase", phrase)

    image_url = work.fetch("imageUrl") { return [400, "Missing 'imageUrl' key in JSON request body."] }
    OpenTelemetry::Trace.current_span.set_attribute("app.imageUrl", image_url)

    begin
      image_url = URI.parse(image_url)
      [URI::HTTP, URI::HTTPS].include?(image_url.class) or raise URI::Error.new("URL scheme must be HTTP or HTTPS.")
    rescue URI::Error => e
      OpenTelemetry::Trace.current_span.record_exception(e)
      return [400, "Invalid 'imageUrl' value in JSON request body. #{e.message}"]
    end

    file_extension = File.extname(image_url.path)
    downloaded_image = Tempfile.new(["downloaded_image", file_extension])
    downloaded_image.binmode

    TRACER.in_span('retrieve_image') do |span|
      downloaded_image.write(URI.open(image_url).read)
    end

    meme_image = Tempfile.new(["meme_image", file_extension])

    TRACER.in_span('convert') do |conversion_span|
      memination_command = [
        "convert", downloaded_image.path,
        "-resize", IMAGE_RESIZE_DIMENSIONS,
        "-gravity", "'North'",
        "-pointsize", "48",
        "-fill", "'white'",
        "-undercolor", "'#00000080'",
        "-font", "'Angkor-Regular'",
        "-annotate", "0",
        ('"' + phrase.upcase + '"'),
        meme_image.path
      ].join(" ")

      conversion_span.set_attribute("app.subprocess.command", memination_command)

      cmd_out, cmd_err, status = Open3.capture3(memination_command)
      conversion_span.add_attributes({
        "app.subprocess.returncode" => status.exitstatus,
        "app.subprocess.stderr" => cmd_err,
        "app.subprocess.stdout" => cmd_out,
      })

      if !status.success?
        return [500, "Failed to meminate."]
      end
    end

    send_file meme_image.path
  end

  on_start do
    puts "===== Booting up ====="
  end

  on_stop do
    puts "===== Shutting down ====="
  end

  # start the server if this file is run directly
  run! if app_file == $PROGRAM_NAME
end
