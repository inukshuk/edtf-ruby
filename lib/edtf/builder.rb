module EDTF

  # Builds EDTF objects from parse results.
  # Results may come from outside (EDTF() accepts them),
  # also with String keys and values as read from JSON;
  # only the known types are built.
  module Builder

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

    # Legacy calendars (2001-02-03^julian) have no ISO 8601-2 equivalent;
    # the parse result keeps them, the date does not.
    def date(result)
      Date.new(*result[:values], **result.slice(:uncertain, :approximate, :unspecified))
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

    # Legacy hemisphere qualifiers (2001-21^southern) become ISO 8601-2
    # hemisphere seasons (2001-29); other qualifiers have no equivalent,
    # the parse result keeps them, the season does not.
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
