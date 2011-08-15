
unless Date.respond_to?(:to_time)
  require 'time'
  
  class Date
    def to_time
      Time.parse(to_s)
    end
  end
  
end