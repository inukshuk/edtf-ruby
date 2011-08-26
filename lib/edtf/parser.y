# -*- racc -*-

class EDTF::Parser

token T Z E X PLUS UNSPECIFIED UNKNOWN OPEN LONGYEAR UNMATCHED DOTS IUA

expect 0

rule

  edtf : level_0_expression
       | level_1_expression
       | level_2_expression

  # ---- Level 0 / ISO 8601 Rules ----
  
  # NB: level 0 intervals are covered by the level 1 interval rules
  level_0_expression : date
                     | date_time

  date : positive_date
       | negative_date

  positive_date : year           { result = Date.new(val[0]); result.precision = :year }
                | year_month     { result = Date.new(*val.flatten); result.precision = :month }
                | year_month_day { result = Date.new(*val.flatten); result.precision = :day }
        
  negative_date :  '-' positive_date { result = -val[1] }


  date_time : date T time { result = DateTime.new(val[0].year, val[0].month, val[0].day, *val[2]) }

  time : base_time
       | base_time zone_offset { result = val.flatten }
  
  base_time : hour ':' minute ':' second { result = [val[0], val[2], val[4]] }
            | midnight
  
  midnight : '2' '4' ':' '0' '0' ':' '0' '0'   { result = [24, 0, 0] }
  
  zone_offset : Z                            { result = 0 }
              | '-' zone_offset_hour       { result = -1 * val[1] }
              | PLUS positive_zone_offset    { result = val[1] }

  positive_zone_offset : zone_offset_hour
                       | '0' '0' ':' '0' '0'   { result = 0 }
              
              
  zone_offset_hour : d01_13 ':' minute     { result = Rational(val[0] * 60 + val[2], 1440) }
                   | '1' '4' ':' '0' '0'       { result = Rational(840, 1440) }
                   | '0' '0' ':' d01_59      { result = Rational(val[3], 1440) }
  
  year : digit digit digit digit { result = val.zip([1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }
  
  month : d01_12
      
  year_month : year '-' month         { result = [val[0], val[2]] }
  
  # We raise an exception if there are two many days for the month, but
  # do not consider leap years, as the EDTF BNF did not either.
  # NB: an exception will be raised regardless, because the Ruby Date
  # implementation calculates leap years.
  year_month_day : year_month '-' d01_31 { result = val[0] << val[2]; raise ArgumentError, "invalid date (invalid days #{result[2]} for month #{result[1]})" if result[2] > 31 || (result[2] > 30 && [2,4,6,9,11].include?(result[1])) || (result[2] > 29 && result[1] == 2) }

  hour : d00_23
  
  minute : d00_59
  
  second : d00_59
  
  # covered by level_1_interval
  # level_0_interval : date '/' date   { result = Interval.new(val[0], val[1]) }

  # ---- Level 1 Extension Rules ----
  
  level_1_expression : unspecified 
                     # | uncertain_or_approximate_date # -> covered by level 2
                     | level_1_interval
                     | long_year_simple
                     | season
  

  # uncertain_or_approximate_date : date uncertain_or_approximate { result = val[0]; val[1].each { |m| result.send(m) } }
  # 
  # uncertain_or_approximate : '?'              { result = [:uncertain!] }
  #                          | '~'            { result = [:approximate!] }
  #                          | '?' '~'  { result = [:uncertain!, :approximate!] }
  

  unspecified : unspecified_year          { result = Date.new(val[0][0]); result.unspecified.year[2,2] = val[0][1]; result.precision = :year }
              | unspecified_month
              | unspecified_day
              | unspecified_day_and_month
  
  unspecified_year : digit digit digit UNSPECIFIED       { result = [val[0,3].zip([1000,100,10]).reduce(0) { |s,(a,b)| s += a * b }, [false,true]] }
                   | digit digit UNSPECIFIED UNSPECIFIED { result = [val[0,2].zip([1000,100]).reduce(0) { |s,(a,b)| s += a * b }, [true, true]] }
  
  unspecified_month : year '-' UNSPECIFIED UNSPECIFIED { result = Date.new(val[0]).unspecified!(:month); result.precision = :month }
  
  unspecified_day : year_month '-' UNSPECIFIED UNSPECIFIED { result = Date.new(*val[0]).unspecified!(:day) }
  
  unspecified_day_and_month : year '-' UNSPECIFIED UNSPECIFIED '-' UNSPECIFIED UNSPECIFIED { result = Date.new(val[0]).unspecified!([:day,:month]) }


  level_1_interval : level_1_start '/' level_1_end { result = Interval.new(val[0], val[2]) }

  level_1_start : date
                # | uncertain_or_approximate_date
                | internal_uncertain_or_approximate_date
                | UNKNOWN                        { result = :unknown }
                
  level_1_end : level_1_start
              | OPEN                             { result = :open }


  long_year_simple : LONGYEAR long_year          { result = Date.new(val[1]); result.precision = :year }
                   | LONGYEAR '-' long_year    { result = Date.new(-1 * val[2]); result.precision = :year }
            
  long_year : positive_digit digit digit digit digit { result = val.zip([10000,1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }
            | long_year digit { result = 10 * val[0] + val[1] }


  season : year '-' season_number { result = Season.new(val[0], val[2]) }

  season_number : '2' '1' { result = 21 }
                | '2' '2' { result = 22 }
                | '2' '3' { result = 23 }
                | '2' '4' { result = 24 }


  # ---- Level 2 Extension Rules ----
  
  level_2_expression : season_qualified
                     | internal_uncertain_or_approximate_date
                     | internal_unspecified
                     | choice_list
                     | inclusive_list
                     | masked_precision
                     # | level_2_interval # -> level 1
                     | date_and_calendar
                     | long_year_scientific
  

  season_qualified : season '^' { result = val[0]; result.qualifier = val[1] }


  long_year_scientific : long_year_simple E integer      { result = Date.new(val[0].year * 10 ** val[2]); result.precision = :year }
                       | LONGYEAR int1_4 E integer       { result = Date.new(val[1] * 10 ** val[3]); result.precision = :year }
                       | LONGYEAR '-' int1_4 E integer { result = Date.new(-1 * val[2] * 10 ** val[4]); result.precision = :year }
  

  date_and_calendar : date '^' { result = val[0]; result.calendar = val[1] }
  

  masked_precision : digit digit digit X { d = val[0,3].zip([1000,100,10]).reduce(0) { |s,(a,b)| s += a * b }; result = Date.new(d) ... Date.new(d+10) }
                   | digit digit X X     { d = val[0,2].zip([1000,100]).reduce(0) { |s,(a,b)| s += a * b }; result = Date.new(d) ... Date.new(d+100) }

  
  choice_list : '[' list ']' { result = val[1] }
  
  inclusive_list : '{' list '}' { result = val[1] }
  
  list : earlier                                 { result = [val[0]] }
       | earlier ',' list_elements ',' later { result = [val[0]] + val[2] + [val[4]] }
       | earlier ',' list_elements             { result = [val[0]] + val[2] }
       | earlier ',' later                     { result = [val[0]] + [val[2]] }
       | list_elements ',' later               { result = val[0] + [val[2]] }
       | list_elements
       | later                                   { result = [val[0]] }
           
  list_elements : list_element                     { result = [val[0]].flatten }
                | list_elements ',' list_element { result = val[0] + [val[2]].flatten }
                
  list_element : date
               | internal_uncertain_or_approximate_date
               # | uncertain_or_approximate_date
               | unspecified
               | consecutives                      { result = val[0].map { |d| Date.new(*d) } }
  
  earlier : DOTS date          { result = val[1] }
  
  later : year_month_day DOTS  { result = Date.new(*val[0]); result.precision = :day }
        | year_month DOTS      { result = Date.new(*val[0]); result.precision = :month }
        | year DOTS            { result = Date.new(val[0]); result.precision = :year }
  
  consecutives : year_month_day DOTS year_month_day
               | year_month DOTS year_month
               | year DOTS year                      { result = (val[0]..val[2]).to_a.map }

  
  internal_unspecified :
		unspecified_year '-' month '-' d01_31
		{
			result = Date.new(val[0][0], val[2], val[4])
			result.unspecified.year[2,2] = val[0][1]
		}
		| unspecified_year '-' UNSPECIFIED UNSPECIFIED '-' d01_31
		{
			result = Date.new(val[0][0], 1, val[5])
			result.unspecified.year[2,2] = val[0][1]
			result.unspecified!(:month)
		}
		| unspecified_year '-' UNSPECIFIED UNSPECIFIED '-' UNSPECIFIED UNSPECIFIED
		{
			result = Date.new(val[0][0], 1, 1)
			result.unspecified.year[2,2] = val[0][1]
			result.unspecified!([:month, :day])
		}
		| unspecified_year '-' month '-' UNSPECIFIED UNSPECIFIED
		{
			result = Date.new(val[0][0], val[2], 1)
			result.unspecified.year[2,2] = val[0][1]
			result.unspecified!(:day)
		}
		| year '-' UNSPECIFIED UNSPECIFIED '-' d01_31
		{
			result = Date.new(val[0], 1, val[5])
			result.unspecified!(:month)
		}
		;

 	internal_uncertain_or_approximate_date : internal_uncertain_or_approximate
		| '(' internal_uncertain_or_approximate ')' ua { result = uoa(val[1], val[3]) }

	internal_uncertain_or_approximate : iua_year { result = val[0]; result.precision = :year }
	    | iua_year_month                         { result = val[0]; result.precision = :month }
	    | iua_year_month_day
	
	iua_year : year ua { result = apply_uncertainty(Date.new(val[0]), val[1], :year) }
	
	iua_year_month : iua_year '-' month opt_ua { result = val[0].change(:month => val[2]); val[3].each { |u| result.send(u, [:month, :year]) } }
		| '(' iua_year IUA month opt_ua  { result = uoa(uoa(val[1], val[2], :year).change(:month => val[3]), val[4], :month) }
		| year '-' month ua { result = uoa(Date.new(val[0], val[2]), val[3], [:year, :month]) }
		| year '-' '(' month ')' ua { result = uoa(Date.new(val[0], val[3]), val[5], [:month]) }

	iua_year_month_day : iua_year_month '-' d01_31 opt_ua { result = uoa(val[0].change(:day => val[2]), val[3]) }
		| iua_year_month '-' '(' d01_31 ')' ua { result = uoa(val[0].change(:day => val[3]), val[5], [:day]) }
		| '(' iua_year_month IUA d01_31 opt_ua { result = uoa(uoa(val[1], val[2], [:year, :month]).change(:day => val[3]), val[4], :day) }
		| year '-' '(' month IUA d01_31 opt_ua { result = uoa(uoa(Date.new(val[0], val[3], val[5]), val[4], :month), val[6], :day) }
		| year_month '-' d01_31 ua  { result = uoa(Date.new(val[0][0], val[0][1], val[2]), val[3]) }
		| year_month '-' '(' d01_31 ')' ua { result = uoa(Date.new(val[0][0], val[0][1], val[3]), val[5], [:day]) }
		| year '-' '(' month '-' d01_31 ')' ua { result = uoa(Date.new(val[0], val[3], val[5]), val[7], [:month, :day]) }

	opt_ua : { result = [] }
		     | ua

	ua : '?'
	   | '~'
	   | '?' '~'  { result = val.flatten }
	
	# ---- Auxiliary Rules ----

	digit : '0'             { result = 0 }
	      | positive_digit
      
	positive_digit : '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'

	d01_12 : '0' positive_digit { result = val[1] }
	       | '1' '0'            { result = 10 }
	       | '1' '1'            { result = 11 }
	       | '1' '2'            { result = 12 }

	d01_13 : d01_12
	       | '1' '3'            { result = 13 }
       
	d01_23 : '0' positive_digit { result = val[1] }
	       | '1' digit          { result = 10 + val[1] }
	       | '2' '0'            { result = 20 }
	       | '2' '1'            { result = 21 }
	       | '2' '2'            { result = 22 }
	       | '2' '3'            { result = 23 }

	d00_23 : '0' '0'
	       | d01_23

	d01_29 : d01_23
	       | '2' '4'             { result = 24 }
	       | '2' '5'             { result = 25 }
	       | '2' '6'             { result = 26 }
	       | '2' '7'             { result = 27 }
	       | '2' '8'             { result = 28 }
	       | '2' '9'             { result = 29 }

	d01_30 : d01_29
	       | '3' '0'             { result = 30 }

	d01_31 : d01_30
	       | '3' '1'             { result = 31 }

	d01_59 : d01_29
	       | '3' digit          { result = 30 + val[1] }
	       | '4' digit          { result = 40 + val[1] }
	       | '5' digit          { result = 50 + val[1] }
       
	d00_59 : '0' '0'
	       | d01_59

	int1_4 : positive_digit                  { result = val[0] }
	       | positive_digit digit             { result = 10 * val[0] + val[1] }
	       | positive_digit digit digit       { result = val.zip([100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }
	       | positive_digit digit digit digit { result = val.zip([1000,100,10,1]).reduce(0) { |s,(a,b)| s += a * b } }

	integer : positive_digit { result = val[0] }
	        | integer digit   { result = 10 * val[0] + val[1] }



---- header
require 'strscan'

---- inner

  @defaults = {
    :level => 2,
    :debug => false
  }
  
  class << self; attr_reader :defaults; end
  
  attr_reader :options
  
  def initialize(options = {})
    @options = Parser.defaults.merge(options)
  end
  
  def parse(input)
    @yydebug = @options[:debug] || ENV['DEBUG']
    @src = StringScanner.new(input)
    do_parse
  end
  
  def on_error(tid, val, vstack)
    warn "failed to parse extended date time %s (%s) %s" % [val.inspect, token_to_str(tid) || '?', vstack.inspect]
  end

	def apply_uncertainty(date, uncertainty, scope = nil)
		uncertainty.each do |u|
			scope.nil? ? date.send(u) : date.send(u, scope)
		end
		date
	end
	
	alias uoa apply_uncertainty
	
  def next_token
		case
		when @src.eos?
			nil
	  # when @src.scan(/\s+/)
	    # ignore whitespace
	  when @src.scan(/\(/)
	    ['(', @src.matched]	
	  when @src.scan(/\)\?~-/)
			[:IUA, [:uncertain!, :approximate!]]
	  when @src.scan(/\)\?-/)
			[:IUA, [:uncertain!]]
	  when @src.scan(/\)~-/)
			[:IUA, [:approximate!]]
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
	  when @src.scan(/\?/)
	    ['?', [:uncertain!]]
	  when @src.scan(/~/)
	    ['~', [:approximate!]]
	  when @src.scan(/open/i)
	    [:OPEN, @src.matched]
	  when @src.scan(/unkn?own/i) # matches 'unkown' typo too
	    [:UNKNOWN, @src.matched]
	  when @src.scan(/u/)
	    [:UNSPECIFIED, @src.matched]
	  when @src.scan(/x/i)
	    [:X, @src.matched]
	  when @src.scan(/y/)
	    [:LONGYEAR, @src.matched]
	  when @src.scan(/e/)
	    [:E, @src.matched]
	  when @src.scan(/\+/)
	    [:PLUS, @src.matched]
	  when @src.scan(/-/)
	    ['-', @src.matched]
	  when @src.scan(/:/)
	    [':', @src.matched]
	  when @src.scan(/\//)
	    ['/', @src.matched]
	  when @src.scan(/\s*\.\.\s*/)
	    [:DOTS, '..']
	  when @src.scan(/\s*,\s*/)
	    [',', ',']
	  when @src.scan(/\^\w+/)
	    ['^', @src.matched[1..-1]]
	  when @src.scan(/\d/)
	    [@src.matched, @src.matched.to_i]
	  else @src.scan(/./)
	    [:UNMATCHED, @src.rest]
	  end
  end


# -*- racc -*-