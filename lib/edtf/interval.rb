module EDTF
  
  class Interval

    extend Forwardable

    include Enumerable
    
    def_delegators :to_range, *(Range.instance_methods - Enumerable.instance_methods - Object.instance_methods)

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
        Range.new(unknown_start? ? Date.new : from, to)
      end
    end
    
  end
  
end