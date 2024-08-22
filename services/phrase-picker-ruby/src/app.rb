require 'sinatra/base'

class PhrasePickerApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10118'
  set :show_exceptions, false

  PHRASE_LIST = [
    "you're muted",
    "not dead yet",
    "Let them.",
    "Boiling Loves Company!",
    "Must we?",
    "SRE not-sorry",
    "Honeycomb at home",
    "There is no cloud",
    "This is fine",
    "It's a trap!",
    "Not Today",
    "You had one job",
    "bruh",
    "have you tried restarting?",
    "try again after coffee",
    "deploy != release",
    "oh, just the crimes",
    "not a bug, it's a feature",
    "test in prod",
    "who broke the build?",
    "it could be worse",
  ]

  get '/phrase' do
    chosen_phrase = PHRASE_LIST.sample
    content_type :json
    { "phrase": chosen_phrase }.to_json
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
