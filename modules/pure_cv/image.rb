module PureCV

  class Image
    attr_reader :width, :height, :channels, :data

    def initialize(width, height, channels)
      @width = width
      @height = height
      @channels = channels

      # This creates a palatte type thing which is contained with pixels (all default values are 0)
      # we will change the data by Image#set_index and Image#get_index afterwards
      @data = Array.new(@height) { Array.new(@width, 0) }
    end
  end

end