require 'net/http'
require 'json'
require 'faraday'

module PhrasePickerClient
  CONNECTION = Faraday.new(url: 'http://phrase-picker:10118')

  def self.pick_phrase
    phrase_response = CONNECTION.get('/phrase')
    return nil unless phrase_response.success?
    JSON.parse(phrase_response.body)['phrase']
  end
end

module ImagePickerClient
  CONNECTION = Faraday.new(url: 'http://image-picker:10116')

  def self.pick_image
    image_response = CONNECTION.get('/imageUrl')
    return nil unless image_response.success?
    JSON.parse(image_response.body)['imageUrl']
  end
end

module MeminatorClient
  CONNECTION = Faraday.new(url: 'http://meminator:10117', headers: { 'Content-Type' => 'application/json' })

  def self.create_picture(phrase, image_url)
    meme_response = CONNECTION.post('/applyPhraseToPicture', { phrase: phrase, imageUrl: image_url }.to_json)
    return nil unless meme_response.success?
    meme_response
  end
end
