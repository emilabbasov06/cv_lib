require "chunky_png"
require_relative "./image"
require_relative "../utils/image_utils"


module PureCV
  
  module Color

    def self.adjust_saturation(file_path, value, type: :increment)
      norm = 255.0
      ppm_path = "saturation_#{File.basename(file_path, ".*")}.ppm"
      PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      width = image_data[:width].to_i
      height = image_data[:height].to_i
      new_image = PureCV::Image.new(width, height, "RGB")

      image_data[:pixel_values].each_slice(3).with_index do | (r, g, b), idx |
        
        y = idx / width
        x = idx % width

        r_float = r / norm
        g_float = g / norm
        b_float = b / norm

        gray = 0.2989 * r_float + 0.5870 * g_float + 0.1140 * b_float


        case type
        when :increment
          value = 0.5

          r_new_float = -gray * value + r_float * (1 + value)
          g_new_float = -gray * value + g_float * (1 + value)
          b_new_float = -gray * value + b_float * (1 + value)
        when :decrement
          value = -0.5

          r_new_float = -gray * value + r_float * (1 + value)
          g_new_float = -gray * value + g_float * (1 + value)
          b_new_float = -gray * value + b_float * (1 + value)
        end

        r_new_float = [[0.0, r_new_float].max, 1.0].min
        g_new_float = [[0.0, g_new_float].max, 1.0].min
        b_new_float = [[0.0, b_new_float].max, 1.0].min

        r_new = (r_new_float * norm).round
        g_new = (g_new_float * norm).round
        b_new = (b_new_float * norm).round


        new_image.set_pixel_rgb(x, y, [r_new, g_new, b_new])
      end

      new_image.save_as("saturation_#{File.basename(file_path, ".*")}.png")
    end

    def self.otsu_threshold(file_path, grayscale_type: :weighted)
      ppm_path = case grayscale_type
      when :average
        self.png_average_grayscale(file_path)
      when :weighted
        self.png_weighted_grayscale(file_path)
      else
        puts "[ERROR]: Invalid grayscale type provided"
        return
      end

      image_data = Utils::ImageUtils.read_ppm_file(ppm_path)
      optimal_threshold = Utils::ImageUtils.calculate_otsu_threshold_value(image_data[:pixel_values])

      width = image_data[:width].to_i
      height = image_data[:height].to_i

      output_filename = "thresholded_otsu_#{File.basename(file_path, '.*')}.png"
      thresholded_image = PureCV::Image.new(width, height, "I")

      grayscale_pixels = image_data[:pixel_values].each_slice(3).map do |r,g,b|
        ((0.299*r + 0.587*g + 0.114*b).round).clamp(0,255)
      end
      grayscale_pixels.each_with_index do | intensity, idx |
        y = idx / width
        x = idx % width

        binary_value = intensity > optimal_threshold ? 255 : 0
        thresholded_image.set_pixel_i(x, y, binary_value)
      end

      thresholded_image.save_as(output_filename)
      File.delete(ppm_path)
    end


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
      File.delete(ppm_path)
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
      File.delete(ppm_path)
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

      return ppm_path
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

      return ppm_path
    end


    private_class_method :png_average_grayscale, :png_weighted_grayscale
  end

end