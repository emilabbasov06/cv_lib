require_relative "./image"


module PureCV
  
  module Color
    
    def self.png_average_grayscale(file_path)
      ppm_path = "grayscale_#{file_path.split(".png")[0]}.ppm"
      ppm_format = PureCV::Image.from_png_to_ppm(file_path, ppm_path)

      lines = File.readlines(ppm_path).map(&:strip)
      width, height = lines[1].split.map(&:to_i)
      image = PureCV::Image.new(width.to_i, height.to_i, "I")

      pixel_values = lines[3..].join(" ").split.map(&:to_i)
      pixel_values.each_slice(3).with_index do |(r, g, b), idx|
        y = idx / width
        x = idx % width
        color_value = (r + g + b) / 3
        image.set_pixel_i(x, y, color_value)
      end

      image.save_as("grayscale_#{file_path}.png")

    end

  end

end