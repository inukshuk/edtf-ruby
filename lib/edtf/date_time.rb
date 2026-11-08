module EDTF

  # An EDTF date-time is a regular Ruby Time:
  # it acts as you would normally expect,
  # but knows whether its string had an offset.
  #
  # Two times compare as instants, as in Ruby.
  # Compared with dates and other periods,
  # a time counts as its own calendar date in its own offset,
  # at a precision finer than a day.
  class DateTime < ::Time
    include Period

    ATTRIBUTES = %i[
      year month day hour min sec offset precision t24
    ].freeze

    # The values each precision has, and its length in seconds.
    PRECISION = {
      hour: [4, 3600],
      minute: [5, 60],
      second: [6, 1]
    }.freeze

    # Ruby's constructors skip initialize,
    # so their times would not be frozen.
    private_class_method(*%i[
      now at mktime local utc gm parse strptime iso8601 xmlschema rfc2822 rfc822 httpdate
    ].select { |name| ::Time.respond_to?(name) })

    # Marshal uses Time's own _dump and _load, then freezes.
    undef_method :marshal_dump, :marshal_load

    def self._load(...)
      super.freeze
    end

    # The offset is given in minutes; nil means a floating time.
    # Minutes and seconds beyond the precision must be zero.
    # With t24: true, midnight is written as 24:00 of the day before,
    # as an interval that ends with that day (see #edtf).
    def initialize(
      year,
      month,
      day,
      hour = 0,
      min = 0,
      sec = 0,
      offset: nil,
      precision: :second,
      t24: false
    )
      precision = precision.to_sym
      raise ArgumentError,
        "invalid precision: #{precision.inspect}" unless PRECISION.key?(precision)

      beyond = [min, sec].drop(PRECISION[precision][0] - 4)
      raise ArgumentError,
        "minutes or seconds beyond #{precision} precision" unless beyond.all?(&:zero?)

      super(
        year,
        month,
        day,
        hour,
        min,
        sec,
        offset.nil? || offset.zero? ? 'UTC' : Integer(offset) * 60)

      @floating = offset.nil?
      @precision = precision
      @t24 = !!t24
      raise ArgumentError, 't24 needs a time at midnight' if @t24 && !midnight?
      freeze
    end

    def floating?
      !!@floating
    end

    def t24?
      !!@t24
    end

    # Returns the offset in minutes, or nil for floating times.
    def offset
      utc_offset / 60 unless floating?
    end

    def precision
      @precision || :second
    end

    def values
      [year, month, day, hour, min, sec].take(PRECISION[precision][0])
    end

    def with(**changes)
      return self if changes.empty?

      check_keys!(changes, ATTRIBUTES)

      precision = changes.fetch(:precision, self.precision).to_sym
      raise ArgumentError,
        "invalid precision: #{precision.inspect}" unless PRECISION.key?(precision)

      count = PRECISION[precision][0]
      beyond = ATTRIBUTES[count...6] & changes.keys
      raise ArgumentError,
        "#{beyond.join(' and ')} beyond #{precision} precision" unless beyond.empty?

      current = [year, month, day, hour, min, sec + subsec]
      values = ATTRIBUTES.take(count).zip(current).map { |name, value|
        changes.fetch(name, value)
      }

      self.class.new(
        *values,
        offset: changes.fetch(:offset, offset),
        precision: precision,
        t24: changes.fetch(:t24) { t24? && values.drop(3).all?(&:zero?) })
    end

    # The calendar date in the time's own offset.
    def begin
      ::Date.new(year, month, day, ::Date::GREGORIAN)
    end

    alias_method :end, :begin

    # Returns the next hour, minute or second, by precision
    # (or the one by units later).
    def succ(by = 1)
      time = self + by * PRECISION[precision][1]
      values = [
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        time.sec + time.subsec
      ]

      self.class.new(
        *values.take(PRECISION[precision][0]),
        offset: offset,
        precision: precision)
    end

    alias next succ

    def prev(by = 1)
      succ(-by)
    end

    # A time to the second covers only the same instant,
    # one to the hour or minute the instants within it;
    # dates and other periods compare by the time's calendar date.
    def cover?(other)
      return super unless other.is_a?(::Time)

      first, other_first = to_r, other.to_r
      other_span = DateTime.span(other)
      return first == other_first && other_span.zero? if span.zero?

      last = first + span
      first <= other_first &&
        (other_span.zero? ?
           other_first < last : other_first + other_span <= last)
    end

    # Times compare by their first instant, then by their last.
    def <=>(other)
      return super unless other.is_a?(::Time)

      order = TIME[:<=>].bind_call(self, other)
      order.zero? ? span <=> DateTime.span(other) : order
    end

    # Returns true if other is the same instant with the same offset,
    # or is floating, too.
    def eql?(other)
      other.is_a?(::Time) && TIME[:eql?].bind_call(self, other) &&
        utc_offset == other.utc_offset && floating? == (other.is_a?(DateTime) && other.floating?) &&
        precision == Period.precision(other)
    end

    def hash
      extra = [
        (:floating if floating?),
        (precision unless precision == :second)
      ].compact

      if extra.empty?
        TIME[:hash].bind_call(self)
      else
        [TIME[:hash].bind_call(self), *extra].hash
      end
    end

    %i[getutc getgm getlocal].each do |name|
      define_method(name) { |*args|
        ::Time.at(self, in: utc_offset).send(name, *args)
      }
    end

    # Returns the date-time's EDTF string;
    # a t24 time is written as 24:00 of the day before.
    def edtf
      date, hours = self.begin, hour
      date, hours = date - 1, 24 if t24?

      string = format(
        '%s%04d-%02d-%02dT%02d',
        ('-' if date.year.negative?),
        date.year.abs,
        date.month,
        date.day,
        hours)

      string += format(':%02d', min) unless precision == :hour
      string += format(':%02d', sec) if precision == :second
      string += ".#{strftime('%N').sub(/0+\z/, '')}" unless subsec.zero?

      return string if floating?

      string + (utc_offset.zero? ? 'Z' : strftime('%:z'))
    end

    # The length of a time in seconds: 0 for instants.
    def self.span(time) # :nodoc:
      time.is_a?(DateTime) && time.precision != :second ? PRECISION[time.precision][1] : 0
    end

    # Time's own methods, which Period overrides.
    TIME = %i[<=> eql? hash].to_h { |name|
      [name, ::Time.instance_method(name)]
    }.freeze

    private_constant :TIME

    private

    def span
      DateTime.span(self)
    end

    def midnight?
      hour.zero? && min.zero? && sec.zero? && subsec.zero?
    end
  end
end
