module EDTF

  # Builds objects from parse results
  # while the last 4.x types are phased out (step 2);
  # goes in step 2.10.
  module Adapter

    module_function

    def build(result)
      case result
      when :open, :unknown then result
      when Array then build(result[0])..build(result[1])
      else send(result[:type], result)
      end
    end

    # Legacy calendar dates stay 4.x dates,
    # because EDTF::Date has no calendar.
    def date(result)
      values = result[:values]
      return Date.new(*values, **result.slice(:uncertain, :approximate, :unspecified)) unless result[:calendar]

      date = ::Date.gregorian(*values)
      date.precision = ::Date::PRECISION[values.length - 1]
      date.calendar = result[:calendar]
      date
    end

    def date_time(result)
      DateTime.new(*result[:values], offset: result[:offset])
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
      Interval.new(*result[:values].map { |value| build(value) })
    end

    def set(result)
      Set.new(*result[:values].map { |value| build(value) }, **result.slice(:earlier, :later))
    end

    def list(result)
      List.new(*result[:values].map { |value| build(value) }, **result.slice(:earlier, :later))
    end
  end

end
