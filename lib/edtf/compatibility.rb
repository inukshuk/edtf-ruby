
# unless DateTime.respond_to?(:to_time)
#   require 'time'
#   
#   class DateTime
#     def to_time
#       Time.parse(to_s)
#     end
#   end  
# end