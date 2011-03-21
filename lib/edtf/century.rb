class EDTF
  
  module Century
    
    attr_writer :century
    
    def century
      @century || (year / 100)
    end

    def century?
      !@century.nil?
    end

  end
  
end