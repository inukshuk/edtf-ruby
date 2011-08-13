# -*- racc -*-

class EDTF::Parser

token T Z PLUS MINUS COLON SLASH D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 UNMATCHED

expect 0

rule

  edtf :
       | level_0_expression
       # | level_1_expression
       # | level_2_expression

  level_0_expression : date
    | date_time
    | level_0_interval

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
    
  long_month : D0 D1 { result = 1  }
             | D0 D3 { result = 3  }
             | D0 D5 { result = 5  }
             | D0 D7 { result = 7  }
             | D0 D8 { result = 8  }
             | D1 D0 { result = 10 }
             | D1 D2 { result = 12 }
  
  short_month : D0 D4 { result = 4  }
              | D0 D6 { result = 6  }
              | D0 D9 { result = 9  }
              | D1 D1 { result = 11 }
  
  february : D0 D2 { result = 2 }
  
  month_day : long_month MINUS d01_31   { result = [val[0], val[2]] }
            | short_month MINUS d01_30  { result = [val[0], val[2]] }
            | february MINUS d01_29     { result = [val[0], val[2]] }
  
  year_month : year MINUS month         { result = [val[0], val[2]] }
  
  year_month_day : year MINUS month_day { result = val[0,1] + val[2] }

  hour : d00_23
  
  minute : d00_59
  
  second : d00_59
  
  level_0_interval : date SLASH date   { result = val[0] ... val[1] }

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
      when @src.scan(/T/)
        @stack << [:T, @src.matched]
      when @src.scan(/Z/)
        @stack << [:Z, @src.matched]
      when @src.scan(/\+/)
        @stack << [:PLUS, @src.matched]
      when @src.scan(/-/)
        @stack << [:MINUS, @src.matched]
      when @src.scan(/:/)
        @stack << [:COLON, @src.matched]
      when @src.scan(/\//)
        @stack << [:SLASH, @src.matched]
      when @src.scan(/\d/)
        @stack << [['D', @src.matched].join.intern, @src.matched]
      else @src.scan(/./)
        @stack << [:UNMATCHED, @src.rest]
      end
    end
  
    @stack
  end


# -*- racc -*-