module EDTF

  # Builds EDTF objects from parse results.
  # Results may come from outside (EDTF() accepts them),
  # also with String keys and values as read from JSON;
  # only the known types are built.
  module Adapter

    TYPES = %i[date date_time year decade century season interval set list].freeze

    module_function

    def build(result)
      case result
      when :open, :unknown, 'open', 'unknown' then result.to_sym
      when Array then build(result[0])..build(result[1])
      when Hash
        result = result.transform_keys(&:to_sym)
        type = result[:type].to_s.to_sym
        raise ArgumentError, "invalid parse result type: #{result[:type].inspect}" unless TYPES.include?(type)
        raise ArgumentError, "invalid parse result values: #{result[:values].inspect}" unless result[:values].is_a?(Array)

        send(type, result)
      else
        raise ArgumentError, "invalid parse result: #{result.inspect}"
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
