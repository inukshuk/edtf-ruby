module EDTF

  # Decades and centuries are dedicated periods,
  # which always cover 10 or 100 years, respectively:
  # the years that begin with the given digits
  # (196 is 1960 to 1969, -19 is -1999 to -1900).
  # Epoch is their shared base.
  #
  # Qualifiers apply to the whole epoch:
  # 196~ is an approximate decade, not an approximate year.
  class Epoch
    include Period

    class << self
      # The number of years, the number of digits, and the precision.
      attr_reader :span, :digits, :precision
    end

    attr_reader :value

    def initialize(value, uncertain: false, approximate: false)
      @value = Integer(value)
      raise ArgumentError, "invalid #{precision}: #{value}" unless @value.abs < 10**self.class.digits

      @uncertain = qualified?(uncertain)
      @approximate = qualified?(approximate)
      freeze
    end

    def precision
      self.class.precision
    end

    def values
      [value]
    end

    def uncertain?
      @uncertain
    end

    def approximate?
      @approximate
    end

    def with(**changes)
      return self if changes.empty?

      check_keys!(changes, %i[value uncertain approximate])

      self.class.new(
        changes.fetch(:value, value),
        uncertain: changes.fetch(:uncertain, uncertain?),
        approximate: changes.fetch(:approximate, approximate?)
      )
    end

    def begin
      ::Date.new(span.first, 1, 1, ::Date::GREGORIAN)
    end

    def end
      ::Date.new(span.last, 12, 31, ::Date::GREGORIAN)
    end

    def succ(by = 1)
      with(value: value + by)
    end

    alias next succ

    def prev(by = 1)
      succ(-by)
    end

    def edtf
      string = "#{'-' if value.negative?}#{format("%0#{self.class.digits}d", value.abs)}"
      string += '?' if uncertain?
      string += '~' if approximate?
      string.sub('?~', '%')
    end

    protected

    def state
      [value, uncertain?, approximate?]
    end

    private

    # The first and last year.
    def span
      low = value.abs * self.class.span
      high = low + self.class.span - 1
      value.negative? ? -high..-low : low..high
    end

    # Qualifiers are booleans, or bitmasks as in parse results.
    def qualified?(qualifier)
      case qualifier
      when true, false, nil then !!qualifier
      when Integer then !qualifier.zero?
      else raise ArgumentError, "invalid qualifier: #{qualifier.inspect} (an epoch is qualified as a whole)"
      end
    end
  end

  class Decade < Epoch
    @span, @digits, @precision = 10, 3, :decade
  end

  class Century < Epoch
    @span, @digits, @precision = 100, 2, :century
  end

end
