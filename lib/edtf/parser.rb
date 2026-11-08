module EDTF
  # Parses EDTF strings into plain results (see #parse!).
  #
  # Two grammars read the input:
  # EDTF::ISO reads ISO 8601-2,
  # EDTF::Legacy the legacy syntax of the EDTF draft.
  class Parser

    # Legacy syntax and what to write in ISO syntax instead.
    LEGACY = {
      combined_qualifier: '`?~` is legacy syntax, use `%`',
      parentheses: '`(...)` is legacy syntax, qualify from the left: `2004-?06`',
      open: '`open` is legacy syntax, use `..`',
      unknown: '`unknown` is legacy syntax, leave the end empty',
      unspecified: '`u` is legacy syntax, use `X`',
      masked: '`198x` is legacy syntax, use `198` (decade) or `19` (century)',
      lowercase_y: '`y` is legacy syntax, use `Y`',
      lowercase_e: '`e` is legacy syntax, use `E`',
      negative_zero: '`-0000` is legacy syntax, use `0000`',
      whitespace: 'spaces in sets are legacy syntax, remove them',
      caret: '`^...` is legacy syntax, only hemispheres are kept (seasons 25-32)',
      midnight: '`T24:00:00` is legacy syntax, use `T00:00:00` of the next day',
      partial_date_time: '`2004T...` is legacy syntax, use `2004-01-01T...`'
    }.freeze

    # Unspecified digits allowed at level 1, by precision.
    UNSPECIFIED = [
      nil,
      [Bitmask::YYYX, Bitmask::YYXX, Bitmask::XXXX],
      [Bitmask::MONTH, Bitmask::XXXX | Bitmask::MONTH],
      [Bitmask::DAY, Bitmask::MD, Bitmask::YMD]
    ].freeze

    attr_reader :options, :deprecations

    def initialize(
      level: 2,
      extensions: nil,
      legacy: nil,
      strict: false,
      max_year_digits: 100,
      debug: false,
      warn: true
    )
      unless (0..2).cover?(level)
        raise ArgumentError, "invalid level #{level.inspect}"
      end

      extensions = !strict if extensions.nil?
      legacy = !strict if legacy.nil?
      extensions = check_extensions(extensions)

      @options = {
        level: level,
        extensions: extensions,
        legacy: legacy,
        max_year_digits: max_year_digits,
        debug: debug,
        warn: warn
      }.freeze

      @grammars = [ISO]
      @grammars << Legacy if legacy
      @grammars.map! do |grammar|
        grammar.new(extensions: extensions, max_year_digits: max_year_digits)
      end
    end

    def debug?
      !!(options[:debug] || ENV['DEBUG'])
    end

    def parse(input)
      parse!(input)
    rescue => e
      warn e.message if debug?
      nil
    end

    # Returns the parse result: a frozen Hash with the edtf.js structure
    # (`type`, `level`, `values` with 1-based months,
    # and bitmask integers for qualified or unspecified digits).
    # Results for legacy syntax carry `legacy: true`.
    def parse!(input)
      @deprecations = []
      result = finish(read(input))

      if result[:level] > options[:level]
        raise ArgumentError,
          "level #{result[:level]} input, parser level #{options[:level]}"
      end

      result[:legacy] = true if legacy?
      warn_deprecations(input) if options[:warn]
      deep_freeze(result)
    end

    # Returns true if the last successful parse read legacy syntax.
    def legacy?
      !deprecations.empty?
    end

    private

    def check_extensions(extensions)
      case extensions
      when true
        Grammar::EXTENSIONS
      when false
        []
      else
        unknown = Array(extensions) - Grammar::EXTENSIONS

        unless unknown.empty?
          raise ArgumentError, "unknown extensions #{unknown.inspect}"
        end

        Array(extensions).freeze
      end
    end

    # The ISO grammar reads the input first.
    # If it fails, the legacy grammar's result counts
    # only if the input used legacy syntax;
    # otherwise raises the ISO grammar's error.
    def read(input)
      @grammars[0].parse(input, debug: debug?)
    rescue ArgumentError => error
      legacy = @grammars[1] or raise

      begin
        result = legacy.parse(input, debug: debug?)
      rescue ArgumentError
        raise error
      end

      raise error if legacy.deprecations.empty?
      @deprecations = legacy.deprecations.uniq
      result
    end

    def warn_deprecations(input)
      unless deprecations.empty?
        messages = deprecations.map { |d| LEGACY[d] }
        warn "EDTF #{input.inspect}: #{messages.join('; ')}",
          category: :deprecated
      end
    end

    # Adds the level of a result and its members.
    def finish(result)
      case result
      when Array
        result.each { |member| finish(member) }
      when Hash
        result[:values].each { |value| finish(value) }
        result[:level] ||= level(result)
      end
      result
    end

    def level(result)
      case result[:type]
      when :date
        n = result[:values].length
        level = 0
        level = 2 if result[:calendar]

        if (unspecified = result[:unspecified])
          level = [level, UNSPECIFIED[n].include?(unspecified) ? 1 : 2].max
        end

        qs = result.values_at(:uncertain, :approximate).compact
        unless qs.empty?
          level = [
            level,
            qs.all?(Grammar::DATE_MASKS[n]) ? 1 : 2
          ].max
        end

        level
      when :date_time
        0
      when :century
        qualified?(result) ? 2 : 0
      when :decade, :set, :list
        2
      when :season
        level_2 = qualified?(result) || result[:qualifier]
        level_2 || result[:values][1] > 24 ? 2 : 1
      when :interval
        # Open or unknown ends are level 1, unspecified digits level 2.
        result[:values].map { |value|
          !value.is_a?(Hash) ? 1 : value[:unspecified] ? 2 : value[:level]
        }.max
      end
    end

    def qualified?(result)
      result.key?(:uncertain) || result.key?(:approximate)
    end

    def deep_freeze(result)
      case result
      when Array
        result.each { |member| deep_freeze(member) }
      when Hash
        result.each_value { |value| deep_freeze(value) }
      end
      result.freeze
    end
  end
end
