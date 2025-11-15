require_relative "modules/pure_cv/image"


PureCV::Image.from_png_to_ppm("clone.png", "test.ppm")
PureCV::Image.from_ppm_to_png("clone.ppm", "test.pn")