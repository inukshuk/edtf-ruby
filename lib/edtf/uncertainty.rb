module EDTF
 
  class Uncertainty < Struct.new(:year, :month, :day, :hour, :minute, :second)
    
    def uncertain?(parts = members)
      [parts].flatten.any? { |p| !!send(p) }
    end

    def uncertain!(parts = members)
      [parts].flatten.each { |p| send("#{p}=", true) }
    end

    def certain?(parts = members); !uncertain?(parts); end
    
    def certain!(parts = members)
      [parts].flatten.each { |p| send("#{p}=", false) }
    end
   
  end
  
end