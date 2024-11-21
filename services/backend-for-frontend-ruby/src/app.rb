require 'sinatra/base'
require_relative 'clients'

class BackendForFrontendApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10115'
  set :show_exceptions, false

  post '/createPicture' do
    meminated_response = nil

    # get a phrase
    phrase = PhrasePickerClient.pick_phrase
    return [500, 'Sorry. No phrases were found to meminate.'] unless phrase

    # get an image
    image_url = ImagePickerClient.pick_image
    return [500, 'Sorry. No images were found to meminate.'] unless image_url

    # meminate phrase onto image
    meminated_response = MeminatorClient.create_picture(phrase, image_url)
    return [500, 'Sorry. Could not create a picture for you.'] unless meminated_response

    # return meminated image
    content_type meminated_response.headers['Content-Type']
    [200, meminated_response.body]
  end

  get '/health' do
    [200, 'UP']
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
