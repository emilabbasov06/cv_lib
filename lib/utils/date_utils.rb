require "time"
require_relative "formatter_utils"


module Utils
  class DateUtils
    
    def self.get_current_date
      Utils::Formatter.format_date(Time.now())
    end
  end
end