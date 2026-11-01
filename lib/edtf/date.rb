module EDTF

  # EDTF dates extend the regular (proleptic Gregorian) Ruby Date class.
  # Every EDTF date acts as you would normally expect,
  # but provides additional functionality.
  #
  # Most notably, EDTF dates come in day, month, or year precision.
  # This is a subtle difference that determines how many other methods work:
  # the bounds, stepping with `succ`, `prev`, `upto` and `downto`,
  # and the EDTF string all follow the precision.
  # Dates can also be uncertain, approximate, or have unspecified digits,
  # marked by bitmasks.
  #
  # Years of any size are written with a Y prefix beyond four digits (Y170000002),
  # and may have significant digits (1950S2 spans 1900 to 1999).
  #
  # Dates are frozen; use `with` for a modified copy.
  # Date math (+, -, >>, <<) and calendar conversions return plain dates,
  # because the result no longer stands for the same EDTF string.
  # Create dates with `new`, `EDTF()` or `EDTF.parse`;
  # Ruby's other constructors (today, parse, …) are private.
  class Date < ::Date
    include Period

    PRECISION = %i[year month day].freeze

    # The masks that cover the whole date, by number of values.
    WHOLE = [nil, Bitmask::YEAR, Bitmask::YM, Bitmask::YMD].freeze

    QUALIFIERS = %i[uncertain approximate unspecified significant].freeze
    ATTRIBUTES = [*PRECISION, :precision, *QUALIFIERS].freeze

    # Ruby's constructors skip initialize, so their dates would not be frozen.
    private_class_method(*%i[
      today civil jd ordinal commercial parse strptime
      iso8601 rfc3339 xmlschema rfc2822 rfc822 httpdate jisx0301
    ].select { |name| ::Date.respond_to?(name) })

    DATE_MARSHAL = %i[marshal_dump marshal_load].to_h { |name| [name, ::Date.instance_method(name)] }.freeze
    private_constant :DATE_MARSHAL

    def initialize(year, month = nil, day = nil, uncertain: nil, approximate: nil, unspecified: nil, significant: nil)
      values = [year, month, day].compact
      raise ArgumentError, 'day given without month' if day && month.nil?

      super(year, month || 1, day || 1, ::Date::GREGORIAN)

      @precision = PRECISION[values.length - 1]
      @uncertain = bits(uncertain)
      @approximate = bits(approximate)
      @unspecified = bits(unspecified)
      @significant = significant && Integer(significant)

      check_digits
      freeze
    end

    attr_reader :significant

    # Returns this date's precision.
    # Instances created by Ruby's own date methods skip initialize;
    # they behave like unqualified dates with day precision.
    def precision
      @precision || :day
    end

    def uncertain
      @uncertain || Bitmask.new
    end

    def approximate
      @approximate || Bitmask.new
    end

    def unspecified
      @unspecified || Bitmask.new
    end

    def uncertain?(part = nil)
      qualified?(uncertain, part)
    end

    def approximate?(part = nil)
      qualified?(approximate, part)
    end

    def unspecified?(part = nil)
      qualified?(unspecified, part)
    end

    # Returns an array of the year, month, and day values
    # filtered by the date's precision.
    # Unspecified digits hold their lowest values.
    def values
      [year, month, day].take(values_count)
    end

    # Returns a copy with the given EDTF attributes replaced, like Data#with.
    # Values beyond the precision raise (2016 has no month to replace).
    def with(**changes)
      return self if changes.empty?

      check_keys!(changes, ATTRIBUTES)

      precision = changes.fetch(:precision, self.precision).to_sym
      raise ArgumentError, "invalid precision: #{precision.inspect}" unless PRECISION.include?(precision)

      count = PRECISION.index(precision) + 1
      beyond = PRECISION.drop(count) & changes.keys
      raise ArgumentError, "#{beyond.join(' and ')} beyond #{precision} precision" unless beyond.empty?

      self.class.new(
        *PRECISION.take(count).map { |name| changes.fetch(name) { send(name) } },
        **QUALIFIERS.to_h { |name| [name, changes.fetch(name) { send(name) }] }
      )
    end

    def begin
      return plain if atomic?
      return ::Date.new(significant_years.first, 1, 1, ::Date::GREGORIAN) if significant

      year, month, day = unspecified.min(absolute_values)
      year = -unspecified.max([self.year.abs])[0] if self.year.negative?

      ::Date.new(year, month || 1, day || 1, ::Date::GREGORIAN)
    end

    def end
      return plain if atomic?
      return ::Date.new(significant_years.last, 12, 31, ::Date::GREGORIAN) if significant

      year, month, day = unspecified.max(absolute_values)
      year = -unspecified.min([self.year.abs])[0] if self.year.negative?

      return ::Date.new(year, 12, 31, ::Date::GREGORIAN) if month.nil?
      return ::Date.new(year, month, -1, ::Date::GREGORIAN) if day.nil?

      last = ::Date.new(year, month, -1, ::Date::GREGORIAN).day
      ::Date.new(year, month, [day, last].min, ::Date::GREGORIAN)
    end

    # Returns the next day, month, or year depending on the date's precision.
    # Unspecified digits step by the unit they leave open (201X -> 202X).
    def succ(by = 1)
      year, month, day = unspecified.zero? ? values : bound_values(forward: by.positive? ^ self.year.negative?)

      values =
        case precision
        when :year then [year + by]
        when :month then (year * 12 + month - 1 + by).divmod(12).then { |y, m| [y, m + 1] }
        else (::Date.new(year, month, day, ::Date::GREGORIAN) + by).then { |d| [d.year, d.month, d.day] }
        end

      # Keep the lowest values the unspecified digits allow, as parsing does.
      unless unspecified.zero?
        values = unspecified.min([values[0].abs, *values.drop(1)]).tap { |v| v[0] = -v[0] if values[0].negative? }
      end

      self.class.new(*values, uncertain: uncertain, approximate: approximate, unspecified: unspecified, significant: significant)
    end

    alias next succ

    # Returns the previous day, month, or year depending on the date's precision.
    def prev(by = 1)
      succ(-by)
    end

    # Yields each date at this precision that begins on or before max ends.
    def upto(max)
      return to_enum(:upto, max) unless block_given?

      last = Period.bounds(max)&.last
      date = self
      while last && date.begin <= last
        yield date
        date = date.succ
      end
      self
    end

    # Yields each date at this precision that ends on or after min begins.
    def downto(min)
      return to_enum(:downto, min) unless block_given?

      first = Period.bounds(min)&.first
      date = self
      while first && date.end >= first
        yield date
        date = date.prev
      end
      self
    end

    def +(other)
      plain + other
    end

    def -(other)
      plain - other
    end

    def >>(other)
      plain >> other
    end

    def <<(other)
      plain << other
    end

    %i[next_day prev_day next_month prev_month next_year prev_year].each do |name|
      define_method(name) { |n = 1| plain.send(name, n) }
    end

    # Calendar conversions return plain dates of the same day.
    def new_start(start = ::Date::ITALY)
      plain.new_start(start)
    end

    %i[julian gregorian italy england].each do |name|
      define_method(name) { plain.send(name) }
    end

    def marshal_dump
      DATE_MARSHAL[:marshal_dump].bind_call(self)
    end

    def marshal_load(data)
      DATE_MARSHAL[:marshal_load].bind_call(self, data)
      freeze
    end

    def ==(other)
      (self <=> other) == 0
    end

    # Returns true if other is the same date and has the same EDTF attributes.
    def eql?(other)
      case other
      when Date
        jd == other.jd && state == other.state
      when ::Date
        plain? && plain.eql?(other)
      else
        false
      end
    end

    # Returns the plain Date hash unless EDTF attributes are set.
    def hash
      plain? ? plain.hash : [jd, *state].hash
    end

    # Returns the date's EDTF string.
    def edtf
      return "Y#{year}#{"S#{significant}" if significant}" if long_year?
      return "#{'-' if year.negative?}#{format('%04d', year.abs)}S#{significant}" if significant

      sign = year.negative? ? '-' : ''
      values = self.values.each_with_index.map { |value, idx| format(idx.zero? ? '%04d' : '%02d', value.abs) }

      return sign + unspecified.masks(values).join('-') unless unspecified.zero?

      values = uncertain.marks(values, '?') unless uncertain.zero?
      values = approximate.marks(values, '~').map { |value| value.sub(/~\?|\?~/, '%') } unless approximate.zero?

      sign + values.join('-')
    end

    protected

    def state
      [precision, uncertain.value, approximate.value, unspecified.value, significant]
    end

    private

    def bits(value)
      mask = value == true ? WHOLE[values_count] : Bitmask.convert(value)
      Bitmask.new(mask & WHOLE[values_count])
    end

    def values_count
      PRECISION.index(precision) + 1
    end

    # Returns true if this date has year precision and the year exceeds four digits;
    # such years are written with a Y prefix.
    def long_year?
      precision == :year && year.abs > 9999
    end

    # Masks cover four-digit years only,
    # and EDTF does not qualify long years or years with significant digits.
    def check_digits
      raise ArgumentError, 'years beyond four digits need year precision' if year.abs > 9999 && precision != :year
      raise ArgumentError, 'significant digits need year precision' if significant && precision != :year
      raise ArgumentError, "invalid significant digits: #{significant}" if significant && significant < 1
      return unless long_year? || significant

      unless [uncertain, approximate, unspecified].all?(&:zero?)
        raise ArgumentError, 'long years and significant digits cannot be qualified or unspecified'
      end
    end

    # The first and last year the significant digits allow.
    def significant_years
      digits = year.abs.to_s.length
      return year..year if significant >= digits

      unit = 10**(digits - significant)
      low = year.abs / unit * unit
      high = low + unit - 1

      year.negative? ? -high..-low : low..high
    end

    def qualified?(mask, part)
      part.nil? ? !mask.zero? : mask.intersect?(part)
    end

    # True for a single day without qualifiers.
    def plain?
      precision == :day && uncertain.zero? && approximate.zero? && unspecified.zero?
    end

    def atomic?
      precision == :day && unspecified.zero?
    end

    def plain
      ::Date.jd(jd, ::Date::GREGORIAN)
    end

    def absolute_values
      [year.abs, *values.drop(1)]
    end

    # The highest (or lowest) values the unspecified digits allow,
    # with the sign of negative years restored.
    def bound_values(forward:)
      values = forward ? unspecified.max(absolute_values) : unspecified.min(absolute_values)
      values[0] = -values[0] if year.negative?
      values
    end
  end

end
