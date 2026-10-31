# -*- racc -*-

class EDTF::Parser

token T Z E X U UNKNOWN OPEN LONGYEAR UNMATCHED DOTS UA PUA

expect 0

rule

  edtf : level_0_expression
       | level_1_expression
       | level_2_expression
       ;

  # ---- Level 0 / ISO 8601 Rules ----

  # NB: level 0 intervals are covered by the level 1 interval rules
  level_0_expression : date
                     | date_time
                     ;

  date :
    year             { result = date(val[0]) }
    | year_month     { result = date(*val[0]) }
    | year_month_day { result = date(*val[0]) }
    ;


  date_time : date T time {
    year, month, day = val[0][:values]
    result = { type: :date_time, values: [year, month || 1, day || 1, *val[2][0, 3]] }
    result[:offset] = val[2][3] if val[2].length > 3
  }

  time : base_time
       | base_time zone_offset { result = val.flatten }

  base_time : hour ':' minute ':' second { result = val.values_at(0, 2, 4) }
            | midnight

  midnight : '2' '4' ':' '0' '0' ':' '0' '0' { result = [24, 0, 0] }

  zone_offset : Z                        { result = 0 }
              | '-' zone_offset_hour     { result = -1 * val[1] }
              | '+' positive_zone_offset { result = val[1] }
              ;

  positive_zone_offset : zone_offset_hour
                       | '0' '0' ':' '0' '0' { result = 0 }
                       ;


  zone_offset_hour : d01_13 ':' minute   { result = val[0] * 60 + val[2] }
                   | '1' '4' ':' '0' '0' { result = 840 }
                   | '0' '0' ':' d01_59  { result = val[3] }
                   ;

  year : positive_year
       | '-' positive_year {
         result = -val[1]
         deprecate :negative_zero if result.zero?
       }

  positive_year : digit digit digit digit {
    result = val.zip([1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b }
  }

  month : d01_12
  day : d01_31

  year_month : year '-' month { result = [val[0], val[2]] }

  year_month_day : year_month '-' day {
    result = check_day(*val[0], val[2])
  }

  hour   : d00_23
  minute : d00_59
  second : d00_59

  # Completely covered by level_1_interval
  # level_0_interval : date '/' date { result = Interval.new(val[0], val[1]) }


  # ---- Level 1 Extension Rules ----

  # NB: Uncertain/approximate Dates are covered by the Level 2 rules
  level_1_expression : unknown | unspecified | level_1_interval | long_year_simple | season

  unknown : U U U U {
    result = date(0, unspecified: Bitmask::XXXX)
    deprecate :unknown_date
  }

  # uncertain_or_approximate_date : date UA { result = uoa(val[0], val[1]) }

  unspecified : unspecified_year { result = date(val[0][0], unspecified: val[0][1]) }
              | unspecified_month
              | unspecified_day
              | unspecified_day_and_month
              ;

  unspecified_year : positive_unspecified_year
                   | '-' positive_unspecified_year
                   {
                     result = val[1]
                     result[0] = -result[0]
                   }

  positive_unspecified_year :
    digit digit digit U
    {
      result = [val[0,3].zip([1000,100,10]).reduce(0) { |s,(a,b)| s += a * b }, Bitmask::YYYX]
    }
    | digit digit U U
    {
      result = [val[0,2].zip([1000,100]).reduce(0) { |s,(a,b)| s += a * b }, Bitmask::YYXX]
    }

  unspecified_month : year '-' U U {
    result = date(val[0], 1, unspecified: Bitmask::MONTH)
  }

  unspecified_day : year_month '-' U U {
    result = date(*val[0], 1, unspecified: Bitmask::DAY)
  }

  unspecified_day_and_month : year '-' U U '-' U U {
    result = date(val[0], 1, 1, unspecified: Bitmask::MD)
  }

  level_1_interval : level_1_interval_closed | level_1_interval_open | level_1_interval_unknown

  level_1_interval_closed : level_1_start '/' level_1_end {
    result = interval(val[0], val[2])
  }

  level_1_interval_open : level_1_interval_open_start | level_1_interval_open_end 

  level_1_interval_open_start : open_start_or_end '/' level_1_end {
    result = interval(:open, val[2])
  }

  level_1_interval_open_end : level_1_start '/' open_start_or_end {
    result = interval(val[0], :open)
  }

  open_start_or_end : OPEN | DOTS 

  level_1_interval_unknown : level_1_interval_empty_start | level_1_interval_empty_end | level_1_interval_unknown_start | level_1_interval_unknown_end

  level_1_interval_empty_start : '/' level_1_end {
    result = interval(:unknown, val[1])
  }

  level_1_interval_empty_end : level_1_start '/' {
    result = interval(val[0], :unknown)
  }

  level_1_interval_unknown_start : UNKNOWN '/' level_1_end {
    result = interval(:unknown, val[2])
  }

  level_1_interval_unknown_end : level_1_start '/' UNKNOWN {
    result = interval(val[0], :unknown)
  }

  level_1_start : date | partial_uncertain_or_approximate | unspecified | partial_unspecified

  level_1_end : level_1_start


  long_year_simple :
    LONGYEAR long_year       { result = year(val[1], 1) }
    | LONGYEAR '-' long_year { result = year(-val[2], 1) }
    ;

  long_year :
    positive_digit digit digit digit digit {
      result = val.zip([10000,1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b }
    }
    | long_year digit { result = 10 * val[0] + val[1] }
    ;


  season : year '-' season_number ua {
    result = uoa({ type: :season, values: [val[0], val[2]] }, val[3], Bitmask::YM)
  }

  season_number : '2' '1' { result = 21 }
                | '2' '2' { result = 22 }
                | '2' '3' { result = 23 }
                | '2' '4' { result = 24 }
                ;


  # ---- Level 2 Extension Rules ----

  # NB: Level 2 Intervals are covered by the Level 1 Interval rules.
  level_2_expression : season_qualified
                     | partial_uncertain_or_approximate
                     | partial_unspecified
                     | choice_list
                     | inclusive_list
                     | masked_precision
                     | date_and_calendar
                     | long_year_scientific
                     ;


  season_qualified : season '^' { result = val[0]; result[:qualifier] = val[1] }


  long_year_scientific :
    long_year_simple E integer      { result = year(val[0][:values][0] * 10 ** val[2], 2) }
    | LONGYEAR int1_4 E integer       { result = year(val[1] * 10 ** val[3], 2) }
    | LONGYEAR '-' int1_4 E integer   { result = year(-val[2] * 10 ** val[4], 2) }
    ;


  date_and_calendar : date '^' { result = val[0]; result[:calendar] = val[1] }


  masked_precision :
    digit digit digit X
    {
      result = { type: :decade, values: [val[0,3].zip([100,10,1]).reduce(0) { |s,(a,b)| s += a * b }] }
    }
    | digit digit X X
    {
      result = { type: :century, values: [val[0] * 10 + val[1]] }
    }
    ;


  choice_list : '[' list ']'   { result = { type: :set, **val[1] } }

  inclusive_list : '{' list '}' { result = { type: :list, **val[1] } }

  list : earlier                              { result = { values: [val[0]], earlier: true } }
       | earlier ',' list_elements ',' later  { result = { values: [val[0], *val[2], val[4]], earlier: true, later: true } }
       | earlier ',' list_elements            { result = { values: [val[0], *val[2]], earlier: true } }
       | earlier ',' later                    { result = { values: [val[0], val[2]], earlier: true, later: true } }
       | list_elements ',' later              { result = { values: [*val[0], val[2]], later: true } }
       | list_elements                        { result = { values: val[0] } }
       | later                                { result = { values: [val[0]], later: true } }
       ;

  list_elements : list_element                   { result = [val[0]] }
                | list_elements ',' list_element { result = val[0] + [val[2]] }
                ;

  list_element : atomic
               | consecutives
               ;

  atomic : date
         | partial_uncertain_or_approximate
         | unspecified
         ;

  earlier : DOTS date { result = val[1] }

  later : year_month_day DOTS { result = date(*val[0]) }
        | year_month DOTS     { result = date(*val[0]) }
        | year DOTS           { result = date(val[0]) }
        ;

  consecutives : year_month_day DOTS year_month_day { result = [date(*val[0]), date(*val[2])] }
               | year_month DOTS year_month         { result = [date(*val[0]), date(*val[2])] }
               | year DOTS year                     { result = [date(val[0]), date(val[2])] }
               ;

  partial_unspecified :
    unspecified_year '-' month '-' day
    {
      check_day(val[0][0], val[2], val[4], leap: true)
      result = date(val[0][0], val[2], val[4], unspecified: val[0][1])
    }
    | unspecified_year '-' month
    {
      result = date(val[0][0], val[2], unspecified: val[0][1])
    }
    | unspecified_year '-' U U '-' day
    {
      result = date(val[0][0], 1, val[5], unspecified: val[0][1] | Bitmask::MONTH)
    }
    | unspecified_year '-' U U '-' U U
    {
      result = date(val[0][0], 1, 1, unspecified: val[0][1] | Bitmask::MD)
    }
    | unspecified_year '-' month '-' U U
    {
      result = date(val[0][0], val[2], 1, unspecified: val[0][1] | Bitmask::DAY)
    }
    | year '-' U U '-' day
    {
      result = date(val[0], 1, val[5], unspecified: Bitmask::MONTH)
    }
    ;

  partial_uncertain_or_approximate : pua_base
    | '(' pua_base ')' UA { result = uoa(val[1], val[3]) }

  pua_base :
    pua_year
    | pua_year_month     { result = val[0][0] }
    | pua_year_month_day

  pua_year : year UA { result = uoa(date(val[0]), val[1], :year) }

  pua_year_month :
    pua_year '-' month ua {
      result = [uoa(extend_date(val[0], val[2]), val[3], [:month, :year])]
    }
    | year '-' month UA {
        result = [uoa(date(val[0], val[2]), val[3], [:year, :month])]
    }
    | year '-(' month ')' UA {
        result = [uoa(date(val[0], val[2]), val[4], [:month]), true]
    }
    | pua_year '-(' month ')' UA {
        result = [uoa(extend_date(val[0], val[2]), val[4], [:month]), true]
    }
    ;

  pua_year_month_day :
    pua_year_month '-' day ua {
      result = uoa(extend_date(val[0][0], val[2]), val[3], val[0][1] ? [:day] : nil)
    }
    | pua_year_month '-(' day ')' UA {
        result = uoa(extend_date(val[0][0], val[2]), val[4], [:day])
    }
    | year '-(' month ')' UA day ua {
        result = uoa(uoa(date(val[0], val[2], val[5]), val[4], :month), val[6], :day)
    }
    | year_month '-' day UA {
        result = uoa(date(val[0][0], val[0][1], val[2]), val[3])
    }
    | year_month '-(' day ')' UA {
        result = uoa(date(val[0][0], val[0][1], val[2]), val[4], [:day])
    }
    | year '-(' month '-' day ')' UA {
        result = uoa(date(val[0], val[2], val[4]), val[6], [:month, :day])
    }
    | year '-(' month '-(' day ')' UA ')' UA {
        result = date(val[0], val[2], val[4])
        result = uoa(result, val[6], [:day])
        result = uoa(result, val[8], [:month, :day])
    }
    | pua_year '-(' month '-' day ')' UA {
        result = extend_date(val[0], val[2], val[4])
        result = uoa(result, val[6], [:month, :day])
    }
    | pua_year '-(' month '-(' day ')' UA ')' UA {
        result = extend_date(val[0], val[2], val[4])
        result = uoa(result, val[6], [:day])
        result = uoa(result, val[8], [:month, :day])
    }
    # | '(' pua_year '-(' month ')' UA ')' UA '-' day ua {
    #     result = val[1].change(:month => val[3], :day => val[9])
    #     result = uoa(result, val[5], [:month])
    #     result = [uoa(result, val[7], [:year]), true]
    # }
    ;

  ua : { result = [] } | UA

  # ---- Auxiliary Rules ----

  digit : '0' { result = 0 }
        | positive_digit
        ;

  positive_digit : '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

  d01_12 : '0' positive_digit { result = val[1] }
         | '1' '0'            { result = 10 }
         | '1' '1'            { result = 11 }
         | '1' '2'            { result = 12 }
         ;

  d01_13 : d01_12
         | '1' '3'            { result = 13 }
         ;

  d01_23 : '0' positive_digit { result = val[1] }
         | '1' digit          { result = 10 + val[1] }
         | '2' '0'            { result = 20 }
         | '2' '1'            { result = 21 }
         | '2' '2'            { result = 22 }
         | '2' '3'            { result = 23 }
         ;

  d00_23 : '0' '0'
         | d01_23
         ;

  d01_29 : d01_23
         | '2' '4' { result = 24 }
         | '2' '5' { result = 25 }
         | '2' '6' { result = 26 }
         | '2' '7' { result = 27 }
         | '2' '8' { result = 28 }
         | '2' '9' { result = 29 }
         ;

  d01_30 : d01_29
         | '3' '0' { result = 30 }
         ;

  d01_31 : d01_30
         | '3' '1' { result = 31 }
         ;

  d01_59 : d01_29
         | '3' digit { result = 30 + val[1] }
         | '4' digit { result = 40 + val[1] }
         | '5' digit { result = 50 + val[1] }
         ;

  d00_59 : '0' '0'
         | d01_59
         ;

  int1_4 : positive_digit              { result = val[0] }
         | positive_digit digit        { result = 10 * val[0] + val[1] }
         | positive_digit digit digit
         {
           result = val.zip([100,10,1]).reduce(0) { |s,(a,b)| s += a * b }
         }
         | positive_digit digit digit digit
         {
           result = val.zip([1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b }
         }
         ;

  integer : positive_digit { result = val[0] }
          | integer digit  { result = 10 * val[0] + val[1] }
          ;



---- header
require 'strscan'

---- inner

  @defaults = {
    :level => 2,
    :debug => false,
    :warn => true
  }.freeze

  # Input that EDTF-Ruby 5.0 parses differently.
  # Legacy syntax will be accepted only in legacy mode;
  # lossy legacy syntax has no ISO 8601-2 equivalent.
  LEGACY = {
    combined_qualifier: '`?~` is legacy syntax, use `%`',
    parentheses: 'parentheses are legacy syntax, ' \
      'EDTF-Ruby 5.0 qualifies parts from the left instead, e.g. `2004-?06-11`',
    open: '`open` is legacy syntax, use `..`',
    unknown: '`unknown` is legacy syntax, leave the interval end empty',
    unspecified: '`u` is legacy syntax, use `X`',
    masked: 'masked precision (`198x`) is legacy syntax, ' \
      'EDTF-Ruby 5.0 reads it as a decade (`198`) or century (`19`)',
    lowercase_y: '`y` is legacy syntax, use `Y`',
    lowercase_e: '`e` is legacy syntax, use `E`',
    negative_zero: '`-0000` is legacy syntax, use `0000`',
    whitespace: 'spaces around `,` and `..` are legacy syntax, remove them',
    caret: 'calendars and season qualifiers (`^…`) are legacy syntax, ' \
      'EDTF-Ruby 5.0 converts hemispheres to seasons, e.g. `2001-21^southern` ' \
      'to `2001-29`, and drops the rest'
  }.freeze

  CHANGED = {
    unknown_date: 'EDTF-Ruby 5.0 parses this as a date ' \
      'with an unspecified year instead of EDTF::Unknown'
  }.freeze

  class << self; attr_reader :defaults; end

  attr_reader :options, :deprecations

  def initialize(options = {})
    @options = Parser.defaults.merge(options)
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
  # (`type`, `level`, `values` with 1-based months, and bitmask integers
  # for qualified or unspecified digits). Results for legacy syntax
  # carry `legacy: true`.
  def parse!(input)
    @yydebug = debug?
    @src = StringScanner.new(input)
    @deprecations = []
    result = finish(do_parse)
    result[:legacy] = true if legacy?
    @deprecations.uniq!
    warn_deprecations(input) if options[:warn]
    deep_freeze(result)
  end

  # Returns true if the last successful parse used legacy syntax.
  def legacy?
    deprecations.any? { |d| LEGACY.key?(d) }
  end

  def on_error(tid, value, stack)
    raise ArgumentError,
      "failed to parse date: unexpected '#{value}' at #{stack.inspect}"
  end

  def deprecate(name)
    @deprecations << name
  end

  def warn_deprecations(input)
    return if deprecations.empty?
    messages = deprecations.map { |d| LEGACY[d] || CHANGED[d] }
    warn "EDTF #{input.inspect}: #{messages.join('; ')}", category: :deprecated
  end

  PARTS = { year: Bitmask::YEAR, month: Bitmask::MONTH, day: Bitmask::DAY }.freeze

  # The qualifier masks that cover a whole date of each precision.
  WHOLE = [nil, Bitmask::YEAR, Bitmask::YM, Bitmask::YMD].freeze

  # Unspecified digits allowed at level 1, by precision.
  UNSPECIFIED = [
    nil,
    [Bitmask::YYYX, Bitmask::YYXX, Bitmask::XXXX],
    [Bitmask::MONTH, Bitmask::XXXX | Bitmask::MONTH],
    [Bitmask::DAY, Bitmask::MD, Bitmask::YMD]
  ].freeze

  # Rejects days the month cannot have. With leap: true,
  # February 29 is allowed in any year (unspecified years
  # always include a leap year).
  def check_day(year, month, day, leap: false)
    max = Bitmask::MAXDAYS[month - 1]
    max = 28 if month == 2 && !leap && !::Date.gregorian_leap?(year)
    raise ArgumentError, "invalid date (invalid days #{day} for month #{month})" if day > max
    [year, month, day]
  end

  def date(*values, **attributes)
    { type: :date, values: values, **attributes }
  end

  def extend_date(result, *values)
    result.merge(values: result[:values] + values)
  end

  def year(value, level)
    { type: :year, level: level, values: [value] }
  end

  def interval(from, to)
    { type: :interval, values: [from, to] }
  end

  # Qualifies the given parts (a Symbol, an Array, or a mask) of a result,
  # or the whole date if no parts are given.
  def apply_uncertainty(result, uncertainty, parts = nil)
    mask = case parts
      when nil then WHOLE[result[:values].length]
      when Integer then parts
      else Array(parts).sum { |part| PARTS[part] }
      end

    uncertainty.each do |u|
      result[u] = (result[u] || 0) | mask
    end
    result
  end

  alias uoa apply_uncertainty

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

      qualifiers = result.values_at(:uncertain, :approximate).compact
      unless qualifiers.empty?
        level = [level, qualifiers.all?(WHOLE[n]) ? 1 : 2].max
      end

      level
    when :date_time
      0
    when :decade, :century, :set, :list
      2
    when :season
      result.key?(:uncertain) || result.key?(:approximate) || result[:qualifier] ? 2 : 1
    when :interval
      # Open or unknown ends are level 1, unspecified digits level 2.
      result[:values].map { |value|
        !value.is_a?(Hash) ? 1 : value[:unspecified] ? 2 : value[:level]
      }.max
    end
  end

  def deep_freeze(result)
    case result
    when Array then result.each { |member| deep_freeze(member) }
    when Hash then result.each_value { |value| deep_freeze(value) }
    end
    result.freeze
  end

  def next_token
    case
    when @src.eos?
      nil
    # when @src.scan(/\s+/)
      # ignore whitespace
    when @src.scan(/\(/)
      deprecate :parentheses
      ['(', @src.matched]
    # when @src.scan(/\)\?~-/)
    #   [:PUA, [:uncertain!, :approximate!]]
    # when @src.scan(/\)\?-/)
    #   [:PUA, [:uncertain!]]
    # when @src.scan(/\)~-/)
    #   [:PUA, [:approximate!]]
    when @src.scan(/\)/)
      [')', @src.matched]
    when @src.scan(/\[/)
      ['[', @src.matched]
    when @src.scan(/\]/)
      [']', @src.matched]
    when @src.scan(/\{/)
      ['{', @src.matched]
    when @src.scan(/\}/)
      ['}', @src.matched]
    when @src.scan(/T/)
      [:T, @src.matched]
    when @src.scan(/Z/)
      [:Z, @src.matched]
    when @src.scan(/\?~/)
      deprecate :combined_qualifier
      [:UA, [:uncertain, :approximate]]
    when @src.scan(/%/)
      [:UA, [:uncertain, :approximate]]
    when @src.scan(/\?/)
      [:UA, [:uncertain]]
    when @src.scan(/~/)
      [:UA, [:approximate]]
    when @src.scan(/open/i)
      deprecate :open
      [:OPEN, :open]
    when @src.scan(/unkn?own/i) # matches 'unkown' typo too
      deprecate :unknown
      [:UNKNOWN, :unknown]
    when @src.scan(/u/)
      deprecate :unspecified
      [:U, @src.matched]
    when @src.scan(/X/)
      [:U, @src.matched]
    when @src.scan(/x/)
      deprecate :masked
      [:X, @src.matched]
    when @src.scan(/y/i)
      deprecate :lowercase_y if @src.matched == 'y'
      [:LONGYEAR, @src.matched]
    when @src.scan(/e/i)
      deprecate :lowercase_e if @src.matched == 'e'
      [:E, @src.matched]
    when @src.scan(/\+/)
      ['+', @src.matched]
    when @src.scan(/-\(/)
      deprecate :parentheses
      ['-(', @src.matched]
    when @src.scan(/-/)
      ['-', @src.matched]
    when @src.scan(/:/)
      [':', @src.matched]
    when @src.scan(/\//)
      ['/', @src.matched]
    when @src.scan(/\s*\.\.\s*/)
      deprecate :whitespace if @src.matched.length > 2
      [:DOTS, '..']
    when @src.scan(/\s*,\s*/)
      deprecate :whitespace if @src.matched.length > 1
      [',', ',']
    when @src.scan(/\^\w+/)
      deprecate :caret
      ['^', @src.matched[1..-1]]
    when @src.scan(/\d/)
      [@src.matched, @src.matched.to_i]
    else @src.scan(/./)
      [:UNMATCHED, @src.rest]
    end
  end


# -*- racc -*-
