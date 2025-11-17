require "rmagick"
require "chunky_png"
require_relative "../utils/date_utils"
require_relative "../utils/image_utils"
require_relative "../errors/errors"


module PureCV

  class Image
    attr_reader :width, :height, :channels, :created_at
    attr_accessor :data


    def initialize(width, height, channels)
      @width = width
      @height = height
      @channels = channels.upcase
      @created_at = Utils::DateUtils.get_current_date

      # This creates a palatte type thing which is contained with pixels (all default values are 0)
      # we will change the data by Image#set_pixel and Image#get_pixel afterwards
      # @data = Array.new(@height) { Array.new(@width, 0) }
      @default_pixel = Utils::ImageUtils.default_pixel_value(@channels)
      @data = Array.new(@height) do
        Array.new(@width) {@default_pixel.dup rescue @default_pixel}
      end
    end

###########################################################
# CLASS METHODS START HERE
###########################################################
    
    def self.from_ppm_to_png(file_path, file_name)
      begin
        raise PureCVErrors::FileExtensionError unless file_name.include?(".png")

        image_data = Utils::ImageUtils.read_ppm_file(file_path)
        raise "Max value must be 255" unless image_data[:max_value] == 255

        # Creating new image from self
        image = self.new(image_data[:width], image_data[:height], "RGB")

        # Extracting pixel values and inserting them to create .png or .jpg image from PPM file
        image_data[:pixel_values].each_slice(3).with_index do |(r, g, b), idx|
          y = idx / image_data[:width]
          x = idx % image_data[:height]
          image.set_pixel_rgb(x, y, [r, g, b])
        end

        image.save_as(file_name)
        puts "[SUCCESS]: Created new PNG named \"#{file_name}\" image from \"#{file_path}\""
      rescue PureCVErrors::FileExtensionError => e
        puts "[ERROR #{e.class}]: File extension must be .png"
      end
      
    end


    def self.from_png_to_ppm(file_path, file_name)
      begin
        raise PureCVErrors::FileExtensionError unless file_name.include?(".ppm")

        image = ChunkyPNG::Image.from_file(file_path)
        
        File.open(file_name, "w") do |ppm_file|
          ppm_file.write(
            Utils::ImageUtils.generate_ppm_header(
              image.width,
              image.height,
              "255"
            )
          )

          (0...image.height).each do |y|

            (0...image.width).each do |x|

              pixel_color = image[x, y]
              value = [
                ChunkyPNG::Color.r(pixel_color),
                ChunkyPNG::Color.g(pixel_color),
                ChunkyPNG::Color.b(pixel_color)
              ]

              ppm_file.write("#{value.join(" ")} ")
            end

          end

        end

        puts "[SUCCESS]: Created new PPM file named \"#{file_name}\" from \"#{file_path}\""
      rescue PureCVErrors::FileExtensionError => e
        puts "[ERROR #{e.class}]: File extension must be .ppm"
      end
    end


###########################################################
# INSTANCE METHODS START HERE
###########################################################


    def get_pixel(x, y)
      check_bounds!(x, y)
      @data[y][x]
    end


    def set_pixel_rgb(x, y, color_rgb)
      check_bounds!(x, y)
      raise ArgumentError, "Color must be an array of 3 values" unless color_rgb.is_a?(Array) && color_rgb.length == 3
      @data[y][x] = color_rgb
    end

    
    def set_pixel_i(x, y, color_i)
      check_bounds!(x, y)
      raise ArgumentError, "Color value must be between 0 and 255 (both inclusive)" unless color_i.is_a?(Integer) && color_i >= 0 && color_i <= 255
      @data[y][x] = color_i
    end

    
    # This method will deep clone the given image
    def clone
      d_clone = PureCV::Image.new(@width, @height, @channels)
      d_clone.data = @data.map do |row|
        row.map { |pixel| pixel.is_a?(Array) ? pixel.dup : pixel }
      end
      d_clone
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

###########################################################
# PRIVATE METHODS START HERE
###########################################################

    private def check_bounds!(x, y)
      raise PureCVErrors::CoordinateBoundaries unless Utils::ImageUtils.in_bounds?(x, y, @width, @height)
    end

  end

end