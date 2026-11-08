# -*- racc -*-
#
# The ISO 8601-2 grammar: EDTF levels 0 to 2 and EDTF-Ruby's extensions.
# Each section below covers one level;
# rules for extensions are marked as such.
#
# Regenerate lib/edtf/iso.rb with `bundle exec rake racc`.

class EDTF::ISO < EDTF::Grammar
  token UA MINUS
  expect 0

rule

  edtf
    : date              # levels 0-2
    | date_time         # level 0
    | interval          # levels 0-2
    | year              # levels 1-2
    | set               # level 2
    ;


  # ---- Dates, seasons, decades and centuries ----

  # A date is made of parts: the year, month and day.
  # Each part may have unspecified digits (X, levels 1-2)
  # and qualifiers on either side (levels 1-2):
  # a qualifier left of a part qualifies only that part,
  # one on its right that part and all parts to its left.
  # A second part from 21 to 41 is a season (levels 1-2);
  # a year of three or two digits is a decade (level 2)
  # or a century (level 0).
  date
    : year_part                    { result = date_of(val[0]) }
    | year_part '-' part           { result = date_of(val[0], val[2]) }
    | year_part '-' part '-' part  { result = date_of(val[0], val[2], val[4]) }
    ;

  year_part
    : ua sign xdigits ua  { result = [val[0], val[1] + val[2], val[3]] }
    ;

  part
    : ua xdigits ua  { result = val }
    ;

  sign
    : /* none */  { result = '' }
    | minus
    ;

  # The minus sign U+2212 or its ASCII stand-in, the hyphen-minus.
  minus
    : '-'
    | MINUS
    ;

  ua
    : /* none */  { result = [] }
    | UA
    ;

  xdigits
    : xdigit
    | xdigits xdigit  { result = val[0] + val[1] }
    ;

  xdigit
    : digit  { result = val[0].to_s }
    | 'X'
    ;


  # ---- Date-times (level 0) ----

  date_time
    : date 'T' time {
        result = date_time(val[0], val[2])
      }
    | date 'T' time offset {
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
    : 'Z'                    { result = 0 }
    | '+' hour ':' minute    { result = offset(1, val[1], val[3]) }
    | minus hour ':' minute  { result = offset(-1, val[1], val[3]) }
    ;


  # ---- Intervals (levels 0-2) ----

  interval
    : interval_date '/' interval_date  { result = interval(val[0], val[2]) }
    | interval_date '/' '..'           { result = interval(val[0], :open) }
    | '..' '/' interval_date           { result = interval(:open, val[2]) }
    | interval_date '/'                { result = interval(val[0], :unknown) }
    | '/' interval_date                { result = interval(:unknown, val[1]) }
    ;

  interval_date
    : date  { result = member(val[0]) }
    ;


  # ---- Years with Y or significant digits (levels 1-2) ----

  # Y marks years with more than four digits (level 1),
  # E an exponent and S significant digits (level 2).
  year
    : 'Y' sign integer {
        result = year(long_year(signed(val[1], val[2])), 1)
      }
    | 'Y' sign integer 'S' integer {
        result = year(long_year(signed(val[1], val[2])), 2, val[4])
      }
    | 'Y' sign integer 'E' integer significant {
        result = year(exponent(signed(val[1], val[2]), val[4]), 2, val[5])
      }
    | date 'S' integer {
        result = significant_year(val[0], val[2])
      }
    ;

  significant
    : /* none */   { result = nil }
    | 'S' integer  { result = val[1] }
    ;


  # ---- Sets and lists (level 2) ----

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
    : date  { result = member(val[0]) }
    | consecutives
    ;

  # Open ends and consecutive dates are plain dates.
  earlier
    : '..' date  { result = plain(val[1]) }
    ;

  later
    : date '..'  { result = plain(val[0]) }
    ;

  consecutives
    : date '..' date  { result = consecutives(val[0], val[2]) }
    ;


  # ---- Digits ----

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
    when @src.scan(/\u2212/)
      [:MINUS, '-']
    when @src.scan(/\.\.|./m)
      [@src.matched, @src.matched]
    end
  end

  PART_NAMES = %i[year month day].freeze

  # Builds a date, season, decade or century from its parts,
  # each [left qualifiers, digits with X, right qualifiers].
  def date_of(*parts)
    digits = parts.map { |part| part[1] }
    negative = digits[0].start_with?('-')
    digits[0] = digits[0].delete_prefix('-')
    raw = digits.map { |d| d.tr('X', '0').to_i }

    if negative && raw[0].zero?
      raise ParseError, "invalid year -#{digits[0]}, use #{digits[0]}"
    end

    case digits.map(&:length)
    when [2], [3]
      epoch(negative ? -raw[0] : raw[0], parts[0])
    when [4, 2]
      if raw[1] > 12 && !digits[1].include?('X')
        season_of(negative ? -raw[0] : raw[0], raw[1], parts)
      else
        calendar_date(negative, digits, raw, parts)
      end
    when [4], [4, 2, 2]
      calendar_date(negative, digits, raw, parts)
    else
      raise ParseError, "invalid date #{digits.join('-')}"
    end
  end

  def calendar_date(negative, digits, raw, parts)
    mask = Bitmask.compute(digits.join.ljust(8, '0'))
    values = mask.zero? ? raw : Bitmask.new(mask).min(raw)
    year, month, day = values

    if month && !fits?(digits[1], 1..12)
      raise ArgumentError, "invalid month #{digits[1]}"
    end

    if day
      unless fits?(digits[2], 1..31)
        raise ArgumentError, "invalid day #{digits[2]}"
      end

      check_day(*values, leap: digits[0].include?('X'))
    end

    values[0] = -year if negative
    result = date(*values)
    result[:unspecified] = mask unless mask.zero?

    parts.each_with_index do |(left, _, right), i|
      qualify(result, left, PART_NAMES[i])
      qualify(result, right, PART_NAMES[0..i])
    end

    result
  end

  # Returns true if a number in range can be written with digits,
  # where X stands for any digit.
  def fits?(digits, range)
    pattern = Regexp.new(digits.gsub('X') { '\\d' })
    range.any? { |n| pattern.match?(format('%02d', n)) }
  end

  def epoch(value, (left, digits, right))
    raise ArgumentError, "invalid year #{digits}" if digits.include?('X')
    type = digits.length == 2 ? :century : :decade
    qualify({ type: type, values: [value] }, left | right)
  end

  # Seasons 21-24 are level 1, 25-41 level 2.
  # Only seasons as a whole can be qualified (season-uncertainty).
  def season_of(year, number, parts)
    (year_left, year_digits, year_right), (left, _, right) = parts

    unless (21..41).cover?(number)
      raise ArgumentError, "invalid month or season #{number}"
    end

    if year_digits.include?('X') || [year_left, year_right, left].any?(&:any?)
      raise ArgumentError, "invalid season #{year_digits}-#{number}"
    end

    extension :season_uncertainty if right.any?
    qualify({ type: :season, values: [year, number] }, right, Bitmask::YM)
  end

  # Interval ends and set members are dates.
  def member(result)
    return result if result[:type] == :date
    raise ArgumentError, "invalid #{result[:type]} in an interval or set"
  end

  def plain(result)
    if member(result).keys != %i[type values]
      raise ArgumentError, 'open ends and consecutive dates must be plain dates'
    end

    result
  end

  def consecutives(from, to)
    unless plain(from)[:values].length == plain(to)[:values].length
      raise ArgumentError, 'consecutive dates must have the same precision'
    end

    [from, to]
  end

  # Date-times have a plain, complete date.
  def date_time(date, time, offset = nil)
    if date.keys != %i[type values] || date[:values].length != 3
      raise ParseError, 'a date-time needs a complete date'
    end

    result = { type: :date_time, values: [*date[:values], *time] }
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

  def signed(sign, number)
    sign.empty? ? number : -number
  end

  # Years with fewer than five digits are written without Y.
  def long_year(year)
    if year.abs < 10000
      raise ParseError, "invalid year Y#{year}, use #{year}"
    end

    year
  end

  # Four-digit years with significant digits, e.g. 1950S2.
  def significant_year(date, significant)
    if date[:type] != :date || date.keys != %i[type values] ||
        date[:values].length != 1
      raise ArgumentError, 'only years can have significant digits'
    end

    year(date[:values][0], 2, significant)
  end

  def list(*values, **open)
    { values: values, **open }
  end
