module EDTF
  
  module ExtendedDate
    
    extend Forwardable
    
    include Seasons
    
    attr_accessor :calendar
    
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
      def edtf(input, options = {})
        ::EDTF::Parser.new(options).parse(input)
      end
    end
    
  end
  
end