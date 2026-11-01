module EDTF

  # The interface shared by all EDTF types:
  # each one stands for a period of time.
  #
  # Including classes implement `begin` and `end` (plain dates,
  # nil when open), `precision`, and `edtf`.
  module Period
    include Comparable

    # From the coarsest to the finest.
    PRECISIONS = %i[century decade year season month day].freeze

    # Bounds widened by approximation; for now the nominal bounds.
    def earliest
      self.begin
    end

    def latest
      self.end
    end

    def to_range
      self.begin..self.end
    end

    # True if the other period, date or time lies within this period.
    # A time counts as its own calendar date in its own offset.
    # Open or unknown ends (nil bounds) reach without limit.
    def cover?(other)
      return false unless other.is_a?(Period) || Period.bounds(other)

      first, last = Period.bounds(other)
      (self.begin.nil? || (!first.nil? && self.begin <= first)) &&
        (self.end.nil? || (!last.nil? && last <= self.end))
    end

    def ===(other)
      cover?(other)
    end

    # Orders periods by begin, then end, then precision; qualifiers
    # are ignored, so == means the same period.
    def <=>(other)
      other_keys = other.is_a?(Period) ? other.send(:keys) : Period.keys(other)
      keys <=> other_keys if other_keys
    end

    def self.bounds(other)
      case other
      when Period then [other.begin, other.end]
      when ::DateTime, ::Time then [other.to_date] * 2
      when ::Date then [::Date.jd(other.jd, ::Date::GREGORIAN)] * 2
      end
    end

    def self.precision(other)
      other.is_a?(Period) ? other.precision : :day
    end

    # The sort keys of a plain date or time.
    def self.keys(other)
      first, last = bounds(other)
      [[0, first], [0, last], PRECISIONS.index(:day)] if first
    end

    private

    # The sort keys: begin, end and precision. Private, but read
    # from other periods too (see <=>).
    def keys
      [[0, self.begin], [0, self.end], rank]
    end

    # Periods without a precision (intervals without dated ends) rank first.
    def rank
      PRECISIONS.index(precision) || -1
    end
  end

end
