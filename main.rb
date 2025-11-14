require_relative "modules/pure_cv/image"

image_rgb = PureCV::Image.new(300, 300, "RGB")

(0...image_rgb.height).each do |y|
  (0...image_rgb.width).each do |x|
    image_rgb.set_pixel_rgb(x, y, [0, 255, 0])
  end
end
image_rgb.save_as("test_rgb.png")



image_i = PureCV::Image.new(300, 300, "I")

(0...image_i.height).each do |y|
  (0...image_i.width).each do |x|
    image_i.set_pixel_i(x, y, 128)
  end
end
image_i.save_as("test_i.png")