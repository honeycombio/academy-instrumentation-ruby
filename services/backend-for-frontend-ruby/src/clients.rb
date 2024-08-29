require 'net/http'
require 'json'

module PhrasePickerClient
  PHRASE_URI = URI('http://phrase-picker:10118/phrase')
  def self.pick_phrase
    phrase_response = Net::HTTP.get_response(PHRASE_URI)
    JSON.parse(phrase_response.body)['phrase']
  end
end

module ImagePickerClient
  IMAGE_URI = URI('http://image-picker:10116/imageUrl')
  def self.pick_image
    image_response = Net::HTTP.get_response(IMAGE_URI)
    JSON.parse(image_response.body)['imageUrl']
  end
end

module MeminatorClient
  MEMINATOR_URI = URI('http://meminator:10117/applyPhraseToPicture')
  def self.create_picture(phrase, image_url)
    Net::HTTP.post(MEMINATOR_URI, { phrase: phrase, imageUrl: image_url }.to_json, 'Content-Type' => 'application/json')
  end
end
