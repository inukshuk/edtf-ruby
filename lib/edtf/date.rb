module EDTF
  
  module ExtendedDateTime
    
    extend Forwardable
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def uncertain; @uncertain ||= Uncertainty.new; end
    def approximate; @approximate ||= Uncertainty.new; end
    
    def_delegators :uncertain, :uncertain?, :uncertain!, :certain?, :certain!

    def approximate?(*arguments); approximate.uncertain?(*arguments); end
    def approximate!(*arguments); approximate.certain!(*arguments); end

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