
# unless DateTime.respond_to?(:to_time)
#   require 'time'
#   
#   class DateTime
#     def to_time
#       Time.parse(to_s)
#     end
#   end  
# end

	
class DateTime
	
	def iso8601
		to_time.iso8601
	end unless method_defined?(:iso8601)
	
end
