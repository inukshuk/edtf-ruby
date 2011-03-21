class EDTF
  def self.parse(string)
    case string
    when /^-?\d{4}$/
      DateTime.strptime(string, '%Y')
    when /^\d{4}-\d{1,2}$/
      DateTime.strptime(string, '%Y-%m')
    else
      DateTime.parse(string)
    end
  end
end