require 'forwardable'

class EDTF
  
  class Interval
    extend Forwardable
    
    PATTERN = /^([T\d:-]+)\/([PTDMYHMS\d:-]+)$/
    
    def self.parse(string)
      new(*(string.match(PATTERN).captures.map { |p| EDTF.parse(p) }))
    end
    
    def initialize(start_date, end_date)
      @range = end_date.is_a?(Duration) ? end_date.to_range(start_date) :
        Range.new(start_date, end_date)
    end
    
    def_delegators(:@range, *Range.instance_methods)
  end
  
end