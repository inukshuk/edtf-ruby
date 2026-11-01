module EDTF

  # An interval behaves like a regular Range but is dedicated to EDTF periods.
  # Most importantly, intervals use the precision of their start
  # when generating the set of contained values and for membership tests.
  # All tests are implemented without iteration.
  #
  # For example, the interval "2003/2006" covers the years 2003, 2004, 2005 and 2006.
  # Converting the interval to an array results in an array
  # containing exactly four dates with year precision.
  # This is also reflected in membership tests.
  #
  #     EDTF('2003/2006').count                      -> 4
  #
  #     EDTF('2003/2006').include? EDTF('2004')      -> true
  #     EDTF('2003/2006').include? EDTF('2004-03')   -> false
  #
  #     EDTF('2003/2006').cover? EDTF('2004-03')     -> true
  #
  # Each end is a date or season, :open (no bound, written ..),
  # or :unknown (written empty).
  # The bounds of open or unknown ends are nil.
  class Interval
    include Enumerable
    include Period # after Enumerable, so ActiveSupport's Enumerable#as_json doesn't win

    ENDS = %i[open unknown].freeze

    attr_reader :from, :to

    def initialize(from, to)
      @from = coerce_end(from)
      @to = coerce_end(to)
      freeze
    end

    # Returns the interval's precision.
    # Mixed precisions are not supported;
    # the start's precision takes precedence (the end's if the start has no date).
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

      check_keys!(changes, %i[from to])

      self.class.new(changes.fetch(:from, from), changes.fetch(:to, to))
    end

    # call-seq:
    #     interval.each { |period| block }  -> self
    #     interval.each                     -> Enumerator
    #
    # Iterates over the interval by the start's precision,
    # yielding each unit that begins within the interval,
    # without the qualifiers of the start:
    # 1980-08?/1994 yields the months from 1980-08 to 1994-12.
    # Like endless ranges, intervals with an open or unknown end iterate endlessly;
    # those without a dated start raise a RangeError.
    def each
      return to_enum(:each) unless block_given?
      raise RangeError, "cannot iterate the interval #{edtf} without a start" if ENDS.include?(from)

      unit = unqualified(from)
      while within?(unit)
        yield unit
        unit = unit.succ
      end
      self
    end

    def to_a
      raise RangeError, "cannot convert the endless interval #{edtf} to an array" if endless?

      super
    end

    alias entries to_a

    # Like Range#count, endless intervals count infinitely many units.
    def count(*args, &block)
      args.empty? && block.nil? && endless? ? Float::INFINITY : super
    end

    # Returns true if other is one of the units the interval yields,
    # like Range#include?, but without iterating:
    # covered and of the interval's precision.
    def include?(other)
      cover?(other) && Period.precision(other) == precision
    end

    def edtf
      [from, to].map { |value| value == :open ? '..' : value == :unknown ? '' : value.edtf }.join('/')
    end

    protected

    def state
      [from, to]
    end

    private

    def endless?
      ENDS.include?(to)
    end

    def within?(unit)
      case to
      when *ENDS then true
      when ::Time then unit <= to
      else unit.begin <= self.end
      end
    end

    def unqualified(period)
      case period
      when Date, Season then period.with(uncertain: nil, approximate: nil)
      when Epoch then period.with(uncertain: false, approximate: false)
      else period
      end
    end

    # Open starts sort before unknown ones, unknown ends before open ones.
    def keys
      [
        { open: [-2], unknown: [-1] }.fetch(from) { [0, self.begin] },
        { unknown: [1], open: [2] }.fetch(to) { [0, self.end] },
        rank
      ]
    end

    def coerce_end(value)
      case value
      when *ENDS, Period then value
      when ::Date then EDTF(value)
      else raise ArgumentError, "invalid interval end: #{value.inspect}"
      end
    end
  end

end
