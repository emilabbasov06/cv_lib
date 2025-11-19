require_relative "lib/pure_cv/image"
require_relative "lib/pure_cv/color"


# image_rgb = PureCV::Image.new(300, 300, "RGB")

# (0...image_rgb.height).each do |y|
#   (0...image_rgb.width).each do |x|
#     image_rgb.set_pixel_rgb(x, y, [0, 255, 0])
#   end
# end
# image_rgb.save_as("test_rgb.png")

# image_rgb_clone = image_rgb.clone

# p "Image: #{image_rgb.object_id}"
# p "Cloned image: #{image_rgb_clone.object_id}"

# image_rgb_clone.save_as("clone.png")

p PureCV::Color.histogram("hiking.png")