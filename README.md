EDTF-Ruby
=========
[![ci](https://github.com/inukshuk/edtf-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/inukshuk/edtf-ruby/actions/workflows/ci.yml)

EDTF-Ruby comprises a parser and an API implementation
of the [Extended Date/Time Format](https://www.loc.gov/standards/datetime/) (EDTF)
as specified by ISO 8601-2.

This is the development version of EDTF-Ruby 5.0,
which switches from the EDTF draft syntax to ISO 8601-2.
For EDTF-Ruby 4.x see the [legacy branch](https://github.com/inukshuk/edtf-ruby/tree/legacy);
to upgrade, see [UPGRADING.md](UPGRADING.md).


Compatibility
-------------
EDTF-Ruby implements EDTF levels 0, 1, and 2
as specified by ISO 8601-2.
Its classes support all features of these levels;
the parser does not read the following yet:
qualification from the left (`2004-?06-11`),
unspecified digits anywhere (`1XXX-12`),
significant digits (`1950S2`),
decades and centuries (`196`, `19`),
seasons 25–41,
fractional seconds,
and hour-only or basic-format offsets (`-04`, `+0230`).

EDTF-Ruby still reads the draft syntax of earlier EDTF versions
(`?~`, parentheses, `u`, `open`, `unknown`, …)
and warns when deprecation warnings are enabled;
see [Legacy syntax](#legacy-syntax).

EDTF-Ruby is tested on Ruby 3.3 and later, and on JRuby.
It does not depend on ActiveSupport,
but works with it and with Rails;
see [Rails and ActiveSupport](#rails-and-activesupport).


Quickstart
----------
Parse EDTF strings with `EDTF.parse`,
which returns nil if the string cannot be parsed,
or with `EDTF.parse!` or `EDTF()`,
which raise an ArgumentError instead.

    require 'edtf'

    EDTF.parse('2016-XX')            #-> #<EDTF::Date 2016-XX>
    EDTF.parse('not a date')         #-> nil
    EDTF('2016-04~/2016-05')         #-> #<EDTF::Interval 2016-04~/2016-05>

`EDTF()` also converts Ruby dates and times,
parse results (see [Parser](#parser)),
and returns EDTF objects unchanged.

    EDTF(Date.new(2016, 5, 31))      #-> #<EDTF::Date 2016-05-31>

EDTF-Ruby has the following types:
`EDTF::Date` (a Ruby `Date`) and `EDTF::DateTime` (a Ruby `Time`),
`EDTF::Decade` and `EDTF::Century`,
`EDTF::Season`,
`EDTF::Interval`,
`EDTF::Set` (one of a set) and `EDTF::List` (all members of a set).

Each EDTF string stands for a period of time,
so all types share an interface (`EDTF::Period`):
the corresponding EDTF string,
the first and last day of the period,
its precision,
and its values.

    EDTF('2016?').edtf               #-> "2016?"
    EDTF('2016?').to_s               #-> "2016?"

`edtf` and `to_s` return the ISO 8601-2 (EDTF) string;
`iso8601` returns the ISO 8601-1 string of the first day, as in Ruby:

    EDTF('2016?').iso8601            #-> "2016-01-01"

    EDTF('2016-02').begin.to_s       #-> "2016-02-01"
    EDTF('2016-02').end.to_s         #-> "2016-02-29"
    EDTF('2016-02').precision        #-> :month

    EDTF('2016-02-XX').begin.to_s    #-> "2016-02-01"
    EDTF('2016-02-XX').end.to_s      #-> "2016-02-29"

    EDTF('[..2016,2017]').begin      #-> nil
    EDTF('[..2016,2017]').end.to_s   #-> "2017-12-31"

    EDTF('2016-23').begin.to_s       #-> "2016-09-01"
    EDTF('2016-23').end.to_s         #-> "2016-11-30"

    EDTF('2016?-02').values          #-> [2016, 2]

All EDTF objects are frozen;
use `with` for a modified copy.
Create them with `EDTF()`, `EDTF.parse`, or their `new` method;
Ruby's other constructors (such as `EDTF::Date.today`) are private,
use `EDTF(Date.today)` instead.

    EDTF('2016-05?').with(approximate: true).edtf  #-> "2016-05%"


Dates
-----
Most of the EDTF features deal with dates;
EDTF-Ruby implements these by extending the regular Ruby Date class.
Every EDTF date acts as you would normally expect,
but provides additional functionality.

Most notably, EDTF dates come in day, month, or year precision.
This is a subtle difference that determines how many other methods work.
For instance:

    EDTF('2016-05-31').succ.edtf     #-> "2016-06-01"
    EDTF('2016-05').succ.edtf        #-> "2016-06"
    EDTF('2016').succ.edtf           #-> "2017"

The natural successor of a date with month precision
is not the next day, but the next month.
Always keep precision in mind when comparing dates, too:

    EDTF('1966') == EDTF('1966-01-01')   #-> false

The year 1966 is not equal to the January 1st, 1966.
To change a date's precision, use `with`:

    d = EDTF('1993-01-01')
    d.with(precision: :month).edtf   #-> "1993-01"
    d.with(precision: :year).edtf    #-> "1993"

In the examples above, you also see that `edtf`
prints a different string depending on the date's precision.

Date math (`+`, `-`, `>>`, `<<`, `next_day`, …) returns plain Ruby dates,
because the result no longer stands for the same EDTF string:

    (EDTF('2016-05?') + 1).class     #-> Date

### Unspecified, uncertain, and approximate dates

The second important extension is that dates can be uncertain and or approximate.
The distinction between the two may seem somewhat contrived,
but we have come to understand it as follows:

Assume you take a history exam
and have to answer one of those dreaded questions
that require you to say exactly in what year a certain event happened;
you studied hard, but all of a sudden you are *uncertain*:
was that the year 1683 or was it 1638?
This is what uncertainty is in the parlance of EDTF:
in fact, you would write it just like that "1638?".

Approximate dates are similar but slightly different.
Let's say you want to tell a story about something that happened to you one winter;
you don't recall the exact date,
but you know it must have been sometime between Christmas and New Year's.
Come to think of it, you don't remember the year either,
but you must have been around ten years old.
Using EDTF, you could write something like "1993~-12-~27":
this indicates that both the year and the day are approximations:
perhaps the day is not the 27th but it is somewhere close.

This is the main difference between uncertain and approximate in EDTF
(in our opinion at least):
approximate always means close to the actual number,
whilst uncertain could be something completely different
(just as there is a large temporal distance between 1638 and 1683).

EDTF-Ruby keeps track of qualified dates using bitmasks (`EDTF::Bitmask`).
You can ask about the whole date, or about its year, month, or day:

    EDTF('2016-05?').uncertain?              #-> true
    EDTF('2016-05?').approximate?            #-> false
    EDTF('2016-05?').uncertain?(:month)      #-> true
    EDTF('2016-05?').uncertain?(:day)        #-> false
    EDTF('2016?-05').uncertain?(:month)      #-> false

    EDTF('201X').unspecified?(:year)         #-> true
    EDTF('1999-XX').unspecified.to_s         #-> "YYYY-XX-DD"

When printing qualified dates,
EDTF-Ruby finds the shortest rendition of the qualification symbols,
so you can use it to normalize EDTF strings:

    EDTF('2016-05-31%').edtf                 #-> "2016-05-31%"
    EDTF::Date.new(2016, 5, 31, uncertain: [:year, :month]).edtf  #-> "2016-05?-31"
    EDTF::Date.new(2004, 6, 11, uncertain: :year, approximate: :day).edtf  #-> "2004?-06-~11"

Uncertain, approximate, and unspecified parts
do not factor into comparisons;
dates are equal if they stand for the same period,
and `eql?` (used for hash keys) tells them apart:

    EDTF('1906') == EDTF('1906?')            #-> true
    EDTF('1906').eql?(EDTF('1906?'))         #-> false

Unspecified digits widen a date's bounds,
and its successor steps over them:

    EDTF('1999-03-XX').end.to_s              #-> "1999-03-31"
    EDTF('201X').succ.edtf                   #-> "202X"

### Years

EDTF years beyond four digits are written with a `Y` prefix,
and may use an exponent:

    EDTF('Y170000002').year                  #-> 170000002
    EDTF('Y-17E7').edtf                      #-> "Y-170000000"

Years may have significant digits,
which widen their bounds:

    EDTF::Date.new(1950, significant: 2).edtf      #-> "1950S2"
    EDTF::Date.new(1950, significant: 2).end.to_s  #-> "1999-12-31"


Date-times
----------
EDTF date-times are regular Ruby times,
which know whether their string had an offset.
Without one, a time is floating;
EDTF-Ruby keeps it on the UTC clock, never in the system's time zone.

    t = EDTF('2004-01-01T10:10:10+05:00')
    t.offset                                 #-> 300
    t == EDTF('2004-01-01T05:10:10Z')        #-> true
    EDTF('2004-01-01T10:10:10').floating?    #-> true

Compared with dates,
a time counts as its own calendar date in its own offset,
after the whole day:

    EDTF('2004-01-01') < t                   #-> true
    EDTF('2004').cover?(t)                   #-> true


Intervals
---------
If you parse an EDTF interval,
EDTF-Ruby returns an instance of `EDTF::Interval`;
intervals behave like regular Ruby ranges,
but are dedicated to EDTF periods.
Most importantly, intervals use the precision of their start
when generating the set of contained values and for membership tests.

    i = EDTF('1984-06?/2004-08?')
    i.from.uncertain?                        #-> true
    i.include?(Date.new(1987, 4, 13))        #-> false

The day is not included because the interval has month precision.
However:

    i.cover?(Date.new(1987, 4, 13))          #-> true

The day is still covered by the interval.
Precision also plays into the way intervals are enumerated:

    i.count                                  #-> 243

There are 243 months between 1984-06-01 and 2004-08-31.

    i.each_slice(36).map { |months| months.first.year }  #-> [1984, 1987, 1990, 1993, 1996, 1999, 2002]

Here we iterate through the interval in 36-month steps
and map each step to its first year.
This also works with varying precisions:

    EDTF('2015-10/2016').map(&:edtf).first(4)   #-> ["2015-10", "2015-11", "2015-12", "2016-01"]

    EDTF('1582-10-01/1582-10-31').count      #-> 31

This interval has day precision,
so 31 is the number of days in October 1582:
EDTF-Ruby uses the proleptic Gregorian calendar,
so the ten days skipped by the Gregorian calendar reform are included.

Intervals can have open (`..`) or unknown (empty) ends,
whose bounds are nil:

    EDTF('2004/..').open?                    #-> true
    EDTF('2004/..').cover?(Date.today)       #-> true
    EDTF('/2004').unknown?                   #-> true


Sets and lists
--------------
EDTF supports two kinds of sets:
choice lists (meaning one date out of a list),
or inclusive lists.
In EDTF-Ruby, these are covered by `EDTF::Set` and `EDTF::List`.

    s = EDTF('{1667,1668,1670..1672}')
    s.class                                  #-> EDTF::List
    EDTF('[1667,1668,1670..1672]').class     #-> EDTF::Set

EDTF-Ruby remembers which parts of the set were specified as a range;
ranges are however enumerated for membership tests:

    s.include?(EDTF('1669'))                 #-> false
    s.include?(EDTF('1671'))                 #-> true

Even though we're still aware
that the year 1671 is not directly an element of the set:

    s.values.length                          #-> 3

When in doubt, you can always map the set to an array.
This will also enumerate all ranges:

    s.map(&:year)                            #-> [1667, 1668, 1670, 1671, 1672]

Sets and lists also have an open start or end (`earlier?` and `later?`):

    s.earlier?                               #-> false
    s.with(earlier: true).edtf               #-> "{..1667,1668,1670..1672}"

Beyond an open start or end,
every year (or month, or day, like the member there) is included,
although enumerating the set yields only the members as written,
like the beginless Ruby range `(..5)` includes 3 but cannot be enumerated:

    EDTF('[..1760]').include?(EDTF('1700'))  #-> true
    EDTF('[..1760]').map(&:edtf)             #-> ["1760"]


Decades and centuries
---------------------
Decades and centuries are dedicated periods,
which always cover 10 or 100 years, respectively:
the years that begin with the given digits.

    d = EDTF::Decade.new(196)
    d.edtf                                   #-> "196"
    [d.begin.to_s, d.end.to_s]               #-> ["1960-01-01", "1969-12-31"]
    EDTF::Century.new(19, approximate: true).edtf  #-> "19~"

The years of a decade can also be written with unspecified digits (`196X`):
that is a year, with year precision, in the same span.


Seasons
-------
Finally, EDTF covers seasons and other divisions of a year
(ISO 8601-2 codes 21–41),
and EDTF-Ruby provides a dedicated class for them.
Note that EDTF does not make any assumption about the specifics
(which months etc.) of the seasons;
EDTF-Ruby uses meteorological seasons (three month periods).

    w = EDTF('2003-24')
    [w.begin.to_s, w.end.to_s]               #-> ["2003-12-01", "2004-02-29"]
    s = w.succ
    s.edtf                                   #-> "2004-21"
    (s.end - s.begin).to_i + 1               #-> 92
    (w.end - w.begin).to_i + 1               #-> 91

As you can see, spring 2004 lasted one day longer than winter 2003.
Seasons can be uncertain or approximate, too:

    s.with(approximate: true).edtf           #-> "2004-21~"


Parser
------
To use EDTF-Ruby's parser directly, use `EDTF::Parser`.
The parser returns frozen hashes
which you can pass to `EDTF()` for conversion to EDTF objects,
or to your own post-processing.

    EDTF::Parser.new.parse('2016-02')        #-> {type: :date, values: [2016, 2], level: 0}

As you can see, the parse result includes the compatibility level of
the string parsed;
the values array contains the individual date parts (months are 1-based).
Unspecified, uncertain, or approximate digits are returned
as the numeric value of a bitmask:

    EDTF::Parser.new.parse('2016?-02')       #-> {type: :date, values: [2016, 2], uncertain: 15, level: 2}
    EDTF::Parser.new.parse('20XX-02')        #-> {type: :date, values: [2000, 2], unspecified: 12, level: 2}

Unspecified digits always hold the least possible value,
e.g., 2000 for 20XX.
Intervals, sets, and lists contain their parsed constituent dates in
the values array:

    EDTF::Parser.new.parse('2015/..')[:values].last  #-> :open

Parse results are plain data:
you can store them, e.g. as JSON,
and `EDTF()` builds objects from them again, also when read back from JSON.


Rails and ActiveSupport
-----------------------
EDTF-Ruby does not depend on ActiveSupport,
but EDTF dates and date-times inherit from Ruby's Date and Time,
which ActiveSupport extends.
With ActiveSupport loaded:

* Date and time calculations (`+ 1.month`, `advance`, `beginning_of_day`, …)
  return plain dates and times, like all date math.
* `to_json` writes the EDTF string of every type.
* Times in a zone (`ActiveSupport::TimeWithZone`)
  compare with EDTF dates and date-times like Ruby times.

EDTF-Ruby no longer loads ActiveSupport itself:
outside Rails, require it if you use its extensions.

To store EDTF values, store their EDTF strings
and read them back with `EDTF()`;
a date column would keep only the first day of a period.


Legacy syntax
-------------
Earlier versions of EDTF used a draft syntax
that ISO 8601-2 replaced
(`?~` became `%`, `u` became `X`, `open` became `..`, …).
EDTF-Ruby still reads the draft syntax and writes ISO 8601-2;
enable deprecation warnings to see which input uses it:

    $ RUBYOPT=-W:deprecated bundle exec rake
    EDTF "2004/open": `open` is legacy syntax, use `..`

To audit stored dates, use `EDTF.legacy?`,
e.g. to print each line of a file that uses legacy syntax:

    $ ruby -redtf -ne 'print if EDTF.legacy?($_.chomp)' dates.txt

EDTF-Ruby 5.0 will read the draft syntax only in a legacy mode.


Contributing
------------
The EDTF-Ruby source code is [hosted on GitHub](https://github.com/inukshuk/edtf-ruby).
You can check out a copy of the latest code using Git:

    $ git clone https://github.com/inukshuk/edtf-ruby.git

To get started, install the dependencies and run all tests:

    $ cd edtf-ruby
    $ bundle install
    $ bundle exec rake

`rake` runs the specs, the specs with ActiveSupport loaded
(`rake spec:active_support`, in their own process),
and the Cucumber features (see [features/README.md](features/README.md)).

If you change the grammar in `lib/edtf/parser.y`,
regenerate the parser with `bundle exec rake racc`.

If you've found a bug or have a question,
please open an issue on the
[EDTF-Ruby issue tracker](https://github.com/inukshuk/edtf-ruby/issues).
Or, for extra credit, clone the EDTF-Ruby repository,
write a failing example, fix the bug
and submit a pull request.


Credits
-------
EDTF-Ruby was written by Sylvester Keil and Ilja Srna.

Published under the terms and conditions of the FreeBSD License;
see LICENSE for details.
