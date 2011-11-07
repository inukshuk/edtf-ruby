module EDTF
  
  class Interval

    extend Forwardable
    include Enumerable
    
    def_delegators :to_range,
      *Range.instance_methods(false).reject { |m| m.to_s =~ /^(each|first|last|min|max|inspect)$/ }

    attr_reader :from, :to

    def initialize(from = :open, to = :open)
      @from, @to = from, to
    end
    
    def from=(from)
      @from = from || :open
    end

    def to=(to)
      @to = to || :open
    end

    [:open, :unknown].each do |method_name|
      
      define_method("#{method_name}?") do
        @to == method_name || @from == method_name
      end

      define_method("#{method_name}!") do
        @to = method_name
      end

      alias_method("#{method_name}_end!", "#{method_name}!")
      
      define_method("#{method_name}_end?") do
        @to == method_name
      end
      
    end
    
    def unknown_start?
      @from == :unknown
    end
    
    def unknown_start!
      @from = :unknown
    end
    
    def each
      if block_given?
        to_range.each(&Proc.new)
      else
        to_enum
      end
    end
    
    # TODO how to handle +/- Infinity for Dates?
    # TODO we can't delegate to Ruby range for mixed precision intervals
    
    # Returns the Interval as a Range.
    def to_range
      case
      when open?
        nil
      when unknown_end?
        nil
      else
        Range.new(unknown_start? ? Date.new : @from, max)
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
        when unknown_start?, to < from
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
        when !unknown_start? && from > to
          nil
        when open_end?, to.day_precision? 
          to
        when to.month_precision?
          to.end_of_month
        else
          to.end_of_year
        end
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