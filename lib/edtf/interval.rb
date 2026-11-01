module EDTF

  # An interval between two periods. Each end is a date or season,
  # or :open (no bound, written ..) or :unknown (written empty).
  # The bounds of open or unknown ends are nil.
  #
  # Intervals enumerate their start's units (1980-08/1994 yields the
  # months from 1980-08 to 1994-12); only closed intervals can.
  class Interval
    include Period
    include Enumerable

    ENDS = %i[open unknown].freeze

    attr_reader :from, :to

    def initialize(from, to)
      @from = coerce(from)
      @to = coerce(to)
      freeze
    end

    def precision
      [from, to].find { |value| value.is_a?(Period) }&.precision
    end

    def values
      [from, to]
    end

    def begin
      from.begin unless ENDS.include?(from)
    end

    def end
      to.end unless ENDS.include?(to)
    end

    def open?
      from == :open || to == :open
    end

    def unknown?
      from == :unknown || to == :unknown
    end

    def with(**changes)
      return self if changes.empty?

      unknown = changes.keys - %i[from to]
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?

      self.class.new(changes.fetch(:from, from), changes.fetch(:to, to))
    end

    def each
      return to_enum(:each) unless block_given?
      raise RangeError, "cannot iterate the open or unknown interval #{edtf}" if open? || unknown?

      unit = from
      while unit.begin <= self.end
        yield unit
        unit = unit.succ
      end
      self
    end

    # True for covered periods of the same precision as the members.
    def include?(other)
      cover?(other) && Period.precision(other) == precision
    end

    def eql?(other)
      other.instance_of?(self.class) && from.eql?(other.from) && to.eql?(other.to)
    end

    def hash
      [self.class, from, to].hash
    end

    def edtf
      [from, to].map { |value| value == :open ? '..' : value == :unknown ? '' : value.edtf }.join('/')
    end

    alias to_s edtf

    def inspect
      "#<#{self.class} #{edtf}>"
    end

    private

    # Open starts sort before unknown ones, unknown ends before open ones.
    def keys
      [
        { open: [-2], unknown: [-1] }.fetch(from) { [0, self.begin] },
        { unknown: [1], open: [2] }.fetch(to) { [0, self.end] },
        rank
      ]
    end

    def coerce(value)
      case value
      when *ENDS, Period then value
      when ::Date then EDTF(value)
      else raise ArgumentError, "invalid interval end: #{value.inspect}"
      end
    end
  end

end
