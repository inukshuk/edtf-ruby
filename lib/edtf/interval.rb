module EDTF

  # An interval behaves like a regular Range but is dedicated to EDTF dates.
  # Most importantly, intervals use the date's precision when generating
  # the set of contained values and for membership tests. All tests are
  # implemented without iteration and should therefore be considerably faster
  # than if you were to use a regular Range.
  #
  # For example, the interval "2003/2006" covers the years 2003, 2004, 2005
  # and 2006. Converting the interval to an array would result in a an array
  # containing exactly four dates with year precision. This is also reflected
  # in membership tests.
  #
  #     Date.edtf('2003/2006').length                           -> 4
  #
  #     Date.edtf('2003/2006').include? Date.edtf('2004')       -> true
  #     Date.edtf('2003/2006').include? Date.edtf('2004-03')    -> false
  #
  #     Date.edtf('2003/2006').cover? Date.edtf('2004-03')      -> true
  #
  class Interval

    extend Forwardable

    include Comparable
    include Enumerable

    # Intervals delegate hash calculation to Ruby Range
    def_delegators :to_range, :eql?, :hash
    def_delegators :to_a, :length, :empty?

    attr_reader :from, :to

    def initialize(from = Date.today, to = :open)
      self.from, self.to = from, to
    end

    def from=(date)
      case date
      when Date, :unknown
        @from = date
      else
        throw ArgumentError.new("Intervals cannot start with: #{date}")
      end
    end

    def to=(date)
      case date
      when Date, :unknown, :open
        @to = date
      else
        throw ArgumentError.new("Intervals cannot end with: #{date}")
      end
    end

    [:open, :unknown].each do |method_name|
      define_method("#{method_name}_end!") do
        @to = method_name
        self
      end

      define_method("#{method_name}_end?") do
        @to == method_name
      end
    end

    alias open! open_end!
    alias open? open_end?

    def unknown_start?
      from == :unknown
    end

    def unknown_start!
      @from = :unknown
      self
    end

    def unknown?
      unknown_start? || unknown_end?
    end

    # Returns the intervals precision. Mixed precisions are currently not
    # supported; in that case, the start date's precision takes precedence.
    def precision
      min.precision || max.precision
    end

    # Returns true if the precisions of start and end date are not the same.
    def mixed_precision?
      min.precision != max.precision
    end

    def each(&block)
      step(1, &block)
    end


    # call-seq:
    #     interval.step(by=1) { |date| block }  -> self
    #     interval.step(by=1)                   -> Enumerator
    #
    # Iterates over the interval by passing by elements at each step and
    # yielding each date to the passed-in block. Note that the semantics
    # of by are precision dependent: e.g., a value of 2 can mean 2 days,
    # 2 months, or 2 years.
    #
    # If not block is given, returns an enumerator instead.
    #
    def step(by = 1)
      raise ArgumentError unless by.respond_to?(:to_i)

      if block_given?
        f, t, by = min, max, by.to_i

        unless f.nil? || t.nil? || by < 1
          by = { Date::PRECISIONS[precision] => by }

          until f > t do
            yield f
            f = f.advance(by)
          end
        end

        self
      else
        enum_for(:step, by)
      end
    end


    # This method always returns false for Range compatibility. EDTF intervals
    # always include the last date.
    def exclude_end?
      false
    end


    # TODO how to handle +/- Infinity for Dates?
    # TODO we can't delegate to Ruby range for mixed precision intervals

    # Returns the Interval as a Range.
    def to_range
      case
      when open?, unknown?
        nil
      else
        Range.new(unknown_start? ? Date.new : @from, max)
      end
    end

    # Returns true if other is an element of the Interval, false otherwise.
    # Comparision is done according to the Interval's min/max date and
    # precision.
    def include?(other)
      cover?(other) && precision == other.precision
    end
    alias member? include?

    # Returns true if other is an element of the Interval, false otherwise.
    # In contrast to #include? and #member? this method does not take into
    # account the date's precision.
    def cover?(other)
      return false unless other.is_a?(Date)

      other = other.day_precision

      case
      when unknown_start?
        max.day_precision! == other
      when unknown_end?
        min.day_precision! == other
      when open_end?
        min.day_precision! <= other
      else
        min.day_precision! <= other && other <= max.day_precision!
      end
    end

    # call-seq:
    #     interval.first     -> Date or nil
    #     interval.first(n)  -> Array
    #
    # Returns the first date in the interval, or the first n dates.
    def first(n = 1)
      if n > 1
        (ds = Array(min)).empty? ? ds : ds.concat(ds[0].next(n - 1))
      else
        min
      end
    end

    # call-seq:
    #     interval.last     -> Date or nil
    #     interval.last(n)  -> Array
    #
    # Returns the last date in the interval, or the last n dates.
    def last(n = 1)
      if n > 1
        (ds = Array(max)).empty? ? ds : ds.concat(ds[0].prev(n - 1))
      else
        max
      end
    end

    # call-seq:
    #     interval.min                  -> Date or nil
    #     interval.min { |a,b| block }  -> Date or nil
    #
    # Returns the minimum value in the interval. If a block is given, it is
    # used to compare values (slower). Returns nil if the first date of the
    # interval is larger than the last or if the interval has an unknown or
    # open start.
    def min
      if block_given?
        to_a.min(&Proc.new)
      else
        case
        when unknown_start?, !unknown_end? && !open? && to < from
          nil
        when from.day_precision?
          from
        when from.month_precision?
          from.beginning_of_month
        else
          from.beginning_of_year
        end
      end
    end

    def begin
      min
    end

    # call-seq:
    #     interval.max                  -> Date or nil
    #     interval.max { |a,b| block }  -> Date or nil
    #
    # Returns the maximum value in the interval. If a block is given, it is
    # used to compare values (slower). Returns nil if the first date of the
    # interval is larger than the last or if the interval has an unknown or
    # open end.
    #
    # To calculate the dates, precision is taken into account. Thus, the max
    # Date of "2007/2008" would be 2008-12-31, whilst the max Date of
    # "2007-12/2008-10" would be 2009-10-31.
    def max
      if block_given?
        to_a.max(&Proc.new)
      else
        case
        when open_end?, unknown_end?, !unknown_start? && to < from
          nil
        when to.day_precision?
          to
        when to.month_precision?
          to.end_of_month
        else
          to.end_of_year
        end
      end
    end

    def end
      max
    end

    def <=>(other)
      case other
      when Interval, Season, Epoch
        [min, max] <=> [other.min, other.max]
      when Date
        cover?(other) ? min <=> other : 0
      else
        nil
      end
    end

    def ===(other)
      case other
      when Interval
        cover?(other.min) && cover?(other.max)
      when Date
        cover?(other)
      else
        false
      end
    end


    # Returns the Interval as an EDTF string.
    def edtf
      [
        from.send(from.respond_to?(:edtf) ? :edtf : :to_s),
        to.send(to.respond_to?(:edtf) ? :edtf : :to_s)
      ] * '/'
    end

    alias to_s edtf

  end

end
