module EDTF

  # Builds EDTF objects from parse results.
  module Builder

    TYPES = %i[
      date date_time year decade century season interval set list
    ].freeze

    module_function

    def build(result)
      case result
      when :open, :unknown, 'open', 'unknown'
        result.to_sym
      when Array
        build(result[0])..build(result[1])
      when Hash
        result = result.transform_keys(&:to_sym)
        type = result[:type].to_s.to_sym

        unless TYPES.include?(type)
          raise ArgumentError,
            "invalid parse result type: #{result[:type].inspect}"
        end

        unless result[:values].is_a?(Array)
          raise ArgumentError,
            "invalid parse result values: #{result[:values].inspect}"
        end

        send(type, result)
      else
        raise ArgumentError, "invalid parse result: #{result.inspect}"
      end
    end

    def date(result)
      Date.new(*result[:values], **result.slice(
        :uncertain,
        :approximate,
        :unspecified
      ))
    end

    def date_time(result)
      values = result[:values].take(6)
      ms = result[:values][6]
      values[5] += Rational(ms, 1000) if ms

      precision = {
        4 => :hour,
        5 => :minute
      }.fetch(values.length, :second)

      DateTime.new(
        *values,
        offset: result[:offset],
        precision: precision
      )
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
      year, season = result[:values]
      season = hemisphere(result[:qualifier], season)
      Season.new(year, season, **result.slice(:uncertain, :approximate, :unspecified))
    end

    def hemisphere(qualifier, season)
      case qualifier
      when /\Anorth/i then season + 4
      when /\Asouth/i then season + 8
      else season
      end
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
