module EDTF

  # An EDTF date-time is a regular Ruby Time:
  # it acts as you would normally expect,
  # but knows whether its string had an offset.
  # Without one (2004-01-01T10:10:10) the time is floating;
  # it is kept on the UTC clock, never in the system's zone.
  #
  # Two times compare as instants, as in Ruby.
  # Compared with dates and other periods,
  # a time counts as its own calendar date in its own offset,
  # at a precision finer than a day.
  #
  # Date-times are frozen; use `with`, `getutc` or `getlocal` for a copy.
  # Time math (+, -) returns plain times.
  class DateTime < ::Time
    include Period

    ATTRIBUTES = %i[year month day hour minute second offset].freeze

    # The offset is given in minutes; nil means a floating time.
    def initialize(year, month, day, hour = 0, minute = 0, second = 0, offset: nil)
      super(year, month, day, hour, minute, second, offset.nil? || offset.zero? ? 'UTC' : Integer(offset) * 60)
      @floating = offset.nil?
      freeze
    end

    def floating?
      !!@floating
    end

    # Returns the offset in minutes, or nil for floating times.
    def offset
      utc_offset / 60 unless floating?
    end

    def precision
      :second
    end

    def values
      [year, month, day, hour, min, sec]
    end

    def with(**changes)
      return self if changes.empty?

      unknown = changes.keys - ATTRIBUTES
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?

      current = [year, month, day, hour, min, sec + subsec]
      values = ATTRIBUTES.take(6).zip(current).map { |name, value| changes.fetch(name, value) }
      self.class.new(*values, offset: changes.fetch(:offset, offset))
    end

    # The calendar date in the time's own offset.
    def begin
      ::Date.new(year, month, day, ::Date::GREGORIAN)
    end

    alias_method :end, :begin

    def <=>(other)
      other.is_a?(::Time) ? TIME_COMPARISON.bind_call(self, other) : super
    end

    # Returns true if other is the same instant with the same offset,
    # or is floating, too.
    def eql?(other)
      other.is_a?(::Time) && super &&
        utc_offset == other.utc_offset && floating? == (other.is_a?(DateTime) && other.floating?)
    end

    def hash
      floating? ? [super, :floating].hash : super
    end

    %i[getutc getlocal].each do |name|
      define_method(name) { |*args| ::Time.at(self, in: utc_offset).send(name, *args) }
    end

    # Returns the date-time's EDTF string.
    def edtf
      string = "#{'-' if year.negative?}#{format('%04d', year.abs)}#{strftime('-%m-%dT%H:%M:%S')}"
      string += ".#{strftime('%N').sub(/0+\z/, '')}" unless subsec.zero?

      return string if floating?

      string + (utc_offset.zero? ? 'Z' : strftime('%:z'))
    end

    alias to_s edtf

    def inspect
      "#<#{self.class} #{edtf}>"
    end

    TIME_COMPARISON = ::Time.instance_method(:<=>)
    private_constant :TIME_COMPARISON
  end

end
