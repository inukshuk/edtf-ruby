class EDTF

  class Duration < Struct.new(:year, :month, :week, :day, :hour, :minute, :second)
    include Comparable

    PATTERN = /^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$/
    
    class << self
      def parse(argument); new(argument.to_s); end
      alias :iso8601 :parse
    end
    
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
    
    def to_i; values.map(&:to_i); end
    
    def to_s
      'P' + each_pair.map { |k,v| [v.to_i, k[0].upcase] }.each_slice(4).map(&:join).join('T').gsub(/0[YMWDHS]/, '').chomp('T')
    end

    # TODO: handle overflows; daylight saving time; gap years
    def to_range(start)
      format =  "%Y %m %d %H %M %S"
      start .. DateTime.strptime(start.strftime(format).split(/\s/).zip(normalize).map { |a,b| a.to_i + b }.join(' '), format)
    end

    members.each do |member|
      alias_method [member,'s'].join, member
    end
    
    protected
    
    def parse(string)
      string.match(PATTERN).captures.map(&:to_i)
    end
    
    def normalize
      [year.to_i, month.to_i, day.to_i + week.to_i * 7, hour.to_i, minute.to_i, second.to_i]
    end
    
  end

end