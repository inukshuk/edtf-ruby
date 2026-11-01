module EDTF

  # Builds objects from parse results while the types move to
  # their 5.0 classes one at a time (step 2); goes in step 2.10.
  # Members of intervals and sets stay 4.x objects until
  # their parent type has moved.
  module Adapter

    module_function

    def build(result)
      if result.is_a?(Hash) && result[:type] == :date && !result[:calendar]
        Date.new(*result[:values], **result.slice(:uncertain, :approximate, :unspecified))
      else
        member(result)
      end
    end

    # Builds 4.x objects. Legacy calendar dates stay 4.x dates,
    # because EDTF::Date has no calendar.
    def member(result)
      case result
      when :open, :unknown then result
      when Array then member(result[0])..member(result[1])
      else send(result[:type], result)
      end
    end

    def date(result)
      values = result[:values]
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
      Date.new(result[:values][0], significant: result[:significant])
    end

    def decade(result)
      Decade.new(result[:values][0], **result.slice(:uncertain, :approximate))
    end

    def century(result)
      Century.new(result[:values][0], **result.slice(:uncertain, :approximate))
    end

    def season(result)
      Season.new(*result[:values], **result.slice(:uncertain, :approximate, :unspecified, :qualifier))
    end

    def interval(result)
      Interval.new(*result[:values].map { |value| member(value) })
    end

    def set(result)
      list(result).choice!
    end

    def list(result)
      set = Set.new(*result[:values].map { |value| member(value) })
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
