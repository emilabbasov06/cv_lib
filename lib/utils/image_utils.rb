module Utils

  module ImageUtils

    def self.calculate_otsu_threshold_value(pixel_values)
      total_pixels = pixel_values.length
      histogram = Array.new(256, 0)

      pixel_values.each do |pixel_value|
        histogram[pixel_value.round] += 1
      end

      sum = (0..255).reduce(0) { |acc, i| acc + i * histogram[i] }
      sum_b = 0
      weighted_background = 0
      weighted_foreground = 0
      max_variance = 0
      optimal_threshold = 0

      (0..255).each do |t|
        weighted_background += histogram[t]
        next if weighted_background == 0

        weighted_foreground = total_pixels - weighted_background
        break if weighted_foreground == 0

        sum_b += (t * histogram[t])

        mean_b = sum_b.to_f / weighted_background
        mean_f = (sum.to_f - sum_b) / weighted_foreground

        # Calculate between-class variance
        variance_between = weighted_background.to_f * weighted_foreground.to_f * (mean_b - mean_f)**2

        if variance_between > max_variance
          max_variance = variance_between
          optimal_threshold = t
        end
      end

      return optimal_threshold

    end


    def self.add_brightness(color_value, brightness)
      if color_value + brightness <= 255 && color_value + brightness >= 0
        return color_value + brightness
      end

      return color_value
    end


    def self.read_ppm_file(file_path)
      lines = File.readlines(file_path).map(&:strip)
      raise "Invalid PPM" unless lines[0] == "P3"

      clean = lines.reject { |line| line.start_with?("#") }
      new_file_name = "#{file_path.split(".ppm")[0]}.png"

      width, height = clean[1].split.map(&:to_i)
      max_value = clean[2].to_i
      pixel_values = clean[3..].join(" ").split.map(&:to_i)

      return {
        width: width,
        height: height,
        max_value: max_value,
        pixel_values: pixel_values,
        new_file_name: new_file_name
      }
    end


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

    def self.in_bounds?(x, y, width, height)
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