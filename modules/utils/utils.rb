module Utils

  module ImageUtils

    def self.generate_ppm_header(width, height, max_value)
      "P3\n#{width} #{height}\n#{max_value}\n"
    end


    def self.get_raw_pixels(channels, data)
      if channels == "I"
        return data.flatten.flat_map do |value|
          value_16_bit = value * 257
          [value_16_bit, value_16_bit, value_16_bit]
        end
      else
        return data.flatten.map { |color_intensity| color_intensity * 257 }
      end
    end

    def self.default_pixel_value(channels)
      case channels
      when "RGB"
        [0, 0, 0]
      when "I"
        0
      else
        raise ArgumentError, "Unsupported channel type: #{@channels}. Use 'RGB' or 'I'."
      end
    end

    def self.check_boundaries(x, y, width, height)
      if x < 0 || x >= width || y < 0 || y >= height
        return false
      end

      return true
    end


    def self.check_channels(channels, value)
      case channels.upcase
      when "RGB"
        unless value.is_a?(Array) && value.length == 3
          return false
        end
      end
    end

  end

end