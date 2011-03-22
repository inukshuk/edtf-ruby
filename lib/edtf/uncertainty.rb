class EDTF
 
  class Uncertainty < Struct.new(:year, :month, :day, :hour, :minute, :second)
    
    def uncertain?(part = nil)
      part.nil? ? values.any? { |v| !!v } : !!send(part)
    end

    def certain?(part = nil); !uncertain?(nil); end
   
  end
  
end