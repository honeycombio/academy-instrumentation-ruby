require 'sinatra/base'
require_relative 'observability'

class ImagePickerApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10116'
  set :show_exceptions, false

  IMAGE_LIST = [
    "Angrybird.JPG",
    "Arco&Tub.png",
    "IMG_9343.jpg",
    "angry-lemon-ufo.JPG",
    "austintiara4.png",
    "baby-geese.jpg",
    "bbq.jpg",
    "beach.JPG",
    "bunny-mask.jpg",
    "busted-light.jpg",
    "cat-glowing-eyes.JPG",
    "cat-on-leash.JPG",
    "cat.jpg",
    "clementine.png",
    "cow-peeking.jpg",
    "different-animals-01.png",
    "dratini.png",
    "everything-is-an-experiment.png",
    "experiment.png",
    "fine-food.jpg",
    "flower.jpg",
    "frenwho.png",
    "genshin-spa.jpg",
    "grass-and-desert-guy.png",
    "honeycomb-dogfood-logo.png",
    "horse-maybe.png",
    "is-this-emeri.png",
    "jean-and-statue.png",
    "jessitron.png",
    "keys-drying.jpg",
    "leftridge.png",
    "lime-on-soap-dispenser.jpg",
    "loki-closeup.jpg",
    "lynia.png",
    "ninguang-at-work.png",
    "paul-r-allen.png",
    "pile-of-cars.png",
    "please.png",
    "roswell-nose.jpg",
    "roswell.JPG",
    "salt-packets-in-jar.jpg",
    "scarred-character.png",
    "square-leaf-with-nuts.jpg",
    "stu.jpeg",
    "sweating-it.png",
    "tanuki.png",
    "tennessee-sunset.JPG",
    "this-is-fine-trash.jpg",
    "three-pillars-2.png",
    "trash-flat.jpg",
    "walrus-painting.jpg",
    "windigo.png",
    "yellow-lines.JPG",
  ]
  BUCKET_NAME = ENV.fetch('BUCKET_NAME', 'random-pictures')
  IMAGE_URL_PREFIX = "https://#{BUCKET_NAME}.s3.amazonaws.com/"

  get '/imageUrl' do
    chosen_image = IMAGE_LIST.sample
    image_url = "#{IMAGE_URL_PREFIX}#{chosen_image}"
    OpenTelemetry::Trace.current_span.set_attribute("app.image", chosen_image)

    content_type :json
    { "imageUrl": image_url }.to_json
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
