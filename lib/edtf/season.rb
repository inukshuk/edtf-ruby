module EDTF

  class Season
    
    SEASONS = Hash[21, :spring, 22, :summer, 23, :autumn, 24, :winter].freeze
    
    CODES = Hash.new { |h,k| h.fetch(k.to_sym, nil) }.merge(
      SEASONS.invert).merge({ :fall => 23 }).freeze
    
    NORTHERN = Hash[:spring, [3,4,5], :summer, [6,7,8], :autumn, [9,10,11], :winter, [12,1,2]].freeze
    SOUTHERN = Hash[:autumn, [3,4,5], :winter, [6,7,8], :spring, [9,10,11], :summer, [12,1,2]].freeze
    
    NORTHERN_MONTHS = Hash[*NORTHERN.map { |s,ms| ms.map { |m| [m,s] } }.flatten].freeze
    SOUTHERN_MONTHS = Hash[*SOUTHERN.map { |s,ms| ms.map { |m| [m,s] } }.flatten].freeze
    
    extend Forwardable
    
    include Comparable
    include Enumerable
    
    class << self
      def current
        Date.today.season
      end
    end

    attr_reader :season, :year
    
    attr_accessor :qualifier
    
    def_delegators :to_range, :each
    
    SEASONS.each_value do |s|
      define_method("#{s}?") { @season == s }
      define_method("#{s}!") { @season =  s }
    end
    
    alias fall? autumn?
    alias fall! autumn!
    
    [:first, :second, :third, :fourth].zip(SEASONS.values).each do |quarter, season|
      alias_method("#{quarter}?", "#{season}?")
      alias_method("#{quarter}!", "#{season}!")
    end

    
    def initialize(*arguments)
      arguments.flatten!
      raise ArgumentError, "wrong number of arguments (#{arguments.length} for 0..3)" if arguments.length > 3
      
      if arguments.length == 1 && arguments[0].is_a?(Date)
        @year, @season = arguments[0].year, NORTHERN_MONTHS[arguments[0]]
      else
        self.year      = arguments[0] || Date.today.year
        self.season    = arguments[1] || NORTHERN_MONTHS[Date.today.month]
        self.qualifier = qualifier
      end
    end

    def year=(new_year)
      @year = new_year.to_i
    end
    
    def season=(new_season)
      @season = SEASONS[new_season] || SEASONS[CODES[new_season]] ||
        raise(ArgumentError, "unknown season/format: #{new_season.inspect})")
    end

    def season?; true; end
    
    def qualified?; !!@qualifier; end
    
    def to_s
      '%04d-%2d%s' % [year, CODES[season], qualified? ? "^#{qualifier}" : '']
    end

    alias to_edtf to_s
    
    def <=>(other)
    end
    
    def to_range
      d = Date.new(@year, NORTHERN[@season][0])
    end
  end
  
end