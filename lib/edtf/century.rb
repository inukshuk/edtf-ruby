class EDTF
  
  class Century
    include Comparable
    
    PATTERN = /^\d{2}$/
    
    attr_accessor :year
    
    class << self
      def parse(argument); new(argument.to_s); end
      alias :iso8601 :parse
    end

    def initialize(argument = 0)
      argument.is_a?(String) ? iso8601(argument) : @year = argument
    end
    
    def century
      @year.to_i / 100 + 1
    end

    alias :to_i :century
    
    # If the year is currently set, sets the year to the first year that is
    # definitely part of the century. For example, if the century is set to
    # 19, the year will be set to 1801. If the year is already set, it adapts
    # the year to the new century.
    def century=(new_century)
      @year = (new_century.to_i - century) * 100 + (@year || 1)  
    end
    
    def iso8601(argument = nil)
      argument && parse(argument) || ('%02d' % [self.century - 1])
    end

    def to_s; iso8601(); end
    
    def parse(string)
      self.century = string.to_i + 1
      self
    end
    
    def +(other)
      self.century = century + other.to_i
      self
    end
    
    def -(other); self + (other.to_i * -1); end
    
    def <=>(other)
      year <=> other.year
    end
  end
  
end