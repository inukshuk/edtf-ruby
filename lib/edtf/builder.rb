module EDTF

  # Builds EDTF objects from parse results.
  module Builder

    TYPES = %i[
      date date_time year decade century season interval set list
    ].freeze

    # With centuries: true, years with only their trailing digits
    # unspecified (19XX, 196X) are built as centuries and decades.
    EPOCHS = {
      Bitmask::YYXX => [Century, 100],
      Bitmask::YYYX => [Decade, 10]
    }.freeze

    module_function

    def build(result, centuries: true)
      case result
      when :open, :unknown, 'open', 'unknown'
        result.to_sym
      when Array
        build(result[0], centuries: centuries)..build(result[1], centuries: centuries)
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

        if %i[date interval set list].include?(type)
          send(type, result, centuries: centuries)
        else
          send(type, result)
        end
      else
        raise ArgumentError, "invalid parse result: #{result.inspect}"
      end
    end

    def date(result, centuries: true)
      if centuries && result[:values].length == 1
        epoch, size = EPOCHS[result[:unspecified]]

        year = result[:values][0]

        # Negative years stay dates: decades and centuries are not negative.
        if epoch && !year.negative?
          return epoch.new(year / size, **result.slice(:uncertain, :approximate, :calendar))
        end
      end

      Date.new(*result[:values], **result.slice(
        :uncertain,
        :approximate,
        :unspecified,
        :calendar
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
      Date.new(result[:values][0], **result.slice(:significant, :calendar))
    end

    # Decades and centuries in results were written 196 and 19.
    def decade(result)
      Decade.new(result[:values][0], short: true,
        **result.slice(:uncertain, :approximate, :calendar))
    end

    def century(result)
      Century.new(result[:values][0], short: true,
        **result.slice(:uncertain, :approximate, :calendar))
    end

    def season(result)
      year, season = result[:values]
      season = hemisphere(result[:qualifier], season)
      Season.new(year, season, **result.slice(
        :uncertain,
        :approximate,
        :unspecified,
        :calendar))
    end

    def hemisphere(qualifier, season)
      case qualifier
      when /\Anorth/i then season + 4
      when /\Asouth/i then season + 8
      else season
      end
    end

    # An interval may end at 24:00, the end of a day (hour 24),
    # which is kept to be written that way again.
    def interval(result, centuries: true)
      from, to = result[:values].map { |value|
        build(value, centuries: centuries)
      }

      to = to.with(t24: true) if to.is_a?(DateTime) && end_of_day?(result[:values][1])
      Interval.new(from, to)
    end

    def end_of_day?(result)
      result.is_a?(Hash) && (result[:values] || result['values'])[3] == 24
    end

    def set(result, centuries: true)
      members = result[:values].map { |value|
        build(value, centuries: centuries)
      }
      Set.new(*members, **result.slice(:earlier, :later))
    end

    def list(result, centuries: true)
      members = result[:values].map { |value|
        build(value, centuries: centuries)
      }
      List.new(*members, **result.slice(:earlier, :later))
    end
  end
end
