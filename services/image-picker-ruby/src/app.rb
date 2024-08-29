require 'sinatra/base'
require_relative 'image_db'
require_relative 'observability'

class ImagePickerApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10116'
  set :show_exceptions, false

  BUCKET_NAME = ENV.fetch('BUCKET_NAME', 'random-pictures')
  IMAGE_URL_PREFIX = "https://#{BUCKET_NAME}.s3.amazonaws.com/"

  get '/imageUrl' do
    chosen_image = ImageDB.random_image_name
    OpenTelemetry::Trace.current_span.set_attribute("app.image", chosen_image)

    content_type :json
    { "imageUrl": "#{IMAGE_URL_PREFIX}#{chosen_image}" }.to_json
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
