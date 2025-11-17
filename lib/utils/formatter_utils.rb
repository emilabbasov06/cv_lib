module Utils
  class Formatter
    
    def self.format_date(date)
      date.strftime("%d/%m/%Y %H:%M:%S")
    end
  end
end