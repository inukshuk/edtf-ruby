class EDTF
  
  module ExtendedDateTime
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def uncertain; @uncertain ||= Uncertainty.new; end
    def approximate; @approximate ||= Uncertainty.new; end
    
    def uncertain?(part = nil); uncertain.uncertain?(part); end
    def approximate?(part = nil); approximate.uncertain?(part); end

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