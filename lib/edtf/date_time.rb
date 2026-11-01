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
  # Create date-times with `new`, `EDTF()` or `EDTF.parse`;
  # Ruby's other constructors (now, at, …) are private.
  class DateTime < ::Time
    include Period

    ATTRIBUTES = %i[year month day hour min sec offset].freeze

    # Ruby's constructors skip initialize, so their times would not be frozen.
    private_class_method(*%i[
      now at mktime local utc gm parse strptime iso8601 xmlschema rfc2822 rfc822 httpdate
    ].select { |name| ::Time.respond_to?(name) })

    # Marshal uses Time's own _dump and _load, then freezes.
    undef_method :marshal_dump, :marshal_load

    def self._load(...)
      super.freeze
    end

    # The offset is given in minutes; nil means a floating time.
    def initialize(year, month, day, hour = 0, min = 0, sec = 0, offset: nil)
      super(year, month, day, hour, min, sec, offset.nil? || offset.zero? ? 'UTC' : Integer(offset) * 60)
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

      check_keys!(changes, ATTRIBUTES)

      current = [year, month, day, hour, min, sec + subsec]
      values = ATTRIBUTES.take(6).zip(current).map { |name, value| changes.fetch(name, value) }
      self.class.new(*values, offset: changes.fetch(:offset, offset))
    end

    # The calendar date in the time's own offset.
    def begin
      ::Date.new(year, month, day, ::Date::GREGORIAN)
    end

    alias_method :end, :begin

    # Returns the next second (or the one by seconds later).
    def succ(by = 1)
      time = self + by
      self.class.new(time.year, time.month, time.day, time.hour, time.min, time.sec + time.subsec, offset: offset)
    end

    alias next succ

    def prev(by = 1)
      succ(-by)
    end

    # A time covers only the same instant;
    # dates and other periods compare by the time's calendar date.
    def cover?(other)
      other.is_a?(::Time) ? self == other : super
    end

    def <=>(other)
      other.is_a?(::Time) ? TIME[:<=>].bind_call(self, other) : super
    end

    # Returns true if other is the same instant with the same offset,
    # or is floating, too.
    def eql?(other)
      other.is_a?(::Time) && TIME[:eql?].bind_call(self, other) &&
        utc_offset == other.utc_offset && floating? == (other.is_a?(DateTime) && other.floating?)
    end

    def hash
      floating? ? [TIME[:hash].bind_call(self), :floating].hash : TIME[:hash].bind_call(self)
    end

    %i[getutc getgm getlocal].each do |name|
      define_method(name) { |*args| ::Time.at(self, in: utc_offset).send(name, *args) }
    end

    # Returns the date-time's EDTF string.
    def edtf
      string = "#{'-' if year.negative?}#{format('%04d', year.abs)}#{strftime('-%m-%dT%H:%M:%S')}"
      string += ".#{strftime('%N').sub(/0+\z/, '')}" unless subsec.zero?

      return string if floating?

      string + (utc_offset.zero? ? 'Z' : strftime('%:z'))
    end

    # Time's own methods, which Period overrides.
    TIME = %i[<=> eql? hash].to_h { |name| [name, ::Time.instance_method(name)] }.freeze
    private_constant :TIME
  end

end
