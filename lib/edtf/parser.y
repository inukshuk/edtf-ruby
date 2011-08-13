# -*- racc -*-

class EDTF::Parser

token T Z PLUS MINUS COLON SLASH D0 D1 D2 D3 D4 D5 D6 D7 D8 D9

expect 0

rule

  edtf :
       | l0_expression
       | l1_expression
       | l2_expression

# Level 0

  l0_expression : date
                | date_time
                | l0_interval

  date : positive_date
       | negative_date

  positive_date : year
                | year_month
                | year_month_day
                
  negative_date =  MINUS positive_date


  date_time = date T time

  time : base_time
       | base_time zone_offset
  
  base_time : hour COLON minute COLON second
            | midnight
  
  midnight : D2 D4 COLON D0 COLON D0
  
  zone_offset : Z
              | sign zone_offset_hour
              | PLUS D0 D0 COLON D0 D0
              
              
  zone_offset_hour : one_thru_13 COLON minute
                   | D1 D4 COLON D0 D0
                   | D0 D0 COLON one_thru_59
  
  
  l0_interval : date SLASH date
    
  sign : PLUS
       | MINUS
  
  one_thru_13 : D0 digit
              | D1 D0
              | D1 D1
              | D1 D2
              | D1 D3
  
  one_through_59 :

  digit : D1
        | D2
        | D3
        | D4
        | D5
        | D6
        | D7
        | D8
        | D9

  digit0 : D0
         | digit



---- header
require 'strscan'

---- inner

  def parse(input)
    @yydebug = options[:debug]
    scan(input)
    do_parse
  end
  
  def next_token
    @stack.shift
  end

  def on_error(tid, val, vstack)
    warn "Failed to parse extended date time %s (%s) %s" % [val.inspect, token_to_str(tid) || '?', vstack.inspect])
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
      when @src.scan(/,?\s+and\s+/io)
      end
    end
  
    push_word
    @stack
  end


# -*- racc -*-