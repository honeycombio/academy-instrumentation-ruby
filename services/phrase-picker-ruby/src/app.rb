require 'sinatra/base'
require_relative 'phrase_db'
require_relative 'observability'

class PhrasePickerApp < Sinatra::Application
  set :bind, '0.0.0.0'
  set :port, '10118'
  set :show_exceptions, false

  get '/phrase' do
    chosen_phrase = PhraseDB.random_phrase
    OpenTelemetry::Trace.current_span.set_attribute("app.phrase", chosen_phrase)

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
