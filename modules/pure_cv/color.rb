require_relative "./image"
require_relative "../utils/image_utils"


module PureCV
  
  module Color

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