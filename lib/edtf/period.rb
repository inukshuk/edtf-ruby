module EDTF

  # The interface shared by all EDTF types:
  # each one stands for a period of time.
  #
  # Including classes implement `begin` and `end` (plain dates, nil when open),
  # `precision`, `edtf`, and a protected `state` for `eql?` and `hash`.
  #
  # Like Ruby's Data, EDTF objects are frozen,
  # and so are their copies (dup, Marshal).
  module Period
    include Comparable

    # From the coarsest to the finest.
    PRECISIONS = %i[century decade year season month day second].freeze

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

    def to_s
      edtf
    end

    def inspect
      "#<#{self.class} #{edtf}>"
    end

    # The EDTF string, for JSON with or without ActiveSupport
    # (whose Date#as_json would drop precision and qualifiers).
    def as_json(*)
      edtf
    end

    # Returns true if the other period, date or time lies within this period,
    # like Range#cover?: by the bounds only, not by precision.
    # (Intervals, sets, and lists also have #include?.)
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

    # Returns true if other is the same EDTF expression.
    def eql?(other)
      other.instance_of?(self.class) && state.eql?(other.state)
    end

    def hash
      [self.class, *state].hash
    end

    # Ruby's Date#<=> coerces objects it doesn't know,
    # so plain dates compare with periods without a core patch.
    def coerce(other)
      raise TypeError, "#{other.class} can't be coerced into #{self.class}" unless other.is_a?(::Date)

      [EDTF(other), self]
    end

    # Orders periods by begin, then end, then precision;
    # qualifiers are ignored, so == means the same period.
    def <=>(other)
      other_keys = other.is_a?(Period) ? other.send(:keys) : Period.keys(other)
      keys <=> other_keys if other_keys
    end

    def initialize_copy(other)
      super
      freeze
    end

    # Marshal restores objects without initialize; plain EDTF objects
    # dump their instance variables and freeze on load.
    # (EDTF::Date and EDTF::DateTime use Ruby's own hooks.)
    def marshal_dump
      instance_variables.to_h { |name| [name, instance_variable_get(name)] }
    end

    def marshal_load(variables)
      variables.each { |name, value| instance_variable_set(name, value) }
      freeze
    end

    def self.bounds(other) # :nodoc:
      case other
      when Period then [other.begin, other.end]
      when ::DateTime, ::Time then [other.to_date] * 2
      when ::Date then [::Date.jd(other.jd, ::Date::GREGORIAN)] * 2
      end
    end

    # Plain dates are days; plain times are instants within a day.
    def self.precision(other) # :nodoc:
      case other
      when Period then other.precision
      when ::DateTime, ::Time then :second
      else :day
      end
    end

    # The sort keys of a plain date or time.
    def self.keys(other) # :nodoc:
      first, last = bounds(other)
      [[0, first], [0, last], PRECISIONS.index(precision(other))] if first
    end

    private

    # Raises like Data#with for keywords outside allowed.
    def check_keys!(changes, allowed)
      unknown = changes.keys - allowed
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?
    end

    # The sort keys: begin, end and precision.
    # Open bounds (nil) sort first at the start and last at the end.
    # Private, but read from other periods too (see <=>).
    def keys
      [self.begin ? [0, self.begin] : [-1], self.end ? [0, self.end] : [1], rank]
    end

    # Periods without a precision (intervals without dated ends) rank first.
    def rank
      PRECISIONS.index(precision) || -1
    end
  end

end
