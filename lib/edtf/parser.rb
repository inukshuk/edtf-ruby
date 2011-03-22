class EDTF
  
  class << self
    def parse(string)
      case string
      when Interval::PATTERN
        Interval.parse(string)
      when Duration::PATTERN
        Duration.parse(string)
      when Century::PATTERN
        Century.parse(string)
      when /^-?\d{4}$/
        DateTime.strptime(string, '%Y')
      when /^-?\d{4}-\d{1,2}$/
        DateTime.strptime(string, '%Y-%m')
      else
        DateTime.parse(string)
      end
    end

    alias :edtf :parse
  end
  
end