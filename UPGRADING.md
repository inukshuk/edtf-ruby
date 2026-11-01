Upgrading to EDTF-Ruby 5.0
==========================
EDTF-Ruby 5.0 switches from the EDTF draft syntax to ISO 8601-2.
It reads the draft syntax still (in a legacy mode in 5.0),
but writes ISO 8601-2 only,
and its API changes:

* **No core patches.**
  EDTF-Ruby 4.x extended Ruby's `Date`, `DateTime`, and `Range`.
  5.0 has its own types instead;
  `EDTF::Date` is still a Ruby `Date`,
  and `EDTF::DateTime` is now a Ruby `Time`.
  The only addition to Ruby is the conversion method `EDTF()`.
* **Immutable values.**
  All EDTF objects are frozen;
  instead of the bang! methods, `with` returns a modified copy.
* **Periods.**
  Every type stands for a period of time
  with plain Ruby dates as `begin` and `end`,
  and the same `cover?`, `include?`, `<=>` and `edtf`.
* **No ActiveSupport.**
  EDTF-Ruby no longer depends on or loads ActiveSupport,
  but works with it.

If you parse ISO strings and print them,
replacing `Date.edtf` is likely all you need.
EDTF-Ruby 4.1 helps you prepare:
it warns about legacy syntax and deprecated calls
when deprecation warnings are enabled
(`RUBYOPT=-W:deprecated`, or `Warning[:deprecated] = true`),
and `EDTF.legacy?` finds stored strings in legacy syntax.


Parsing and printing
--------------------
| 4.x | 5.0 |
|---|---|
| `Date.edtf(s)` | `EDTF.parse(s)` |
| `Date.edtf!(s)` | `EDTF.parse!(s)` or `EDTF(s)` |
| `date.edtf` on a plain `Date` | `EDTF(date).edtf` |
| `range.edtf` | `EDTF::Interval.new(a, b).edtf` |
| `EDTF::Parser#parse` returned objects | it returns parse results (hashes); `EDTF(result)` builds the object |

Output is ISO 8601-2:

| 4.x | 5.0 |
|---|---|
| `1984?~` | `1984%` |
| `2004-(06)?-11` | `2004-?06-11` |
| `unknown/2006`, `2004/unknown` | `/2006`, `2004/` |
| `2004/open` | `2004/..` |
| `199u` | `199X` |
| `2004-01-01T10:10:10+00:00` | `2004-01-01T10:10:10Z` |
| `2001-02-03^julian`, `2001-21^southern` | `2001-02-03`, `2001-21` (ISO 8601-2 has no calendars or season qualifiers) |

`to_s` returns the EDTF string, too, for every type;
`iso8601` still returns the ISO 8601-1 string
of the first day (or of the instant, for date-times).


Dates
-----
| 4.x | 5.0 |
|---|---|
| `d.precision = :month`, `d.month_precision!` | `d = d.with(precision: :month)` |
| `d.month_precision` | `d.with(precision: :month)` |
| `d.uncertain!(:year)`, `d.approximate!` | `d.with(uncertain: :year)`, `d.with(approximate: true)` |
| `d.certain!`, `d.precise!` | `d.with(uncertain: nil)`, `d.with(approximate: nil)` |
| `d.unspecified!(:day)` | `d.with(unspecified: :day)` |
| `d.uncertain`, `d.approximate`, `d.unspecified` (structs) | the same names return an `EDTF::Bitmask` |
| `d.next(3)` (an array) | `(1..3).map { d.succ(_1) }`; `d.succ(3)` is the third successor |
| `d.change(...)`, `d.advance(...)` kept EDTF attributes | they return plain dates (date math) |
| `d.calendar` | gone; `EDTF::Parser` results keep `calendar:` |
| `EDTF::Unknown` (`uuuu`, `XXXX`) | an `EDTF::Date` with an unspecified year |

`with` replaces values instead of adding to them:
`d.with(uncertain: :year)` means only the year is uncertain.
To add a part, combine the bitmasks:
`d.with(uncertain: d.uncertain | :year)`.

Plain Ruby dates have no EDTF methods any more;
convert them with `EDTF(date)`.
Note that `Date.new(1984) == EDTF('1984')` is true,
because Ruby's `Date#==` compares the day,
while `EDTF('1984') == Date.new(1984)` is false:
a year is not the same period as its first day.


Date-times
----------
| 4.x | 5.0 |
|---|---|
| a Ruby `DateTime` with EDTF methods | `EDTF::DateTime`, a Ruby `Time` |
| `skip_timezone?` | `floating?` (no offset in the string) |

A date-time without an offset is floating:
EDTF-Ruby keeps it on the UTC clock, never in the system's time zone.
EDTF date-times are frozen,
so `utc` and `localtime` raise; use `getutc` and `getlocal`.


Intervals
---------
| 4.x | 5.0 |
|---|---|
| `min`, `max` | `begin`, `end` (plain dates; nil for open or unknown ends) |
| `length` | `count` |
| `step(n)` | `each_slice(n)` |
| `open_end?`, `unknown_start?`, … | `to == :open`, `from == :unknown`, … |
| `interval <=> date` was 0 for covered dates | intervals and dates compare as periods; use `cover?` |


Sets
----
| 4.x | 5.0 |
|---|---|
| `EDTF::Set` with `choice?` | `EDTF::Set` (`[…]`, one of) and `EDTF::List` (`{…}`, all of) |
| `choice!` | `EDTF::Set.new(*list.values)` |
| `earlier!`, `later!` | `with(earlier: true)`, `with(later: true)` |
| `set << date` | `set.with(values: set.values + [date])` |

Neither is a Ruby `Set`;
`to_set` returns one with all members, ranges enumerated.


Decades, centuries, and seasons
-------------------------------
| 4.x | 5.0 |
|---|---|
| `EDTF::Decade.new(1999)` (any year) | `EDTF::Decade.new(199)` (the digits) |
| `EDTF::Century.new(1999)` | `EDTF::Century.new(19)` |
| `min`, `max`, `.current` | `begin`, `end`; `.current` is gone |
| `EDTF::Season.new(2004, :summer)` | `EDTF::Season.new(2004, 22)` |
| `season.summer?`, `season.season` (a Symbol) | `season.season` (the code, 21–41) |

Seasons 21–24 still span three months, meteorologically
(winter reaches into the next year).


Equality
--------
`==` means the same period:
the same bounds and precision, ignoring qualifiers
(`EDTF('1906') == EDTF('1906?')`).
`eql?` and `hash` compare the EDTF expression,
so qualified values stay apart as hash keys,
like `1 == 1.0` but not `1.eql?(1.0)` in Ruby.


ActiveSupport
-------------
EDTF-Ruby 4.x loaded ActiveSupport's date and time extensions.
5.0 does not:
outside Rails, require ActiveSupport yourself if you use them.
With ActiveSupport loaded, `to_json` writes the EDTF string of every type.
