module EDTF

  # Bitmasks mark the uncertain, approximate or unspecified
  # digits of a date. Each bit stands for one digit:
  #
  #           YYYYMMDD
  #           --------
  #   Day     00000011
  #   Month   00001100
  #   Year    11110000
  #
  # Bitmasks are immutable: combining or qualifying returns a new one.
  class Bitmask < Data.define(:value)

    DIGIT = /\A[xX]\z/
    PATTERN = /\A[0-9xXdDmMyY]{8}\z/
    MAXDAYS = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

    class << self
      def compute(pattern)
        pattern.each_char.with_index.sum { |c, idx|
          DIGIT.match?(c) ? 2**idx : 0
        }
      end

      def convert(value)
        case value
        when Bitmask
          value.value
        when Integer
          value
        when true
          YMD
        when false, nil
          0
        when Array
          value.sum { |part| convert(part) }
        when Symbol, String
          case value.to_s
          when /\Adays?\z/i then DAY
          when /\Amonths?\z/i, /\Aseasons?\z/i then MONTH
          when /\Ayears?\z/i then YEAR
          when PATTERN then compute(value.to_s)
          else raise ArgumentError, "invalid bitmask: #{value.inspect}"
          end
        else
          raise ArgumentError, "invalid bitmask: #{value.inspect}"
        end
      end

      # Returns the values of a mask like "XXXX05XX",
      # with each X replaced by digit.
      def values(mask, digit: 0, normalize: true)
        num = mask.gsub(/[xX]/, digit.to_s)
        values = num.match(/\A(\d{4})(\d\d)?(\d\d)?\z/).captures.compact.map(&:to_i)
        normalize ? normalize(values) : values
      end

      def normalize(values)
        year, month, day = values
        return [year] if month.nil?

        month = month.clamp(1, 12)
        return [year, month] if day.nil?

        [year, month, day.clamp(1, MAXDAYS[month - 1])]
      end
    end

    DAY   = compute('yyyymmxx')
    MONTH = compute('yyyyxxdd')
    YEAR  = compute('xxxxmmdd')

    MD  = MONTH | DAY
    YM  = YEAR | MONTH
    YMD = YEAR | MD

    YYXX = compute('yyxxmmdd')
    YYYX = compute('yyyxmmdd')
    XXXX = compute('xxxxmmdd')

    DX = compute('yyyymmdx')
    XD = compute('yyyymmxd')
    MX = compute('yyyymxdd')
    XM = compute('yyyyxmdd')

    # Maps each qualifier position to the parts it qualifies:
    #
    #   ~YYYY~-~MM~-~DD~
    #   0    1 2  3 4  5
    UA = [YEAR, YEAR, MONTH, YM, DAY, YMD].freeze

    def initialize(value: 0)
      super(value: self.class.convert(value))
    end

    def to_i
      value
    end

    def zero?
      value.zero?
    end

    def intersect?(other)
      (value & self.class.convert(other)) != 0
    end

    def year?
      intersect?(YEAR)
    end

    def month?
      intersect?(MONTH)
    end

    def day?
      intersect?(DAY)
    end

    def |(other)
      with(value: value | self.class.convert(other))
    end

    # Returns a copy that also qualifies the parts
    # at the given qualifier position (see UA).
    def qualify(idx)
      self | UA[idx]
    end

    def qualified?(idx)
      case idx
      when 1
        value == YEAR || (value & YEAR != 0 && value & MONTH == 0)
      when 2
        value == MONTH || (value & MONTH != 0 && value & YEAR == 0)
      when 3
        value == YM
      when 4
        value == DAY || (value & DAY != 0 && value != YMD)
      when 5
        value == YMD
      else
        false
      end
    end

    # Masks digit strings, e.g. ["2016", "05"] -> ["201X", "05"].
    def masks(values, symbol = 'X')
      offset = 0

      values.map do |string|
        masked = string.each_char.with_index.map do |c, idx|
          value[offset + idx] == 1 ? symbol : c
        end
        offset += string.length
        masked.join
      end
    end

    # Adds qualifier symbols, e.g. ["2016", "05"] -> ["2016", "05?"].
    def marks(values, symbol = '?')
      values.each_with_index.map do |string, idx|
        [
          qualified?(idx * 2) ? symbol : '',
          string,
          qualified?(idx * 2 + 1) ? symbol : ''
        ].join
      end
    end

    # The highest values the unspecified digits allow.
    # The year must not be negative; callers handle the sign.
    # Leap years follow the calendar (a Ruby Date start).
    def max(values, start = ::Date::GREGORIAN)
      year, month, day = values
      return [] if year.nil?

      year = fill(year, '9') if year?
      month = months(year, month, day, start).last if month && month?
      return [year] if month.nil?
      return [year, month] if day.nil?

      maxdays = MAXDAYS[month - 1]

      case value & DAY
      when DAY
        day = maxdays
      when DX
        day = [maxdays, day + (9 - day % 10)].min
      when XD
        day %= 10

        if month == 2
          day += (day == 9 && !::Date.valid_date?(year, 2, 29, start)) ? 10 : 20
        else
          day += day < 2 ? 30 : 20
          day -= 10 if day > maxdays
        end
      end

      day = 28 if month == 2 && day > 28 && !::Date.valid_date?(year, 2, 29, start)

      [year, month, day]
    end

    # The lowest values the unspecified digits allow.
    # The year must not be negative; callers handle the sign.
    # Leap years follow the calendar (a Ruby Date start).
    def min(values, start = ::Date::GREGORIAN)
      year, month, day = values
      return [] if year.nil?

      year = fill(year, '0') if year?
      month = months(year, month, day, start).first if month && month?
      return [year] if month.nil?
      return [year, month] if day.nil?

      case value & DAY
      when DAY then day = 1
      when DX then day = [1, day / 10 * 10].max
      when XD then day = day % 10 == 0 ? 10 : day % 10
      end

      [year, month, day]
    end

    def to_s(symbol = 'X')
      masks(%w[YYYY MM DD], symbol).join('-')
    end

    # The lowest year above 0 the year digits allow:
    # negative years have no year 0 (-00XX ends with -0001).
    def least_year(year)
      digits = pattern(year)[0]
      (1..9999).find { |n| digits.match?(format('%04d', n)) }
    end

    private

    # Possible months allowed by the pattern.
    def months(year, month, day, start)
      _, digits, day_digits = pattern(year, month, day)
      months = (1..12).select { |m| digits.match?(format('%02d', m)) }
      return [month] if months.empty?
      return months if day.nil?

      first = (1..31).find { |d| day_digits.match?(format('%02d', d)) }
      fitting = months.select { |m| first && ::Date.valid_date?(year, m, first, start) }
      fitting.empty? ? months : fitting
    end

    # Patterns that match the values the digits allow, e.g. /\A19..\z/.
    def pattern(*values)
      strings = values.compact.each_with_index.map { |v, i| format(i.zero? ? '%04d' : '%02d', v) }
      masks(strings, '.').map { |digits| Regexp.new("\\A#{digits}\\z") }
    end

    def fill(year, digit)
      masks([format('%04d', year)], digit)[0].to_i
    end
  end
end
