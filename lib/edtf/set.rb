module EDTF
	
	class Set
		extend Forwardable
		
		include Enumerable
		include Comparable
				
		def_delegators :@dates, :size, :length, :empty?
		def_delegators :to_a, :include?
		
		attr_accessor :choice, :later, :earlier
		
		
		def initialize(*dates)
			@dates = ::SortedSet.new(dates.flatten)
			@choice, @later, @earlier = false, false, false
		end
		
		def initialize_copy(other)
			@set = other.to_set
		end

		[:choice, :later, :earlier].each do |m|
			define_method("#{m}?") { send(m) }
			define_method("#{m}!") do
				send("#{m}=", true)
				self
			end
		end

		def <<(date)
			dates << date
			self
		end
		
		def each
			if block_given?
				to_a.each(&Proc.new)
				self
			else
				to_enum
			end
		end
		
		def edtf
			parenthesize(dates.map { |d| d.respond_to?(:edtf) ? d.edtf : d.to_s }.join(', '))
		end
		
		def to_a
			dates.map { |d| Array(d) }.flatten
		end
		
		def to_set
			to_a.to_set
		end
		
		alias to_s edtf
		
		def <=>(other)
			return nil unless other.respond_to?(:to_a)
			to_a <=> other.to_a
		end
		
		private
				
		attr_reader :dates
		
		def parenthesize(string)
			p = choice? ? %w([ ]) : %w({ })
			p[-1,0] = '..' if earlier?
			p[-1,0] = string unless string.empty?
			p[-1,0] = '..' if later?
			p.join
		end
				
	end
	
end