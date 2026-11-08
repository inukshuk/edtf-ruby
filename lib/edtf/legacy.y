# -*- racc -*-
#
# The legacy grammar: the syntax of the EDTF draft.
# Legacy syntax is recorded as a deprecation (see EDTF::Parser::LEGACY).
#
# Regenerate lib/edtf/legacy.rb with `bundle exec rake racc`.

class EDTF::Legacy < EDTF::Grammar
  token T Z E X U UNKNOWN OPEN LONGYEAR UNMATCHED DOTS UA

  expect 0

rule

  edtf
    : level_0_expression
    | level_1_expression
    | level_2_expression
    ;

  # ---- Level 0 / ISO 8601 Rules ----

  # NB: level 0 intervals are covered by the level 1 interval rules
  level_0_expression
    : date
    | date_time
    ;

  date
    : year            { result = date(val[0]) }
    | year_month      { result = date(*val[0]) }
    | year_month_day  { result = date(*val[0]) }
    ;

  date_time
    : date T time {
        year, month, day = val[0][:values]
        deprecate :partial_date_time if day.nil?
        values = [year, month || 1, day || 1, *val[2][0, 3]]
        result = { type: :date_time, values: values }
        result[:offset] = val[2][3] if val[2].length > 3
      }
    ;

  time
    : base_time
    | base_time zone_offset  { result = val.flatten }
    ;

  base_time
    : hour ':' minute ':' second  { result = val.values_at(0, 2, 4) }
    | midnight
    ;

  midnight
    : '2' '4' ':' '0' '0' ':' '0' '0' {
        deprecate :midnight
        result = [24, 0, 0]
      }
    ;

  zone_offset
    : Z                         { result = 0 }
    | '-' zone_offset_hour      { result = -1 * val[1] }
    | '+' positive_zone_offset  { result = val[1] }
    ;

  positive_zone_offset
    : zone_offset_hour
    | '0' '0' ':' '0' '0'  { result = 0 }
    ;

  zone_offset_hour
    : d01_13 ':' minute    { result = val[0] * 60 + val[2] }
    | '1' '4' ':' '0' '0'  { result = 840 }
    | '0' '0' ':' d01_59   { result = val[3] }
    ;

  year
    : positive_year
    | '-' positive_year {
        result = -val[1]
        deprecate :negative_zero if result.zero?
      }
    ;

  positive_year
    : digit digit digit digit  { result = number(val) }
    ;

  month : d01_12 ;
  day   : d01_31 ;

  year_month
    : year '-' month  { result = [val[0], val[2]] }
    ;

  year_month_day
    : year_month '-' day  { result = check_day(*val[0], val[2]) }
    ;

  hour   : d00_23 ;
  minute : d00_59 ;
  second : d00_59 ;

  # ---- Level 1 Extension Rules ----

  # NB: Uncertain/approximate Dates are covered by the Level 2 rules
  level_1_expression
    : unknown
    | unspecified
    | level_1_interval
    | long_year_simple
    | season
    ;

  unknown
    : U U U U {
        result = date(0, unspecified: Bitmask::XXXX)
      }
    ;

  unspecified
    : unspecified_year  { result = date(val[0][0], unspecified: val[0][1]) }
    | unspecified_month
    | unspecified_day
    | unspecified_day_and_month
    ;

  unspecified_year
    : positive_unspecified_year
    | '-' positive_unspecified_year {
        result = val[1]
        result[0] = -result[0]
      }
    ;

  positive_unspecified_year
    : digit digit digit U  { result = [number(val[0, 3]) * 10, Bitmask::YYYX] }
    | digit digit U U      { result = [number(val[0, 2]) * 100, Bitmask::YYXX] }
    ;

  unspecified_month
    : year '-' U U  { result = date(val[0], 1, unspecified: Bitmask::MONTH) }
    ;

  unspecified_day
    : year_month '-' U U {
        result = date(*val[0], 1, unspecified: Bitmask::DAY)
      }
    ;

  unspecified_day_and_month
    : year '-' U U '-' U U {
        result = date(val[0], 1, 1, unspecified: Bitmask::MD)
      }
    ;

  level_1_interval
    : level_1_interval_closed
    | level_1_interval_open
    | level_1_interval_unknown
    ;

  level_1_interval_closed
    : level_1_start '/' level_1_end  { result = interval(val[0], val[2]) }
    ;

  level_1_interval_open
    : level_1_interval_open_start
    | level_1_interval_open_end
    ;

  level_1_interval_open_start
    : open_start_or_end '/' level_1_end  { result = interval(:open, val[2]) }
    ;

  level_1_interval_open_end
    : level_1_start '/' open_start_or_end  { result = interval(val[0], :open) }
    ;

  open_start_or_end
    : OPEN
    | DOTS
    ;

  level_1_interval_unknown
    : level_1_interval_empty_start
    | level_1_interval_empty_end
    | level_1_interval_unknown_start
    | level_1_interval_unknown_end
    ;

  level_1_interval_empty_start
    : '/' level_1_end  { result = interval(:unknown, val[1]) }
    ;

  level_1_interval_empty_end
    : level_1_start '/'  { result = interval(val[0], :unknown) }
    ;

  level_1_interval_unknown_start
    : UNKNOWN '/' level_1_end  { result = interval(:unknown, val[2]) }
    ;

  level_1_interval_unknown_end
    : level_1_start '/' UNKNOWN  { result = interval(val[0], :unknown) }
    ;

  level_1_start
    : date
    | partial_uncertain_or_approximate
    | unspecified
    | partial_unspecified
    ;

  level_1_end : level_1_start ;

  long_year_simple
    : LONGYEAR long_year      { result = year(val[1], 1) }
    | LONGYEAR '-' long_year  { result = year(-val[2], 1) }
    ;

  long_year
    : positive_digit digit digit digit digit  { result = number(val) }
    | long_year digit                         { result = 10 * val[0] + val[1] }
    ;

  # Qualified seasons are an extension (season-uncertainty).
  season
    : year '-' season_number ua {
        extension :season_uncertainty unless val[3].empty?
        season = { type: :season, values: [val[0], val[2]] }
        result = qualify(season, val[3], Bitmask::YM)
      }
    ;

  season_number
    : '2' '1'  { result = 21 }
    | '2' '2'  { result = 22 }
    | '2' '3'  { result = 23 }
    | '2' '4'  { result = 24 }
    ;


  # ---- Level 2 Extension Rules ----

  # NB: Level 2 Intervals are covered by the Level 1 Interval rules.
  level_2_expression
    : season_qualified
    | partial_uncertain_or_approximate
    | partial_unspecified
    | choice_list
    | inclusive_list
    | masked_precision
    | date_and_calendar
    | long_year_scientific
    ;

  season_qualified
    : season '^'  { result = val[0]; result[:qualifier] = val[1] }
    ;

  long_year_scientific
    : long_year_simple E integer {
        result = year(exponent(val[0][:values][0], val[2]), 2)
      }
    | LONGYEAR int1_4 E integer {
        result = year(exponent(val[1], val[3]), 2)
      }
    | LONGYEAR '-' int1_4 E integer {
        result = year(exponent(-val[2], val[4]), 2)
      }
    ;

  date_and_calendar
    : date '^'  { result = val[0]; result[:calendar] = val[1] }
    ;

  masked_precision
    : digit digit digit X {
        result = { type: :decade, values: [number(val[0, 3])], level: 2 }
      }
    | digit digit X X {
        result = { type: :century, values: [number(val[0, 2])], level: 2 }
      }
    ;

  choice_list
    : '[' list ']'  { result = { type: :set, **val[1] } }
    ;

  inclusive_list
    : '{' list '}'  { result = { type: :list, **val[1] } }
    ;

  list
    : earlier {
        result = { values: [val[0]], earlier: true }
      }
    | earlier ',' list_elements ',' later {
        values = [val[0], *val[2], val[4]]
        result = { values: values, earlier: true, later: true }
      }
    | earlier ',' list_elements {
        result = { values: [val[0], *val[2]], earlier: true }
      }
    | earlier ',' later {
        result = { values: [val[0], val[2]], earlier: true, later: true }
      }
    | list_elements ',' later {
        result = { values: [*val[0], val[2]], later: true }
      }
    | list_elements {
        result = { values: val[0] }
      }
    | later {
        result = { values: [val[0]], later: true }
      }
    ;

  list_elements
    : list_element                    { result = [val[0]] }
    | list_elements ',' list_element  { result = val[0] + [val[2]] }
    ;

  list_element
    : atomic
    | consecutives
    ;

  atomic
    : date
    | partial_uncertain_or_approximate
    | unspecified
    ;

  earlier
    : DOTS date  { result = val[1] }
    ;

  later
    : year_month_day DOTS  { result = date(*val[0]) }
    | year_month DOTS      { result = date(*val[0]) }
    | year DOTS            { result = date(val[0]) }
    ;

  consecutives
    : year_month_day DOTS year_month_day {
        result = [date(*val[0]), date(*val[2])]
      }
    | year_month DOTS year_month {
        result = [date(*val[0]), date(*val[2])]
      }
    | year DOTS year {
        result = [date(val[0]), date(val[2])]
      }
    ;

  partial_unspecified
    : unspecified_year '-' month '-' day {
        check_day(val[0][0], val[2], val[4], leap: true)
        result = date(val[0][0], val[2], val[4], unspecified: val[0][1])
      }
    | unspecified_year '-' month {
        result = date(val[0][0], val[2], unspecified: val[0][1])
      }
    | unspecified_year '-' U U '-' day {
        mask = val[0][1] | Bitmask::MONTH
        result = date(val[0][0], 1, val[5], unspecified: mask)
      }
    | unspecified_year '-' U U '-' U U {
        result = date(val[0][0], 1, 1, unspecified: val[0][1] | Bitmask::MD)
      }
    | unspecified_year '-' month '-' U U {
        mask = val[0][1] | Bitmask::DAY
        result = date(val[0][0], val[2], 1, unspecified: mask)
      }
    | year '-' U U '-' day {
        result = date(val[0], 1, val[5], unspecified: Bitmask::MONTH)
      }
    ;

  partial_uncertain_or_approximate
    : pua_base
    | '(' pua_base ')' UA  { result = qualify(val[1], val[3]) }
    ;

  pua_base
    : pua_year
    | pua_year_month  { result = val[0][0] }
    | pua_year_month_day
    ;

  pua_year
    : year UA  { result = qualify(date(val[0]), val[1], :year) }
    ;

  pua_year_month
    : pua_year '-' month ua {
        result = [qualify(extend_date(val[0], val[2]), val[3], [:month, :year])]
      }
    | year '-' month UA {
        result = [qualify(date(val[0], val[2]), val[3], [:year, :month])]
      }
    | year '-(' month ')' UA {
        result = [qualify(date(val[0], val[2]), val[4], [:month]), true]
      }
    | pua_year '-(' month ')' UA {
        result = [qualify(extend_date(val[0], val[2]), val[4], [:month]), true]
      }
    ;

  pua_year_month_day
    : pua_year_month '-' day ua {
        parts = val[0][1] ? [:day] : nil
        result = qualify(extend_date(val[0][0], val[2]), val[3], parts)
      }
    | pua_year_month '-(' day ')' UA {
        result = qualify(extend_date(val[0][0], val[2]), val[4], [:day])
      }
    | year '-(' month ')' UA day ua {
        result = qualify(date(val[0], val[2], val[5]), val[4], :month)
        result = qualify(result, val[6], :day)
      }
    | year_month '-' day UA {
        result = qualify(date(val[0][0], val[0][1], val[2]), val[3])
      }
    | year_month '-(' day ')' UA {
        result = qualify(date(val[0][0], val[0][1], val[2]), val[4], [:day])
      }
    | year '-(' month '-' day ')' UA {
        result = qualify(date(val[0], val[2], val[4]), val[6], [:month, :day])
      }
    | year '-(' month '-(' day ')' UA ')' UA {
        result = date(val[0], val[2], val[4])
        result = qualify(result, val[6], [:day])
        result = qualify(result, val[8], [:month, :day])
      }
    | pua_year '-(' month '-' day ')' UA {
        result = extend_date(val[0], val[2], val[4])
        result = qualify(result, val[6], [:month, :day])
      }
    | pua_year '-(' month '-(' day ')' UA ')' UA {
        result = extend_date(val[0], val[2], val[4])
        result = qualify(result, val[6], [:day])
        result = qualify(result, val[8], [:month, :day])
      }
    ;

  ua
    : /* none */  { result = [] }
    | UA
    ;


  # ---- Auxiliary Rules ----

  digit
    : '0'  { result = 0 }
    | positive_digit
    ;

  positive_digit
    : '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
    ;

  d01_12
    : '0' positive_digit  { result = val[1] }
    | '1' '0'             { result = 10 }
    | '1' '1'             { result = 11 }
    | '1' '2'             { result = 12 }
    ;

  d01_13
    : d01_12
    | '1' '3'  { result = 13 }
    ;

  d01_23
    : '0' positive_digit  { result = val[1] }
    | '1' digit           { result = 10 + val[1] }
    | '2' '0'             { result = 20 }
    | '2' '1'             { result = 21 }
    | '2' '2'             { result = 22 }
    | '2' '3'             { result = 23 }
    ;

  d00_23
    : '0' '0'
    | d01_23
    ;

  d01_29
    : d01_23
    | '2' '4'  { result = 24 }
    | '2' '5'  { result = 25 }
    | '2' '6'  { result = 26 }
    | '2' '7'  { result = 27 }
    | '2' '8'  { result = 28 }
    | '2' '9'  { result = 29 }
    ;

  d01_30
    : d01_29
    | '3' '0'  { result = 30 }
    ;

  d01_31
    : d01_30
    | '3' '1'  { result = 31 }
    ;

  d01_59
    : d01_29
    | '3' digit  { result = 30 + val[1] }
    | '4' digit  { result = 40 + val[1] }
    | '5' digit  { result = 50 + val[1] }
    ;

  d00_59
    : '0' '0'
    | d01_59
    ;

  int1_4
    : positive_digit                    { result = val[0] }
    | positive_digit digit              { result = number(val) }
    | positive_digit digit digit        { result = number(val) }
    | positive_digit digit digit digit  { result = number(val) }
    ;

  integer
    : positive_digit  { result = val[0] }
    | integer digit   { result = 10 * val[0] + val[1] }
    ;

end

---- inner

  def parse(input, debug: false)
    @set = false
    super
  end

  def next_token
    case
    when @src.eos?
      nil
    when @src.scan(/\(/)
      deprecate :parentheses
      ['(', @src.matched]
    when @src.scan(/\)/)
      [')', @src.matched]
    when @src.scan(/[\[{]/)
      @set = true
      [@src.matched, @src.matched]
    when @src.scan(/[\]}]/)
      @set = false
      [@src.matched, @src.matched]
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
    # Spaces around `..` and `,` are allowed in sets only.
    when @set && @src.scan(/ *\.\. */)
      deprecate :whitespace if @src.matched.length > 2
      [:DOTS, '..']
    when @set && @src.scan(/ *, */)
      deprecate :whitespace if @src.matched.length > 1
      [',', ',']
    when @src.scan(/\.\./)
      [:DOTS, '..']
    when @src.scan(/,/)
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
