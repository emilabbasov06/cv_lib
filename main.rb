require_relative "modules/pure_cv/image"

image = PureCV::Image.new(300, 400, "CMYK")

(0...image.height).each do |y|
  (0...image.width).each do |x|
    image.set_pixel(x, y, [0, 0, 255]) # 200 is a code for blue color
  end
end

p image.data

image.save_as("another_test.png")