require "chunky_png"
require_relative "./image"
require_relative "../utils/image_utils"


module PureCV
  
  module Color

    

    def self.increase_brightness_of_png(file_path, brightness_value)
      ppm_path = "brightness_#{file_path.split(".png")[0]}.ppm"
      PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      image = PureCV::Image.new(image_data[:width], image_data[:height], "RGB")

      image_data[:pixel_values].each_slice(3).with_index do | (r, g, b), idx |
        y = idx / image_data[:width]
        x = idx % image_data[:width]
        new_r = Utils::ImageUtils.add_brightness(r, brightness_value)
        new_g = Utils::ImageUtils.add_brightness(g, brightness_value)
        new_b = Utils::ImageUtils.add_brightness(b, brightness_value)

        image.set_pixel_rgb(x, y, [new_r, new_g, new_b])
      end

      image.save_as("brightness_#{file_path.split(".png")[0]}.png")
    end

    def self.invert_colors_png(file_path)
      ppm_path = "inverted_#{file_path.split(".png")[0]}.ppm"
      PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      image = PureCV::Image.new(image_data[:width].to_i, image_data[:height].to_i, "RGB")

      image_data[:pixel_values].each_slice(3).with_index do | (r, g, b), idx |
        y = idx / image_data[:width]
        x = idx % image_data[:width]
        inverted_r = 255 - r
        inverted_g = 255 - g
        inverted_b = 255 - b

        image.set_pixel_rgb(x, y, [inverted_r, inverted_g, inverted_b])
      end

      image.save_as("inverted_#{file_path.split(".png")[0]}.png")
    end

    def self.rotate_image(file_path)
      image = ChunkyPNG::Image.from_file(file_path)
      rotated_image = image.rotate_180
      rotated_image.save("#{file_path.split(".")[0]}_rotated.png")
    end

    def self.to_grayscale(file_path, grayscale_type: :average)
      case grayscale_type
      when :average
        self.png_average_grayscale(file_path)
      when :weighted
        self.png_weighted_grayscale(file_path)
      else
        puts "[ERROR]: There is no type named like #{grayscale_type}"
      end
    end
    
    def self.png_average_grayscale(file_path)
      # This is a new PPM file name
      ppm_path = "grayscale_average_#{file_path.split(".png")[0]}.ppm"
      PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      image = PureCV::Image.new(image_data[:width].to_i, image_data[:height].to_i, "I")

      image_data[:pixel_values].each_slice(3).with_index do | (r, g, b), idx |
        y = idx / image_data[:width]
        x = idx % image_data[:width]
        color_value = (r + g + b) / 3
        image.set_pixel_i(x, y, color_value)
      end

      image.save_as(image_data[:new_file_name])
    end

    def self.png_weighted_grayscale(file_path)
      ppm_path = "grayscale_weighted_#{file_path.split(".png")[0]}.ppm"
      PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      image = PureCV::Image.new(image_data[:width].to_i, image_data[:height].to_i, "I")

      image_data[:pixel_values].each_slice(3).with_index do | (r, g, b), idx |
        y = idx / image_data[:width]
        x = idx % image_data[:width]
        color_value = ((0.299 * r) + (0.587 * g) + (0.114 * b)) / 3
        color_value = [[color_value.round, 255].min, 0].max
        image.set_pixel_i(x, y, color_value)
      end

      image.save_as(image_data[:new_file_name])
    end


    private_class_method :png_average_grayscale, :png_weighted_grayscale
  end

end