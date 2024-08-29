require 'sinatra/base'
require_relative 'meme_generator'
require_relative 'observability'

class MeminatorApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10117'
  set :show_exceptions, false

  TRACER = OpenTelemetry.tracer_provider.tracer('MeminatorApp', '0.1.0')

  post '/applyPhraseToPicture' do
    phrase, image_url, errors = MemeGenerator.parse_request(request)
    return [400, { errors: errors}.to_json] if !errors.empty?

    meme_image, status = MemeGenerator.generate(phrase, image_url)
    return [500, { errors: ["Failed to meminate."]}.to_json] if !status.success?

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
