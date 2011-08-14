module EDTF
  
  class Interval

    extend Forwardable
        
    def initialize(start_date, end_date)
      @range = end_date.is_a?(Duration) ? end_date.to_range(start_date) :
        Range.new(start_date, end_date)
    end
    
    def_delegators(:@range, *Range.instance_methods.reject { |m| m.to_s =~ /^__/ || m.to_s == 'object_id' })
  end
  
end