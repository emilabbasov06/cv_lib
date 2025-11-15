require "rmagick"
require_relative "../utils/utils"


module PureCV

  class Image
    attr_reader :width, :height, :channels, :data, :default_pixel


    class << self
      
      def from_ppm_to_image(file_path, file_name)
        lines = File.readlines(file_path).map(&:strip)

        # Checks if first line in PPM file equals to "P3" which it must be
        raise "Invalid PPM" unless lines[0] == "P3"


        # Extracting width, height and maximum color intensity value (max. 255)
        width, height = lines[1].split.map(&:to_i)
        max_value = lines[2].to_i
        raise "Max value must be 255" unless max_value == 255

        # Creating new image from self
        image = self.new(width, height, "RGB")

        # Extracting pixel values and inserting them to create .png or .jpg image from PPM file
        pixel_values = lines[3..].join(" ").split.map(&:to_i)
        pixel_values.each_slice(3).with_index do |(r, g, b), idx|
          y = idx / width
          x = idx % width
          image.set_pixel_rgb(x, y, [r, g, b])
        end

        image.save_as(file_name)
      end

    end


    def initialize(width, height, channels)
      @width = width
      @height = height
      @channels = channels.upcase

      # This creates a palatte type thing which is contained with pixels (all default values are 0)
      # we will change the data by Image#set_pixel and Image#get_pixel afterwards
      # @data = Array.new(@height) { Array.new(@width, 0) }
      @default_pixel = Utils::ImageUtils.default_pixel_value(@channels)
      @data = Array.new(@height) do
        Array.new(@width) {@default_pixel.dup rescue @default_pixel}
      end
    end


    def get_pixel(x, y)
      if !Utils::ImageUtils.check_boundaries(x, y, @width, @height)
        raise ArgumentError, "Coordinates (#{x}, #{y}) are outside of image boundaries!"
      end

      @data[y][x]
    end


    def set_pixel_rgb(x, y, color_rgb)
      if !Utils::ImageUtils.check_boundaries(x, y, @width, @height)
        raise ArgumentError, "Coordinates (#{x}, #{y}) are outside of image boundaries!"
      end

      unless color_rgb.is_a?(Array) && color_rgb.length == 3
        raise ArgumentError, "Color must be an array of 3 values"
      end

      @data[y][x] = color_rgb
    end

    
    def set_pixel_i(x, y, color_i)
      if !Utils::ImageUtils.check_boundaries(x, y, @width, @height)
        raise ArgumentError, "Coordinates (#{x}, #{y}) are outside of image boundaries!"
      end

      unless color_i.is_a?(Integer) && color_i >= 0 && color_i <= 255
        raise ArgumentError, "Color value must be between 0 and 255 (both inclusive)"
      end

      @data[y][x] = color_i
    end


    def save_as(file_name)
      begin
        # The reason I multiplied the pixel color_intensity to 257 is that rmagick uses 16-bit depth
        # but we import 8-bit depth values

        raw_pixels = Utils::ImageUtils.get_raw_pixels(@channels, @data)

        image = Magick::Image.new(@width, @height)
        image.import_pixels(
          0,
          0,
          @width,
          @height,
          @channels == "I" ? "RGB" : @channels,
          raw_pixels
        )

        image.write(file_name)
        
        puts "[INFO]: Image was saved succesfully [Channel type: #{@channels}]"
      rescue LoadError => e
        puts "[ERROR]: There is no gem installed \"rmagick\". Please run \"gem install rmagick\""
      rescue => e
        puts "[ERROR]: An error occured during file creation: #{e.message}"
      end
    end
  end

end