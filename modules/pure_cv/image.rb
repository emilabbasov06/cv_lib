require "rmagick"


module PureCV

  class Image
    attr_reader :width, :height, :channels, :data


    def initialize(width, height, channels)
      @width = width
      @height = height
      @channels = channels

      # This creates a palatte type thing which is contained with pixels (all default values are 0)
      # we will change the data by Image#set_pixel and Image#get_pixel afterwards
      @data = Array.new(@height) { Array.new(@width, 0) }
    end


    def get_pixel(x, y)
      if x < 0 || x >= @width || y < 0 || y >= @height
        raise ArgumentError, "Coordinates (#{x}, #{y}) are outside of image boundaries!"
      end

      @data[y][x]
    end


    def set_pixel(x, y, color_rgb)
      if x < 0 || x >= @width || y < 0 || y >= @height
        raise ArgumentError, "Coordinates (#{x}, #{y}) are outside of image boundaries!"
      end

      # unless color_rgb.is_a?(Integer) && color_value >= 0 && color_value <= 255
      #   raise ArgumentError, "Please enter values between 0 and 255 (They both are included)"
      # end

      unless color_rgb.is_a?(Array) && color_rgb.length == 3
        raise ArgumentError, "Color must be an array of 3 values"
      end

      @data[y][x] = color_rgb
    end


    def save_as(file_name)
      begin
        # The reason I multiplied the pixel color_intensity to 257 is that rmagick uses 16-bit depth
        # but we import 8-bit depth values
        raw_pixels = @data.flatten.map { |color_intensity| color_intensity * 257 }

        image = Magick::Image.new(@width, @height)

        image.import_pixels(0, 0, @width, @height, "RGB", raw_pixels)
        image.write(file_name)
        
        puts "[INFO]: Image was saved succesfully"
      rescue LoadError => e
        puts "[ERROR]: There is no gem installed \"rmagick\". Please run \"gem install rmagick\""
      rescue => e
        puts "[ERROR]: An error occured during file creation: #{e.message}"
      end
    end
  end

end