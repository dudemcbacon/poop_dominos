require 'sinatra'
require 'rmagick'
require 'httparty'

AGENT_URL = "https://agent.electricimp.com/IxdMGFT6Ie3p/image"

WIDTH = 264
HEIGHT = 176

WHITE = 0
BLACK = 1

get '/start' do
  image = start_page
  prepare_image(image)
end

get '/pizza' do
  filepath = File.dirname(__FILE__) + '/static/pizza.png'
  logger.warn filepath
  image = Magick::Image.read(filepath).first
  prepare_image(image)
end

get '/poop' do
  filepath = File.dirname(__FILE__) + '/static/poop.png'
  logger.warn filepath
  logger.warn Dir.entries File.dirname(__FILE__) + '/static'
  image = Magick::Image.read(filepath).first
  prepare_image(image)
end

def test(image)
  image.rotate!(180)
  pixels = image.export_pixels(0, 0, WIDTH, HEIGHT, 'I')
  options = {
    :body => interlace(pixels)
  }
puts options
  HTTParty.post(AGENT_URL, options)
end


def interlace(pixels)
  image = ""
  pixels.each_slice(WIDTH) do |row|
    binned_pixels = row.map{|x| x > 0 ? WHITE : BLACK}
    image << [binned_pixels.join].pack("B*")
  end

  return image
end

def start_page
  canvas = Magick::Image.new(264, 176){self.background_color = 'white'}
  gc = Magick::Draw.new
  gc.font_weight = Magick::BoldWeight

  gc.annotate(canvas, 0, 0, 0, -10, "Choose Wisely") {
    self.gravity = Magick::CenterGravity
    self.font = "Helvetica-Narrow-Bold"
    self.pointsize = 40
  }

  gc.annotate(canvas, 0, 0, 2, 2, "Poop") {
    self.gravity = Magick::SouthWestGravity
    self.pointsize = 26
    self.font = "Helvetica-Bold"
  }

  gc.annotate(canvas, 0, 0, 2, 2, "Dominos") {
    self.gravity = Magick::SouthEastGravity
    self.pointsize = 26
    self.font = "Helvetica-Bold"
  }
  return canvas
end

def prepare_image(image)
  image.rotate!(180)
  pixels = image.export_pixels(0, 0, WIDTH, HEIGHT, 'I')
  pixels = pixels.map{|x| x > 0 ? WHITE : BLACK}
  return format_pixels(pixels)
end

def format_pixels(pixels)
  line = ""
  pixels.each_slice(WIDTH) do |row|
    line << [row.join].pack("B*")
  end
  return line
end
