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
    
    [:first, :second, :third, :fourth].zip((21..24).to_a).each do |quarter, code|
      define_method("#{quarter}?") { @season == code }
      define_method("#{quarter}!") { @season = code }
    end
    
    [:spring, :summer, :autumn, :winter].zip([:first, :second, :third, :fourth]).each do |season, quarter|
      alias_method("#{season}?", "#{quarter}?")
      alias_method("#{season}!", "#{quarter}!")
    end
    
    attr_accessor :qualifier
    
    def qualified?; !!@qualifier; end
    
  end
  
end