class EDTF

  class Duration < Struct.new(:year, :month, :week, :day, :hour, :minute, :second)
    include Comparable

    ISO8601 = /^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$/
    
    def self.iso8601(string); new(string); end
    
    def initialize(*arguments)
      arguments = parse(arguments[0]) if arguments.length == 1 && arguments[0].to_s.start_with?('P')
      super
    end

    def iso8601(argument = nil)
      return to_s if argument.nil?
      
      members.zip(parse(argument)).each { |m,v| send("#{m}=", v.to_i) }
      self
    end
        
    def <=>(other)
      values.map(&:to_i) <=> other.values.map(&:to_i)
    end
    
    def to_s
      'P' + each_pair.map { |k,v| [v.to_i, k[0].upcase] }.each_slice(4).map(&:join).join('T').gsub(/0[YMWDHS]/, '').chomp('T')
    end

    members.each do |member|
      alias_method [member,'s'].join, member
    end
    
    protected
    
    def parse(string)
      string.match(ISO8601).captures.map(&:to_i)
    end
    
  end

end