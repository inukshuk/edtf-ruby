module EDTF
  
  module Seasons
    
    attr_reader :season
    
    def season?; !!@season; end
    
    def season=(new_season)
      case new_season
      when 1, 2, 3, 4
        @season = new_season + 20
      when 21, 22, 23, 24
        @season = new_season
      else
        raise ArgumentError, "bad season format (21, 22, 23 or 24 expected; was #{new_season.inspect})"
      end
    end
    
  end
  
end