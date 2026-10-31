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
    def cover?(other)
      first, last = Period.bounds(other)
      return false if first.nil? || last.nil?

      (self.begin.nil? || self.begin <= first) && (self.end.nil? || last <= self.end)
    end

    def ===(other)
      cover?(other)
    end

    # Orders periods by begin, then end, then precision; qualifiers
    # are ignored, so == means the same period.
    def <=>(other)
      first, last = Period.bounds(other)
      return nil if first.nil? || last.nil?

      (self.begin <=> first).nonzero? ||
        (self.end <=> last).nonzero? ||
        PRECISIONS.index(precision) <=> PRECISIONS.index(Period.precision(other))
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
  end

end
