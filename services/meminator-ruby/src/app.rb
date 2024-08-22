require 'sinatra/base'
require 'open-uri'
require 'tempfile'

class MeminatorApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10117'
  set :show_exceptions, false


  IMAGE_MAX_WIDTH_PX = 1000
  IMAGE_MAX_HEIGHT_PX = 1000

  post '/applyPhraseToPicture' do
    request.body.rewind
    work = JSON.parse(request.body.read)
    logger.info "Received request: #{work}"

    phrase = work.fetch("phrase") { return [400, "Missing 'phrase' key in JSON request body."] }
    image_url = work.fetch("imageUrl") { return [400, "Missing 'imageUrl' key in JSON request body."] }

    begin
      image_url = URI.parse(image_url)
      [URI::HTTP, URI::HTTPS].include?(image_url.class) or raise URI::InvalidURIError
    rescue URI::InvalidURIError
      return [400, "Invalid 'imageUrl' value in JSON request body."]
    end

    file_extension = File.extname(image_url.path)
    downloaded_image = Tempfile.new(["downloaded_image", file_extension])
    downloaded_image.binmode
    downloaded_image.write(URI.open(image_url).read)

    meme_image = Tempfile.new(["meme_image", file_extension])

    memination_command = [
      "convert", downloaded_image.path,
      "-resize", (IMAGE_MAX_WIDTH_PX.to_s + "x" + IMAGE_MAX_HEIGHT_PX.to_s),
      "-gravity", "North",
      "-pointsize", "48",
      "-fill", "white",
      "-undercolor", "#00000080",
      "-font", "Angkor-Regular",
      "-annotate", "0",
      phrase.upcase,
      meme_image.path
    ]

    begin
      result = IO.popen(memination_command)
      logger.info result.readlines
      result.close
      # TODO: capture process return code, stdout, and stderr
    rescue Errno::ENOENT => e
      logger.error "Failed to run command: #{e.message}"
      logger.error e.backtrace
      return [500, "Failed to meminate."]
    end

    if $?.exitstatus != 0
      return [500, "Failed to meminate."]
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
