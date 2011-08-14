module EDTF
 
  class Uncertainty < Struct.new(:year, :month, :day, :hour, :minute, :second)
    def uncertain?(parts = members)
      [parts].flatten.any? { |p| !!send(p) }
    end

    def uncertain!(parts = members)
      [parts].flatten.each { |p| send("#{p}=", true) }
      self
    end

    def certain?(parts = members); !uncertain?(parts); end
    
    def certain!(parts = members)
      [parts].flatten.each { |p| send("#{p}=", false) }
      self
    end
  end

  # year = []
  class Unspecified < Struct.new(:year, :month, :day)
    
    def initialize
      super year = Array.new(4), month = Array.new(2), day = Array.new(2)
    end
    
    def unspecified?(parts = members)
      [parts].flatten.any? { |p| send(p).any? { |u| !!u } }
    end
    
    def unspecified!(parts = members)
      [parts].flatten.each { |p| send(p).map! { true } }
      self
    end

    def specified?(parts = members); !unspecified?(parts); end

    def specified!(parts = members)
      [parts].flatten.each { |p| send(p).map! { false } }
      self
    end
    
    alias specific? specified?
    alias unspecific? unspecified?

    alias specific! specified!
    alias unspecific! unspecified!
    
    private :year=, :month=, :day=
    
    def to_s
      [year, month, day].map { |p| p.map { |i| i ? 'u' : 's' }.join }.join('-')
    end
    
  end
  
end