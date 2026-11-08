require 'strscan'
require 'racc/parser'

module EDTF
  # The base class of the generated grammars (see EDTF::Parser).
  # A grammar returns plain parse results.
  class Grammar < Racc::Parser # :nodoc:

    PARTS = {
      year:  Bitmask::YEAR,
      month: Bitmask::MONTH,
      day:   Bitmask::DAY
    }.freeze

    DATE_MASKS = [
      nil, Bitmask::YEAR, Bitmask::YM, Bitmask::YMD
    ].freeze

    EXTENSIONS = %i[season_uncertainty basic_offset].freeze

    class ParseError < ArgumentError; end

    attr_reader :deprecations

    def initialize(extensions: EXTENSIONS, max_year_digits: 100)
      @extensions = extensions
      @max_year_digits = max_year_digits
    end

    def parse(input, debug: false)
      unless input.encoding == Encoding::UTF_8 || input.ascii_only?
        raise ParseError, "invalid encoding #{input.encoding}"
      end

      @yydebug = debug
      @src = StringScanner.new(input)
      @deprecations = []
      do_parse
    end

    def on_error(tid, value, stack)
      raise ParseError,
        "failed to parse date: unexpected '#{value}' at #{stack.inspect}"
    end

    def deprecate(name)
      @deprecations << name
    end

    def extension(name)
      return if @extensions.include?(name)
      raise ArgumentError, "extension #{name} is turned off"
    end

    # Rejects days the month cannot have.
    # With leap: true, February 29 is allowed in any year,
    def check_day(year, month, day, leap: false)
      max = Bitmask::MAXDAYS[month - 1]
      max = 28 if month == 2 && !leap && !::Date.gregorian_leap?(year)

      if day > max
        raise ArgumentError,
          "invalid date (invalid days #{day} for month #{month})"
      end

      [year, month, day]
    end

    # Returns the number written with the given digits.
    def number(digits)
      digits.reduce(0) { |n, digit| 10 * n + digit }
    end

    def date(*values, **attributes)
      { type: :date, values: values, **attributes }
    end

    def extend_date(result, *values)
      result.merge(values: result[:values] + values)
    end

    def exponent(sgnd, exponent)
      if sgnd.abs.to_s.length + exponent > @max_year_digits
        raise ArgumentError,
          "year too large: more than #{@max_year_digits} digits"
      end

      sgnd * 10**exponent
    end

    def year(value, level, significant = nil)
      result = { type: :year, level: level, values: [value] }
      result[:significant] = significant if significant
      result
    end

    def interval(from, to)
      { type: :interval, values: [from, to] }
    end

    # Qualifies the given parts (a Symbol, an Array, or a mask) of a result,
    # or the whole date if no parts are given.
    def qualify(result, qualifiers, parts = nil)
      mask = case parts
        when nil
          DATE_MASKS[result[:values].length]
        when Integer
          parts
        else
          Array(parts).sum { |part| PARTS[part] }
        end

      qualifiers.each do |q|
        result[q] = (result[q] || 0) | mask
      end
      result
    end
  end
end
