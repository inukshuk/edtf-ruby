module EDTF

  # An EDTF date: a regular (proleptic Gregorian) Ruby date with
  # year, month or day precision, and bitmasks for its uncertain,
  # approximate and unspecified digits. Years of any size are
  # written with a Y prefix beyond four digits (Y170000002), and
  # may have significant digits (1950S2 spans 1900 to 1999).
  # Dates are frozen; use `with` for a modified copy.
  #
  # Date math (+, -, >>, <<) returns plain dates, because the result
  # no longer stands for the same EDTF string. Stepping with `succ`,
  # `prev`, `upto` and `downto` follows the precision.
  class Date < ::Date
    include Period

    PRECISION = %i[year month day].freeze

    # The masks that cover the whole date, by number of values.
    WHOLE = [nil, Bitmask::YEAR, Bitmask::YM, Bitmask::YMD].freeze

    ATTRIBUTES = %i[precision uncertain approximate unspecified significant].freeze

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

    # The lowest values, as many as the precision has.
    def values
      [year, month, day].take(values_count)
    end

    # Returns a copy with the given attributes replaced, like Data#with.
    def with(**changes)
      return self if changes.empty?

      unknown = changes.keys - ATTRIBUTES
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?

      precision = changes.fetch(:precision, self.precision).to_sym
      raise ArgumentError, "invalid precision: #{precision.inspect}" unless PRECISION.include?(precision)

      self.class.new(
        *[year, month, day].take(PRECISION.index(precision) + 1),
        **ATTRIBUTES.drop(1).to_h { |name| [name, changes.fetch(name) { send(name) }] }
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

    def include?(other)
      cover?(other) && Period.precision(other) == precision
    end

    # The next date at this precision; unspecified digits
    # step by the unit they leave open (201X -> 202X).
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

    def prev(by = 1)
      succ(-by)
    end

    def upto(max)
      return to_enum(:upto, max) unless block_given?

      date = self
      while (date <=> max) <= 0
        yield date
        date = date.succ
      end
      self
    end

    def downto(min)
      return to_enum(:downto, min) unless block_given?

      date = self
      while (date <=> min) >= 0
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

    # ActiveSupport's calculations (only when it is loaded).
    def advance(options)
      plain.advance(options)
    end

    def change(options)
      plain.change(options)
    end

    def ==(other)
      (self <=> other) == 0
    end

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

    def hash
      plain? ? plain.hash : [jd, *state].hash
    end

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

    alias to_s edtf

    def inspect
      "#<#{self.class} #{edtf}>"
    end

    # Used by the 4.x Date patch when a plain date is compared
    # with this one (removed in 2.10).
    def extended_hash
      plain? ? 0 : hash
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

    # A year beyond four digits, written with a Y prefix.
    def long_year?
      precision == :year && year.abs > 9999
    end

    # Masks cover four-digit years only, and EDTF does not qualify
    # long years or years with significant digits.
    def check_digits
      raise ArgumentError, 'significant digits need year precision' if significant && precision != :year
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
