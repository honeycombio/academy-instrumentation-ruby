require 'sinatra/base'
require 'net/http'
require_relative 'observability'

class BackendForFrontendApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10115'
  set :show_exceptions, false

  TRACER = OpenTelemetry.tracer_provider.tracer('BackendForFrontendApp', '0.1.0')

  PHRASE_URI = URI('http://phrase-picker:10118/phrase')
  IMAGE_URI = URI('http://image-picker:10116/imageUrl')
  MEMINATOR_URI = URI('http://meminator:10117/applyPhraseToPicture')

  post '/createPicture' do
    meminated_response = nil

    TRACER.in_span('create_picture') do |span|
      # get a phrase
      phrase_response = Net::HTTP.get_response(PHRASE_URI)
      phrase = JSON.parse(phrase_response.body).fetch('phrase') { return [500, 'Sorry. No phrases were found to meminate.'] }
      span.set_attribute('app.phrase', phrase)
      # get an image
      image_response = Net::HTTP.get_response(IMAGE_URI)
      image_url = JSON.parse(image_response.body).fetch('imageUrl') { return [500, 'Sorry. No images were found to meminate.'] }
      span.set_attribute('app.imageUrl', image_url)
      # meminate phrase onto image
      meminated_response = Net::HTTP.post(MEMINATOR_URI, { phrase: phrase, imageUrl: image_url }.to_json, 'Content-Type' => 'application/json')
    end

    if meminated_response.nil?
      return [500, 'Sorry. Could not create a picture for you.']
    end

    # return meminated image
    content_type meminated_response['Content-Type']
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
