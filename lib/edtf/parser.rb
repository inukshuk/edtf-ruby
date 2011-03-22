class EDTF
  
  def self.parse(string)
    case string.to_s
    when Interval::PATTERN
      Interval.parse(string)
    when Duration::PATTERN
      Duration.parse(string)
    when Century::PATTERN
      Century.parse(string)
    else
      DateTime.edtf(string)
    end
  end
  
end