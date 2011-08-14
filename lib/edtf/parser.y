# -*- racc -*-

class EDTF::Parser

token T Z PLUS MINUS COLON SLASH D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 LP RP
  UNCERTAIN APPROXIMATE UNSPECIFIED UNKNOWN OPEN LONGYEAR CARET UNMATCHED

expect 0

rule

  edtf : level_0_expression
       | level_1_expression
       | level_2_expression
       # | { result = Date.today }


  # ---- Level 0 / ISO 8601 Rules ----
  
  level_0_expression : date
                     | date_time
                     # | level_0_interval # --> level_1_interval

  date : positive_date
       | negative_date

  positive_date : year           { result = Date.new(val[0]) }
                | year_month     { result = Date.new(*val.flatten) }
                | year_month_day { result = Date.new(*val.flatten) }
                
  negative_date :  MINUS positive_date { result = Date.new(-1 * val[1].year, val[1].month, val[1].day) }


  date_time : date T time { result = DateTime.new(val[0].year, val[0].month, val[0].day, *val[2]) }

  time : base_time
       | base_time zone_offset { result = val.flatten }
  
  base_time : hour COLON minute COLON second { result = [val[0], val[2], val[4]] }
            | midnight
  
  midnight : D2 D4 COLON D0 D0 COLON D0 D0   { result = [24, 0, 0] }
  
  zone_offset : Z                            { result = 0 }
              | MINUS zone_offset_hour       { result = -1 * val[1] }
              | PLUS positive_zone_offset    { result = val[1] }

  positive_zone_offset : zone_offset_hour
                       | D0 D0 COLON D0 D0   { result = 0 }
              
              
  zone_offset_hour : d01_13 COLON minute     { result = Rational(val[0] * 60 + val[2], 1440) }
                   | D1 D4 COLON D0 D0       { result = Rational(840, 1440) }
                   | D0 D0 COLON d01_59      { result = Rational(val[3], 1440) }
  
  year : digit digit digit digit { result = val.zip([1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }
  
  month : d01_12
      
  year_month : year MINUS month         { result = [val[0], val[2]] }
  
  # We raise an exception if there are two many days for the month, but
  # do not consider leap years, as the EDTF BNF did not either.
  # NB: an exception will be raised regardless, because the Ruby Date
  # implementation calculates leap years.
  year_month_day : year_month MINUS d01_31 { result = val[0] << val[2]; raise ArgumentError, "invalid date (invalid days #{result[2]} for month #{result[1]})" if result[2] > 31 || (result[2] > 30 && [2,4,6,9,11].include?(result[1])) || (result[2] > 29 && result[1] == 2) }

  hour : d00_23
  
  minute : d00_59
  
  second : d00_59
  
  # covered by level_1_interval
  # level_0_interval : date SLASH date   { result = Interval.new(val[0], val[1]) }

  # ---- Level 1 Extension Rules ----
  
  level_1_expression : uncertain_or_approximate_date 
                     | unspecified 
                     | level_1_interval
                     | long_year_simple
                     | season
  

  uncertain_or_approximate_date : date uncertain_or_approximate { result = val[0]; val[1].each { |m| result.send(m) } }
  
  uncertain_or_approximate : UNCERTAIN              { result = [:uncertain!] }
                           | APPROXIMATE            { result = [:approximate!] }
                           | UNCERTAIN APPROXIMATE  { result = [:uncertain!, :approximate!] }
  

  unspecified : unspecified_year
              | unspecified_month
              | unspecified_day
              | unspecified_day_and_month
  
  unspecified_year : digit digit digit UNSPECIFIED       { result = Date.new(val[0,3].zip([1000,100,10]).reduce(0) { |s,(a,b)| s += a * b }); result.unspecified.year[3] = true }
                   | digit digit UNSPECIFIED UNSPECIFIED { result = Date.new(val[0,2].zip([1000,100]).reduce(0) { |s,(a,b)| s += a * b }); result.unspecified.year[2,2] = true }
  
  unspecified_month : year MINUS UNSPECIFIED UNSPECIFIED { result = Date.new(val[0]).unspecified!(:month) }
  
  unspecified_day : year_month MINUS UNSPECIFIED UNSPECIFIED { result = Date.new(*val[0]).unspecified!(:day) }
  
  unspecified_day_and_month : year MINUS UNSPECIFIED UNSPECIFIED MINUS UNSPECIFIED UNSPECIFIED { result = Date.new(val[0]).unspecified!([:day,:month]) }


  level_1_interval : level_1_start SLASH level_1_end { result = Interval.new(val[0], val[2]) }

  level_1_start : date
                | uncertain_or_approximate_date
                | UNKNOWN                        { result = :unknown }
                
  level_1_end : level_1_start
              | OPEN                             { result = :open }


  long_year_simple : LONGYEAR long_year          { result = Date.new(val[1]) }
                   | LONGYEAR MINUS long_year    { result = Date.new(-1 * val[2]) }
            
  long_year : positive_digit digit digit digit digit { result = val.zip([10000,1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }
            | long_year digit { result = 10 * val[0] + val[1] }


  season : year MINUS season_number { result = Date.new(val[0]); result.season = val[2] }

  season_number : D2 D1 { result = 21 }
                | D2 D2 { result = 22 }
                | D2 D3 { result = 23 }
                | D2 D4 { result = 24 }


  # ---- Level 2 Extension Rules ----
  
  level_2_expression : season_qualified
                     # | internal_uncertain_or_approximate
                     # | internal_unspecified
                     # | choice_list
                     # | inclusive_list
                     # | masked_precision
                     # | level_2_interval
                     # | date_and_calendar
                     # | long_year_scientific
  

  season_qualified : season CARET { result = val[0]; result.qualifier = val[1] }

  # ---- Auxiliary Rules ----

  digit : D0             { result = 0 }
        | positive_digit
        
  positive_digit : D1 { result = 1 }
                 | D2 { result = 2 }
                 | D3 { result = 3 }
                 | D4 { result = 4 }
                 | D5 { result = 5 }
                 | D6 { result = 6 }
                 | D7 { result = 7 }
                 | D8 { result = 8 }
                 | D9 { result = 9 }

  d01_12 : D0 positive_digit { result = val[1] }
         | D1 D0             { result = 10 }
         | D1 D1             { result = 11 }
         | D1 D2             { result = 12 }

  d01_13 : d01_12
         | D1 D3             { result = 13 }
         
  d01_23 : D0 positive_digit { result = val[1] }
         | D1 digit          { result = 10 + val[1] }
         | D2 D0             { result = 20 }
         | D2 D1             { result = 21 }
         | D2 D2             { result = 22 }
         | D2 D3             { result = 23 }

  d00_23 : D0 D0             { result = 0  }
         | d01_23

  d01_29 : d01_23
         | D2 D4             { result = 24 }
         | D2 D5             { result = 25 }
         | D2 D6             { result = 26 }
         | D2 D7             { result = 27 }
         | D2 D8             { result = 28 }
         | D2 D9             { result = 29 }

  d01_30 : d01_29
         | D3 D0             { result = 30 }

  d01_31 : d01_30
         | D3 D1             { result = 31 }
  
  d01_59 : d01_29
         | D3 digit          { result = 30 + val[1] }
         | D4 digit          { result = 40 + val[1] }
         | D5 digit          { result = 50 + val[1] }
         
  d00_59 : D0 D0             { result = 0 }
         | d01_59


---- header
require 'strscan'

---- inner

  def parse(input)
    @yydebug = !!ENV['DEBUG']
    scan(input)
    do_parse
  end
  
  def next_token
    @stack.shift
  end

  def on_error(tid, val, vstack)
    warn "failed to parse extended date time %s (%s) %s" % [val.inspect, token_to_str(tid) || '?', vstack.inspect]
  end

  def scan(input)
    @src = StringScanner.new(input)
    @stack = []
    tokenize
  end

  private

  def tokenize
    until @src.eos?
      case
      when @src.scan(/\(/)
        @stack << [:LP, @src.matched]
      when @src.scan(/\)/)
        @stack << [:RP, @src.matched]
      when @src.scan(/T/)
        @stack << [:T, @src.matched]
      when @src.scan(/Z/)
        @stack << [:Z, @src.matched]
      when @src.scan(/\?/)
        @stack << [:UNCERTAIN, @src.matched]
      when @src.scan(/~/)
        @stack << [:APPROXIMATE, @src.matched]
      when @src.scan(/open/i)
        @stack << [:OPEN, @src.matched]
      when @src.scan(/unkn?own/i) # matches 'unkown' typo too
        @stack << [:UNKNOWN, @src.matched]
      when @src.scan(/u/)
        @stack << [:UNSPECIFIED, @src.matched]
      when @src.scan(/y/)
        @stack << [:LONGYEAR, @src.matched]
      when @src.scan(/\+/)
        @stack << [:PLUS, @src.matched]
      when @src.scan(/-/)
        @stack << [:MINUS, @src.matched]
      when @src.scan(/:/)
        @stack << [:COLON, @src.matched]
      when @src.scan(/\//)
        @stack << [:SLASH, @src.matched]
      when @src.scan(/\^\w+/)
        @stack << [:CARET, @src.matched[1..-1]]
      when @src.scan(/\d/)
        @stack << [['D', @src.matched].join.intern, @src.matched]
      else @src.scan(/./)
        @stack << [:UNMATCHED, @src.rest]
      end
    end
  
    @stack
  end


# -*- racc -*-