require 'open-uri'
require 'open3'
require 'tempfile'
require 'uri'

module MemeGenerator
  IMAGE_MAX_WIDTH_PX = 1000
  IMAGE_MAX_HEIGHT_PX = 1000
  IMAGE_RESIZE_DIMENSIONS = "#{IMAGE_MAX_WIDTH_PX}x#{IMAGE_MAX_HEIGHT_PX}"

  def self.generate(phrase, image_url)
    # what type of image are we working with?
    file_extension = File.extname(image_url.path)

    # retrieve the original image
    downloaded_image = Tempfile.new(["downloaded_image", file_extension])
    downloaded_image.binmode
    downloaded_image.write(URI.open(image_url).read)

    # generate meme
    meme_image = Tempfile.new(["meme_image", file_extension])

    memination_command = [
      "convert", downloaded_image.path,
      "-resize", IMAGE_RESIZE_DIMENSIONS,
      "-gravity", "'North'",
      "-pointsize", "48",
      "-fill", "'white'",
      "-undercolor", "'#00000080'",
      "-font", "'Angkor-Regular'",
      "-annotate", "0",
      ('"' + phrase.upcase + '"'),
      meme_image.path
    ].join(" ")

    cmd_out, cmd_err, status = Open3.capture3(memination_command)

    [meme_image, status]
  end

  def self.parse_request(request)
    errors = []

    request.body.rewind
    work = JSON.parse(request.body.read)

    phrase = work["phrase"]
    phrase || errors.push("Missing 'phrase' key in JSON request body.")
    image_url = work["imageUrl"]
    image_url || errors.push("Missing 'imageUrl' key in JSON request body.")

    if image_url
      begin
        image_url = URI.parse(image_url)
        [URI::HTTP, URI::HTTPS].include?(image_url.class) or raise URI::Error.new("URL scheme must be HTTP or HTTPS.")
      rescue URI::Error => e
        errors.push("Invalid 'imageUrl' value in JSON request body. #{e.message}")
      end
    end

    [phrase, image_url, errors]
  rescue JSON::ParserError => e
    [nil, nil, ["Invalid JSON request body. #{e.message}"]]
  end
end
