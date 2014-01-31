module EDTF

  class Epoch
    extend Forwardable

    include Enumerable
    include Comparable

    class << self
      attr_reader :duration, :format

      def current
        new(Date.today.year)
      end

      private :new, :current
    end

    attr_reader :year

    def_delegators :to_range,
      *Range.instance_methods(false).reject { |m| m.to_s =~ /^(each|min|max|cover|inspect)$|^\W/ }


    def initialize(year = 0)
      self.year = year
    end

    def year=(year)
      @year = (year / self.class.duration) * self.class.duration
    end

    alias get year
    alias set year=

    def cover?(other)
      return false unless other.respond_to?(:day_precision)
      other = other.day_precision
      min.day_precision! <= other && other <= max.day_precision!
    end

    def <=>(other)
      case other
      when Date
        cover?(other) ? 0 : to_date <=> other
      when Interval, Season
        [min, max] <=> [other.min, other.max]
      when Epoch
        [year, self.class.duration] <=> [other.year, other.class.duration]
      else
        nil
      end
    rescue
      nil
    end

    def ===(other)
      (self <=> other) == 0
    rescue
      false
    end

    def each
      if block_given?
        to_range.each(&Proc.new)
      else
        to_enum
      end
    end

    def to_date
      Date.new(year).year_precision!
    end

    alias min to_date

    def max
      to_date.advance(:years => self.class.duration - 1).end_of_year
    end

    def to_range
      min..max
    end

    def edtf
      self.class.format % (year / self.class.duration)
    end

    alias to_s edtf

  end

  class Century < Epoch
    @duration = 100.freeze
    @format = '%02dxx'.freeze

    public_class_method :current, :new
  end

  class Decade < Epoch
    @duration = 10.freeze
    @format = '%03dx'.freeze

    public_class_method :current, :new
  end
end
