module EDTF
  
  class Interval

    extend Forwardable

    include Enumerable
    
    def_delegators :to_range, *(Range.instance_methods(false))

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
    
    # TODO how to handle +/- Infinity for Dates?
    
    def to_range
      case
      when open?
        nil
      when unknown_end?
        nil
      else
        Range.new(unknown_start? ? Date.new : @from, bounds)
      end
    end
    
    def bounds
      case
      when open_end?, to.day_precision? 
        to
      when to.month_precision?
        to.end_of_month
      else
        to.end_of_year
      end
    end
   
		def edtf
			[
				@from.send(@from.respond_to?(:edtf) ? :edtf : :to_s),
				@to.send(@to.respond_to?(:edtf) ? :edtf : :to_s)
			].join('/')
		end
		
		alias to_s edtf
		
  end
  
end