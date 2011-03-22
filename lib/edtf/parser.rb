class EDTF
  
  def self.parse(string)
    parse_interval(string) || parse_date_time(string)
  end
  
  protected
  
  def self.parse_interval(string)
    string =~ /^([T\d:-]+)\/([PTDMYHMS\d:-]+)$/ ? parse($1) .. parse($2) : nil
  end
  
  def self.parse_date_time(string)
    case string
    when /^P/
      Duration.new(string)
    when /^\d{2}$/
      Date.strptime(string + '00', '%Y')
    when /^-?\d{4}$/
      Date.strptime(string, '%Y')
    when /^-?\d{4}-\d{1,2}$/
      Date.strptime(string, '%Y-%m')
    else
      DateTime.parse(string)
    end
  end
  
end