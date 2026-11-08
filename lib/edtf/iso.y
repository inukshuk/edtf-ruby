# -*- racc -*-
#
# The ISO 8601-2 grammar: EDTF levels 0 to 2 and EDTF-Ruby's extensions.
# Each section below covers one level;
# rules for extensions are marked as such.
#
# Regenerate lib/edtf/iso.rb with `bundle exec rake racc`.

class EDTF::ISO < EDTF::Grammar
  token UA
  expect 0

rule

  edtf
    : date              # level 0
    | date_time         # level 0
    | interval          # levels 0-2
    | qualified_date    # levels 1-2
    | unspecified       # levels 1-2
    | long_year         # level 1
    | season            # level 1
    | exponential_year  # level 2
    | set               # level 2
    ;


  # ---- Level 0: ISO 8601-1 ----

  date
    : year            { result = date(val[0]) }
    | year_month      { result = date(*val[0]) }
    | year_month_day  { result = date(*val[0]) }
    ;

  year
    : d4
    | '-' d4  { result = negative(val[1]) }
    ;

  year_month
    : year '-' month  { result = val.values_at(0, 2) }
    ;

  year_month_day
    : year_month '-' day  { result = check_day(*val[0], val[2]) }
    ;

  month : d01_12 ;
  day   : d01_31 ;

  date_time
    : year_month_day 'T' time {
        result = date_time(val[0], val[2])
      }
    | year_month_day 'T' time offset {
        result = date_time(val[0], val[2], val[3])
      }
    ;

  time
    : hour ':' minute ':' second  { result = val.values_at(0, 2, 4) }
    ;

  hour   : d00_23 ;
  minute : d00_59 ;
  second : d00_59 ;

  offset
    : 'Z'                  { result = 0 }
    | '+' hour ':' minute  { result = offset(1, val[1], val[3]) }
    | '-' hour ':' minute  { result = offset(-1, val[1], val[3]) }
    ;


  # ---- Level 1: qualified dates, unspecified digits, intervals ----

  # A qualifier right of a part qualifies all parts to the left.
  qualified_date
    : qualified_year
    | qualified_year_month
    | qualified_year_month_day
    ;

  qualified_year
    : year UA  { result = qualify(date(val[0]), val[1], :year) }
    ;

  qualified_year_month
    : year '-' month UA {
        result = qualify(date(val[0], val[2]), val[3], [:year, :month])
      }
    | qualified_year '-' month ua {
        result = qualify(extend_date(val[0], val[2]), val[3], [:year, :month])
      }
    ;

  qualified_year_month_day
    : year_month '-' day UA {
        result = qualify(date(*check_day(*val[0], val[2])), val[3])
      }
    | qualified_year_month '-' day ua {
        check_day(*val[0][:values], val[2])
        result = qualify(extend_date(val[0], val[2]), val[3])
      }
    ;

  ua
    : /* none */  { result = [] }
    | UA
    ;

  # Unspecified digits from the right are level 1,
  # the other forms level 2.
  unspecified
    : 'X' 'X' 'X' 'X' {
        result = date(0, unspecified: Bitmask::XXXX)
      }
    | year '-' xx {
        result = date(val[0], 1, unspecified: Bitmask::MONTH)
      }
    | year '-' xx '-' xx {
        result = date(val[0], 1, 1, unspecified: Bitmask::MD)
      }
    | year '-' xx '-' day {
        result = date(val[0], 1, val[4], unspecified: Bitmask::MONTH)
      }
    | year_month '-' xx {
        result = date(*val[0], 1, unspecified: Bitmask::DAY)
      }
    | x_year {
        year, mask = val[0]
        result = date(year, unspecified: mask)
      }
    | x_year '-' month {
        year, mask = val[0]
        result = date(year, val[2], unspecified: mask)
      }
    | x_year '-' month '-' day {
        year, mask = val[0]
        check_day(year, val[2], val[4], leap: true)
        result = date(year, val[2], val[4], unspecified: mask)
      }
    | x_year '-' month '-' xx {
        year, mask = val[0]
        result = date(year, val[2], 1, unspecified: mask | Bitmask::DAY)
      }
    | x_year '-' xx '-' day {
        year, mask = val[0]
        result = date(year, 1, val[4], unspecified: mask | Bitmask::MONTH)
      }
    | x_year '-' xx '-' xx {
        year, mask = val[0]
        result = date(year, 1, 1, unspecified: mask | Bitmask::MD)
      }
    ;

  # A year with unspecified digits and its mask.
  x_year
    : x_digits
    | '-' x_digits  { result = [-val[1][0], val[1][1]] }
    ;

  x_digits
    : digit digit digit 'X' {
        result = [number(val[0, 3]) * 10, Bitmask::YYYX]
      }
    | digit digit 'X' 'X' {
        result = [number(val[0, 2]) * 100, Bitmask::YYXX]
      }
    ;

  xx : 'X' 'X' ;

  interval
    : interval_date '/' interval_date  { result = interval(val[0], val[2]) }
    | interval_date '/' '..'           { result = interval(val[0], :open) }
    | '..' '/' interval_date           { result = interval(:open, val[2]) }
    | interval_date '/'                { result = interval(val[0], :unknown) }
    | '/' interval_date                { result = interval(:unknown, val[1]) }
    ;

  interval_date
    : date
    | qualified_date
    | unspecified
    ;

  long_year
    : 'Y' integer      { result = year(long_year(val[1]), 1) }
    | 'Y' '-' integer  { result = year(-long_year(val[2]), 1) }
    ;

  season
    : year '-' season_number {
        result = season(val[0], val[2])
      }
    # Extension: season-uncertainty
    | year '-' season_number UA {
        extension :season_uncertainty
        result = season(val[0], val[2], val[3])
      }
    ;

  season_number
    : '2' '1'  { result = 21 }
    | '2' '2'  { result = 22 }
    | '2' '3'  { result = 23 }
    | '2' '4'  { result = 24 }
    ;


  # ---- Level 2: exponential years, sets and lists ----

  exponential_year
    : 'Y' integer 'E' integer {
        result = year(exponent(val[1], val[3]), 2)
      }
    | 'Y' '-' integer 'E' integer {
        result = year(exponent(-val[2], val[4]), 2)
      }
    ;

  set
    : '[' list ']'  { result = { type: :set, **val[1] } }
    | '{' list '}'  { result = { type: :list, **val[1] } }
    ;

  list
    : members              { result = list(*val[0]) }
    | members ',' later    { result = list(*val[0], val[2], later: true) }
    | later                { result = list(val[0], later: true) }
    | earlier              { result = list(val[0], earlier: true) }
    | earlier ',' members  { result = list(val[0], *val[2], earlier: true) }
    | earlier ',' later {
        result = list(val[0], val[2], earlier: true, later: true)
      }
    | earlier ',' members ',' later {
        result = list(val[0], *val[2], val[4], earlier: true, later: true)
      }
    ;

  members
    : member              { result = [val[0]] }
    | members ',' member  { result = val[0] + [val[2]] }
    ;

  member
    : date
    | qualified_date
    | unspecified
    | consecutives
    ;

  earlier
    : '..' date  { result = val[1] }
    ;

  later
    : year '..'            { result = date(val[0]) }
    | year_month '..'      { result = date(*val[0]) }
    | year_month_day '..'  { result = date(*val[0]) }
    ;

  consecutives
    : year '..' year {
        result = [date(val[0]), date(val[2])]
      }
    | year_month '..' year_month {
        result = [date(*val[0]), date(*val[2])]
      }
    | year_month_day '..' year_month_day {
        result = [date(*val[0]), date(*val[2])]
      }
    ;


  # ---- Digits ----

  d4
    : digit digit digit digit  { result = number(val) }
    ;

  integer
    : positive_digit
    | integer digit  { result = 10 * val[0] + val[1] }
    ;

  digit
    : '0'
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

  d01_31
    : '0' positive_digit  { result = val[1] }
    | '1' digit           { result = 10 + val[1] }
    | '2' digit           { result = 20 + val[1] }
    | '3' '0'             { result = 30 }
    | '3' '1'             { result = 31 }
    ;

  d00_23
    : '0' digit  { result = val[1] }
    | '1' digit  { result = 10 + val[1] }
    | '2' d0_3   { result = 20 + val[1] }
    ;

  d00_59
    : d0_5 digit  { result = 10 * val[0] + val[1] }
    ;

  d0_3 : '0' | '1' | '2' | '3' ;
  d0_5 : d0_3 | '4' | '5' ;

end

---- inner

  QUALIFIERS = {
    '?' => [:uncertain],
    '~' => [:approximate],
    '%' => [:uncertain, :approximate]
  }.freeze

  # Digits are tokens with their value, qualifiers UA tokens;
  # every other character is a token of its own.
  # Characters the grammar does not know are syntax errors.
  def next_token
    case
    when @src.eos?
      nil
    when @src.scan(/\d/)
      [@src.matched, @src.matched.to_i]
    when @src.scan(/[?~%]/)
      [:UA, QUALIFIERS[@src.matched]]
    when @src.scan(/\.\.|./m)
      [@src.matched, @src.matched]
    end
  end

  def negative(year)
    raise ParseError, 'invalid year -0000, use 0000' if year.zero?
    -year
  end

  def date_time(date, time, offset = nil)
    result = { type: :date_time, values: [*date, *time] }
    result[:offset] = offset unless offset.nil?
    result
  end

  # Returns the offset in minutes.
  # Offsets range from -14:00 to +14:00; -00:00 is invalid.
  def offset(sign, hours, minutes)
    offset = 60 * hours + minutes

    if offset > 840 || (sign < 0 && offset.zero?)
      sign = sign < 0 ? '-' : '+'
      raise ArgumentError,
        format('invalid offset %s%02d:%02d', sign, hours, minutes)
    end

    sign * offset
  end

  # Years with fewer than five digits are written without Y.
  def long_year(year)
    raise ParseError, "invalid year Y#{year}, use #{year}" if year < 10000
    year
  end

  def season(year, season, qualifiers = [])
    qualify({ type: :season, values: [year, season] }, qualifiers, Bitmask::YM)
  end

  def list(*values, **open)
    { values: values, **open }
  end
