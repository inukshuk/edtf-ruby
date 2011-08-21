module EDTF
  class Epoch
    
    extend Forwardable
    
    include Enumerable
    include Comparable
    
    attr_accessor :year
    
    alias get year
    alias set year=

    private_class_method :new
    
    def initialize(year = 0)
    end
        
    def <=>(other)
    end
    
    
    def to_date
      Date.new(year)
    end
    
  end
  
  class Century < Epoch

    def_delegator :to_range, :each
    
    def to_range
      d = to_date
      d .. d.years_since(100).end_of_year
    end
    
    def to_edtf
      '%02dxx' % (year / 100)
    end
    
  end
  
  class Decade < Epoch

    def_delegator :to_range, :each
    
    def to_range
      d = to_date
      d .. d.years_since(10).end_of_year
    end
        
    def to_edtf
      '%03dx' % (year / 10)
    end
  end
end