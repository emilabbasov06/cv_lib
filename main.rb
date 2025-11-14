require_relative "modules/pure_cv/image"

image = PureCV::Image.new(3, 4, "CMYK")
p image.channels

p image.data