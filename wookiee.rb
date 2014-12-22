require 'sinatra/base'
require 'RMagick'

class Wookiee < Sinatra::Base
  
  set :public_folder, File.dirname(__FILE__) + '/public'
  Pic = Struct.new(:image, :width, :height)

  def self.preload_images
    images = []
    Dir.glob('./public/images/*.{jpg,png}').each do |img|
      pic = Magick::Image.read("#{img}").first
      p = Pic.new(pic, pic.columns, pic.rows)
      images.push p
    end
    return images
  end

  def self.preload_gifs
    gifs = []
    Dir.glob('./public/images/gifs/*.gif').each do |gif|
      gifs.push gif
    end
    return gifs
  end

  def random_wookiee
    PICS[rand(PICS.count)].image
  end

  def random_wookiee_gif
    GIFS[rand(GIFS.count)].image
  end

  def image_with_size(width, height)
    if width > 3000 || height > 3000
      imgResize = "Wookiees are big, but they're not that big!"
    else
      img = random_wookiee
      imgResize = img.resize_to_fill(width, height)
    end
    return imgResize
  end

  PICS = preload_images
  GIFS = preload_gifs
  
  #### Error Handling
  not_found do
    haml :page_not_found
  end
  
  #### Routes

  get "/" do
    haml :index
  end

  get "/random" do
    content_type 'image/jpeg'
    random_wookiee.to_blob
  end
  
  get "/g/random" do
    content_type 'image/jpeg'
    image = random_wookiee.quantize(256, Magick::GRAYColorspace)
    image.to_blob
  end
  
  get "/specific/:id" do
    id = params[:id].to_i
    id -= 1
    if id >= PICS.size
      "Sorry, We only have #{PICS.size} Wookiee pictures"
    else
      img = PICS[id].image
      
      content_type 'image/jpeg'
      img.to_blob
    end
  end
  
  get "/:width/:height" do
    width = params[:width].to_i
    height = params[:height].to_i
    
    image = image_with_size(width, height)
    if image.class == String
      image
    else
      content_type 'image/jpeg'
      image.to_blob
    end
  end
  
  get "/g/:width/:height" do
    width = params[:width].to_i
    height = params[:height].to_i
    
    image = image_with_size(width, height)
    if image.class == String
      image
    else
      content_type 'image/jpeg'
      image = image.quantize(256, Magick::GRAYColorspace)
      image.to_blob
    end
  end

  # Gifs not working yet

  get "/gif" do
    content_type 'image/gif'
    random_wookiee_gif.to_blob
  end

end
