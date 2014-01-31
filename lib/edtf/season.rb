module EDTF

  class Season
    extend Forwardable

    SEASONS = Hash[21, :spring, 22, :summer, 23, :autumn, 24, :winter].freeze

    CODES = Hash.new { |h,k| h.fetch(k.to_sym, nil) }.merge(
      SEASONS.invert).merge({ :fall => 23 }).freeze

    NORTHERN = Hash[:spring, [3,4,5], :summer, [6,7,8], :autumn, [9,10,11], :winter, [12,1,2]].freeze
    SOUTHERN = Hash[:autumn, [3,4,5], :winter, [6,7,8], :spring, [9,10,11], :summer, [12,1,2]].freeze

    NORTHERN_MONTHS = Hash[*NORTHERN.map { |s,ms| ms.map { |m| [m,s] } }.flatten].freeze
    SOUTHERN_MONTHS = Hash[*SOUTHERN.map { |s,ms| ms.map { |m| [m,s] } }.flatten].freeze


    include Comparable
    include Enumerable

    class << self
      def current
        Date.today.season
      end
    end

    attr_reader :season, :year

    attr_accessor :qualifier, :uncertain, :approximate

    def_delegators :to_range,
      *Range.instance_methods(false).reject { |m| m.to_s =~ /^(each|min|max|cover?|inspect)$|^\W/ }

    SEASONS.each_value do |s|
      define_method("#{s}?") { @season == s }
      define_method("#{s}!") { @season =  s }
    end

    alias fall? autumn?
    alias fall! autumn!

    [:first, :second, :third, :fourth].zip([:spring, :summer, :autumn, :winter]).each do |quarter, season|
      alias_method("#{quarter}?", "#{season}?")
      alias_method("#{quarter}!", "#{season}!")
    end


    def initialize(*arguments)
      arguments.flatten!
      raise ArgumentError, "wrong number of arguments (#{arguments.length} for 0..3)" if arguments.length > 3

      if arguments.length == 1
        case arguments[0]
        when Date
          @year, @season = arguments[0].year, NORTHERN_MONTHS[arguments[0]]
        when Symbol, String
          @year, @season = Date.today.year, SEASONS[CODES[arguments[0].to_sym]]
        else
          self.year = arguments[0]
          @season = NORTHERN_MONTHS[Date.today.month]
        end
      else
        self.year      = arguments[0] || Date.today.year
        self.season    = arguments[1] || NORTHERN_MONTHS[Date.today.month]
        self.qualifier = qualifier
      end
    end


    [:uncertain, :approximate].each do |m|

      define_method("#{m}?") { !!send(m) }

      define_method("#{m}!") do
        send("#{m}=", true)
        self
      end
    end

    def certain?; !uncertain; end
    def precise?; !approximate; end

    def certain!
      @uncertain = false
      self
    end

    def precise!
      @approximate = false
    end

    # Returns the next season.
    def succ
      s = dup
      s.season = next_season_code
      s.year = year + 1 if s.first?
      s
    end

    # def next(n = 1)
    # end

    def cover?(other)
      return false unless other.respond_to?(:day_precision)
      other = other.day_precision
      min.day_precision! <= other && other <= max.day_precision!
    end

    def each
      if block_given?
        to_range.each(&Proc.new)
        self
      else
        to_enum
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

    def edtf
      '%04d-%2d%s' % [year, CODES[season], qualified? ? "^#{qualifier}" : '']
    end

    alias to_s edtf


    def <=>(other)
      case other
      when Date
        cover?(other) ? 0 : to_date <=> other
      when Interval, Epoch
        [min, max] <=> [other.min, other.max]
      when Season
        [year, month, qualifier] <=> [other.year, other.month, other.qualifier]
      else
        nil
      end
    rescue
      nil
    end

    def ===(other)
      (self <=> other) == 0
    rescue
      false
    end

    def to_date
      Date.new(year, month, 1)
    end

    alias min to_date

    def max
      to_date.months_since(2).end_of_month
    end

    # Returns a Range that covers the season (a three month period).
    def to_range
      min .. max
    end

    protected

    def month
      NORTHERN[@season][0]
    end

    def season_code
      CODES[season]
    end

    def next_season_code(by = 1)
      ((season_code + by) % 4) + 20
    end

  end

end
