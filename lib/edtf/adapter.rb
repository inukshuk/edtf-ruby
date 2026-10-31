module EDTF

  # Builds the 4.x objects from parse results.
  # Each type moves to its 5.0 class in its own step;
  # this module goes once all types have moved.
  module Adapter

    module_function

    def build(result)
      case result
      when :open, :unknown then result
      when Array then build(result[0])..build(result[1])
      else send(result[:type], result)
      end
    end

    def date(result)
      values = result[:values]

      # XXXX is still EDTF::Unknown until EDTF::Date switches.
      return Unknown.new if values == [0] && result[:unspecified] == Bitmask::XXXX

      date = ::Date.gregorian(*values)
      date.precision = ::Date::PRECISION[values.length - 1]
      date.calendar = result[:calendar]
      qualify(date, result)
    end

    def date_time(result)
      offset = result[:offset]
      date_time = ::DateTime.new(*result[:values], Rational(offset || 0, 1440))
      date_time.skip_timezone = offset.nil?
      date_time
    end

    def year(result)
      ::Date.gregorian(result[:values][0]).year_precision!
    end

    def decade(result)
      Decade.new(result[:values][0] * 10)
    end

    def century(result)
      Century.new(result[:values][0] * 100)
    end

    def season(result)
      season = Season.new(*result[:values])
      season.uncertain! if result[:uncertain]
      season.approximate! if result[:approximate]
      season.qualifier = result[:qualifier]
      season
    end

    def interval(result)
      Interval.new(*result[:values].map { |value| build(value) })
    end

    def set(result)
      list(result).choice!
    end

    def list(result)
      set = Set.new(*result[:values].map { |value| build(value) })
      set.earlier! if result[:earlier]
      set.later! if result[:later]
      set
    end

    def qualify(date, result)
      uncertain, approximate = result.values_at(:uncertain, :approximate).map { |mask| Bitmask.new(mask) }

      ::Date::PRECISION.each do |part|
        date.uncertain!(part) if uncertain.intersect?(part)
        date.approximate!(part) if approximate.intersect?(part)
      end

      if (unspecified = result[:unspecified])
        { year: 0, month: 4, day: 6 }.each do |part, offset|
          digits = date.unspecified.send(part)
          digits.each_index { |idx| digits[idx] = true if unspecified[offset + idx] == 1 }
        end
      end

      date
    end
  end

end
