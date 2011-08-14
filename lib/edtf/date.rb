module EDTF
  
  module ExtendedDate
    
    extend Forwardable
    
    include Seasons
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def uncertain
      @uncertain ||= Uncertainty.new
    end

    def approximate
      @approximate ||= Uncertainty.new
    end

    def unspecified
      @unspecified ||= Unspecified.new
    end
    
    def_delegators :uncertain, :uncertain?, :certain?

    def certain!(*arguments)
      uncertain.certain!(*arguments)
      self
    end
    
    def uncertain!(*arguments)
      uncertain.uncertain!(*arguments)
      self
    end

    def approximate?(*arguments)
      approximate.uncertain?(*arguments)
    end
    
    def approximate!(*arguments)
      approximate.uncertain!(*arguments)
      self
    end
    
    def precise!(*arguments)
      approximate.certain!(*arguments)
      self
    end

    def_delegators :unspecified, :unspecified?, :specified?, :unsepcific?, :specific?
    
    def unspecified!(*arguments)
      unspecified.unspecified!(*arguments)
      self
    end

    alias unspecific! unspecified!

    def specified!(*arguments)
      unspecified.specified!(*arguments)
      self
    end

    alias specific! specified!
        
    module ClassMethods  
      def edtf(string)
        case string
        when /^(-?\d{4})([\?~])?$/
          match = $~
          date = strptime(match.captures[0], '%Y')
          date.uncertain.year = match.captures[1] == '?'
          date

        when /^-?\d{4}-\d{1,2}$/
          strptime(string, '%Y-%m')
        else
          parse(string)
        end
      end
    end
    
  end
  
end