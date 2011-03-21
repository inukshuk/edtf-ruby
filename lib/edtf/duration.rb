class EDTF

  class Duration < Struct.new(:year, :month, :week, :day, :hour, :minute, :second)
    include Comparable

    def initialize(*arguments)
      arguments = iso8601(arguments[0]) if arguments.length == 1 && arguments[0].start_with?('P')
      super
    end

    def iso8601(duration)
      duration.match(/^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?(?:T(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?)?$/).captures.map(&:to_i)
    end
    
    def <=>(other)
      values.map(&:to_i) <=> other.values.map(&:to_i)
    end
    
    def to_s
      'P' + each_pair.map { |k,v| [v.to_i, k[0].upcase] }.each_slice(4).map(&:join).join('T').gsub(/0[YMWDHS]/, '').chomp('T')
    end
        
  end

end