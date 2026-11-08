module EDTF

  # The interface shared by all EDTF types:
  # each one stands for a period of time.
  module Period
    include Comparable

    PRECISIONS = %i[
      century decade year season month day hour minute second
    ].freeze

    # Calendars by name, and the Ruby Date start of each
    # (the day of the reform: Julian dates before it, Gregorian after).
    # Any other reform day (a Julian day number) is a calendar, too.
    CALENDARS = {
      gregorian: ::Date::GREGORIAN,
      julian: ::Date::JULIAN,
      italy: ::Date::ITALY,
      england: ::Date::ENGLAND
    }.freeze

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
      calendar = " #{self.calendar}" if respond_to?(:calendar) && self.calendar != :gregorian
      "#<#{self.class} #{edtf}#{calendar}>"
    end

    # The EDTF string, for JSON with or without ActiveSupport
    # (whose Date#as_json would drop precision and qualifiers).
    def as_json(*)
      edtf
    end

    # Like Range#cover?: by the bounds only, not by precision.
    # A time counts as its own calendar date in its own offset;
    # nil bounds (open or unknown ends) reach without limit.
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
      when Period
        [other.begin, other.end]
      when ::DateTime, ::Time
        [other.to_date] * 2
      when ::Date
        [::Date.jd(other.jd, ::Date::GREGORIAN)] * 2
      end
    end

    # A calendar name (Symbol or String) or a Ruby Date start
    # -> the calendar's name, or its reform day.
    def self.calendar(value) # :nodoc:
      case value
      when nil
        :gregorian
      when Symbol, String
        name = value.to_sym
        return name if CALENDARS.key?(name)

        raise ArgumentError, "unknown calendar: #{value}"
      when Numeric
        return CALENDARS.key(value) if CALENDARS.value?(value)
        return value.to_i if value.finite? && value == value.to_i

        raise ArgumentError, "invalid calendar: #{value}"
      else
        raise ArgumentError, "invalid calendar: #{value.inspect}"
      end
    end

    # The Ruby Date start of a calendar.
    def self.start(calendar) # :nodoc:
      calendar = self.calendar(calendar)
      CALENDARS.fetch(calendar, calendar)
    end

    def self.precision(other) # :nodoc:
      case other
      when Period
        other.precision
      when ::DateTime, ::Time
        :second
      else
        :day
      end
    end

    def self.keys(other) # :nodoc:
      first, last = bounds(other)
      [[0, first], [0, last], PRECISIONS.index(precision(other))] if first
    end

    private

    def check_keys!(changes, allowed)
      unknown = changes.keys - allowed
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?
    end

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
