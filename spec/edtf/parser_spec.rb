module EDTF
  describe Parser do
    describe '#parse' do

      it 'parses simple dates "2001-02-03"' do
        expect(Parser.new.parse('2001-02-03').to_s).to eq('2001-02-03')
      end

      it 'parses negative years' do
        expect(Parser.new.parse('-2323').to_s).to eq('-2323-01-01')
      end

			it 'parses the negative year -2101 and sets the precision to :year' do
				expect(Parser.new.parse('-2101')).to be_year_precision
			end

      it 'parses year zero' do
        expect(Parser.new.parse('0000').to_s).to eq('0000-01-01')
      end

      it 'parses date/time with time zones' do
        expect(Parser.new.parse('2011-08-15T11:19:00+01:00').to_s).to eq('2011-08-15T11:19:00+01:00')
      end

      it 'parses simple intervals like "2007/2008"' do
        expect(Parser.new.parse('2007/2008')).to be_a(Interval)
      end

      it 'parses uncertain dates' do
        expect(Parser.new.parse('1984?')).to be_uncertain
        expect(Parser.new.parse('1984')).to be_certain
      end

      it 'parses uncertain dates (day precision)' do
        expect(Parser.new.parse('1984-11-23?')).to be_uncertain
        expect(Parser.new.parse('1984-11-23')).to be_certain
      end

      it 'parses approximate dates' do
        expect(Parser.new.parse('1984-01~')).to be_approximate
        expect(Parser.new.parse('1984-01')).to be_precise
      end

      it 'parses draft spec uncertain approximate dates' do
        expect(Parser.new.parse('1984?~')).to be_uncertain
        expect(Parser.new.parse('1984?~')).to be_approximate
      end

      it 'parses final spec uncertain approximate dates' do
        expect(Parser.new.parse('1984%')).to be_uncertain
        expect(Parser.new.parse('1984%')).to be_approximate
      end

      it 'parses draft spec unspecified dates' do
        expect(Parser.new.parse('199u')).to be_unspecified
        expect(Parser.new.parse('1999-uu-uu')).to be_unspecified
        expect(Parser.new.parse('199u-01')).to be_unspecified
      end

      it 'parses final spec unspecified dates' do
        expect(Parser.new.parse('199X')).to be_unspecified
        expect(Parser.new.parse('1999-XX-XX')).to be_unspecified
        expect(Parser.new.parse('199X-01')).to be_unspecified
      end

      it 'parses draft spec negative unspecified dates' do
        expect(Parser.new.parse('-199u')).to be_unspecified
        expect(Parser.new.parse('-1999-uu-uu')).to be_unspecified
      end

      it 'parses final spec negative unspecified dates' do
        expect(Parser.new.parse('-199X')).to be_unspecified
        expect(Parser.new.parse('-1999-XX-XX')).to be_unspecified
      end

      it 'parses open intervals' do
        expect(Parser.new.parse('2004-01-01/open')).to be_open
      end

      it 'parses unknown intervals' do
        expect(Parser.new.parse('2004-01-01/unknown')).to be_unknown_end
        expect(Parser.new.parse('unknown/2004-01-01')).to be_unknown_start
      end

      it 'parses intervals with uncertain or approximate dates' do
        expect(Parser.new.parse('1984-06-02?/2004-08-08~').from).to be_uncertain
        expect(Parser.new.parse('1984-06-02?/2004-08-08~').to).to be_approximate
      end

      it 'parses positive long years' do
        expect(Parser.new.parse('y170000002').year).to eq(170000002)
      end

      it 'parses negative long years' do
        expect(Parser.new.parse('y-170000002').year).to eq(-170000002)
      end

      it 'parses season codes' do
        expect(Parser.new.parse('2003-23')).to be_autumn
      end

      it 'parses calendar names' do
        expect(Parser.new.parse('2001-02-03^xyz').calendar).to eq('xyz')
      end

      it 'parses season qualifiers' do
        d = Parser.new.parse('2003-23^european')
        expect(d).to be_autumn
        expect(d).to be_qualified
        expect(d.qualifier).to eq('european')
      end

			it 'parses uncertain seasons' do
        expect(Parser.new.parse!('2003-23?')).to be_uncertain
			end

			it 'parses approximate seasons' do
        expect(Parser.new.parse!('2003-23~')).to be_approximate
			end

			it 'parses draft spec uncertain and approximate seasons' do
        expect(Parser.new.parse!('2003-23?~')).to be_uncertain
        expect(Parser.new.parse!('2003-23?~')).to be_approximate
			end

      it 'parses final spec uncertain and approximate seasons' do
        expect(Parser.new.parse!('2003-23%')).to be_uncertain
        expect(Parser.new.parse!('2003-23%')).to be_approximate
      end

      it 'parses positive scientific long years' do
        expect(Parser.new.parse('y17e7').year).to eq(170000000)
        expect(Parser.new.parse('Y17E7').year).to eq(170000000)
      end

      it 'parses negative scientific long years' do
        expect(Parser.new.parse('y-17e7').year).to eq(-170000000)
        expect(Parser.new.parse('Y-17E7').year).to eq(-170000000)
      end

      it 'parses masked precision date strings (decades)' do
        d = Parser.new.parse!('198x')
        expect(d).to be_cover(Date.new(1983,3,12))
        expect(d).not_to be_cover(Date.new(1990,1,1))
      end

      it 'parses masked precision date strings (centuries)' do
        d = Parser.new.parse!('18xx')
        expect(d).to be_cover(Date.new(1848,1,14))
        expect(d).not_to be_cover(Date.new(1799,12,31))
      end

      it 'parses multiple dates (years)' do
        d = Parser.new.parse!('{1667,1668, 1670..1672}')
        expect(d.map(&:year)).to eq([1667,1668,1670,1671,1672])
      end

      it 'parses multiple dates (mixed years and months)' do
        d = Parser.new.parse!('{1960, 1961-12}')
        expect(d.map { |x| [x.year,x.month] }).to eq([[1960,1],[1961,12]])
      end

      it 'parses choice lists (One of the years 1667, 1668, 1670, 1671, 1672)' do
        d = Parser.new.parse!('[1667,1668, 1670..1672]')
        expect(d.map(&:year)).to eq([1667,1668,1670,1671,1672])
      end

      it 'parses choice lists (December 3, 1760 or some earlier date)' do
        d = Parser.new.parse!('[..1760-12-03]')
        expect(d.map(&:to_s)).to eq(['1760-12-03'])
      end

      it 'parses choice lists (December 1760 or some later month)' do
        d = Parser.new.parse!('[1760-12..]')
        expect(d.map { |x| [x.year,x.month] }).to eq([[1760,12]])
      end

      it 'parses choice lists (January or February of 1760 or December 1760 or some later month)' do
        d = Parser.new.parse!('[1760-01, 1760-02, 1760-12..]')
        expect(d.length).to eq(3)
      end

      it 'parses intern unspecified "199u-01-01"' do
        expect(Parser.new.parse!('199u-01-01').unspecified.to_s).to eq('sssX-ss-ss')
      end

      it 'parses intern unspecified "19uu-01-01"' do
        expect(Parser.new.parse!('19uu-01-01').unspecified.to_s).to eq('ssXX-ss-ss')
      end

      it 'parses intern unspecified "199u-uu-01"' do
        expect(Parser.new.parse!('199u-uu-01').unspecified.to_s).to eq('sssX-XX-ss')
      end

      it 'parses intern unspecified "19uu-uu-01"' do
        expect(Parser.new.parse!('19uu-uu-01').unspecified.to_s).to eq('ssXX-XX-ss')
      end

      it 'parses intern unspecified "199u-uu-uu"' do
        expect(Parser.new.parse!('199u-uu-uu').unspecified.to_s).to eq('sssX-XX-XX')
      end

      it 'parses intern unspecified "19uu-uu-uu"' do
        expect(Parser.new.parse!('19uu-uu-uu').unspecified.to_s).to eq('ssXX-XX-XX')
      end

      it 'parses intern unspecified "199u-01-uu"' do
        expect(Parser.new.parse!('199u-01-uu').unspecified.to_s).to eq('sssX-ss-XX')
      end

      it 'parses intern unspecified "19uu-01-uu"' do
        expect(Parser.new.parse!('19uu-01-uu').unspecified.to_s).to eq('ssXX-ss-XX')
      end

      it 'parses intern unspecified "1999-uu-01"' do
        expect(Parser.new.parse!('1999-uu-01').unspecified.to_s).to eq('ssss-XX-ss')
      end

      it 'parses intern unspecified "2004-06-uu"' do
        expect(Parser.new.parse!('2004-06-uu').unspecified.to_s).to eq('ssss-ss-XX')
      end

			it 'parses internal unspecified interval  "2004-06-uu/2004-07-03"' do
				expect(Parser.new.parse!('2004-06-uu/2004-07-03').from).to eq(Date.new(2004,6,1))
			end

      it 'parses intern unspecified "199X-01-01"' do
        expect(Parser.new.parse!('199X-01-01').unspecified.to_s).to eq('sssX-ss-ss')
      end

      it 'parses intern unspecified "19XX-01-01"' do
        expect(Parser.new.parse!('19XX-01-01').unspecified.to_s).to eq('ssXX-ss-ss')
      end

      it 'parses intern unspecified "199X-XX-01"' do
        expect(Parser.new.parse!('199X-XX-01').unspecified.to_s).to eq('sssX-XX-ss')
      end

      it 'parses intern unspecified "19XX-XX-01"' do
        expect(Parser.new.parse!('19XX-XX-01').unspecified.to_s).to eq('ssXX-XX-ss')
      end

      it 'parses intern unspecified "199X-XX-XX"' do
        expect(Parser.new.parse!('199X-XX-XX').unspecified.to_s).to eq('sssX-XX-XX')
      end

      it 'parses intern unspecified "19XX-XX-XX"' do
        expect(Parser.new.parse!('19XX-XX-XX').unspecified.to_s).to eq('ssXX-XX-XX')
      end

      it 'parses intern unspecified "199X-01-XX"' do
        expect(Parser.new.parse!('199X-01-XX').unspecified.to_s).to eq('sssX-ss-XX')
      end

      it 'parses intern unspecified "19XX-01-XX"' do
        expect(Parser.new.parse!('19XX-01-XX').unspecified.to_s).to eq('ssXX-ss-XX')
      end

      it 'parses intern unspecified "1999-XX-01"' do
        expect(Parser.new.parse!('1999-XX-01').unspecified.to_s).to eq('ssss-XX-ss')
      end

      it 'parses intern unspecified "2004-06-XX"' do
        expect(Parser.new.parse!('2004-06-XX').unspecified.to_s).to eq('ssss-ss-XX')
      end

			it 'parses internal unspecified interval  "2004-06-XX/2004-07-03"' do
				expect(Parser.new.parse!('2004-06-XX/2004-07-03').from).to eq(Date.new(2004,6,1))
			end

			it 'parses "2004?-06-11": uncertain year; month, day known' do
				d = Parser.new.parse!('2004?-06-11')
				expect(d.uncertain?(:year)).to be true
				expect(d.uncertain?([:month, :day])).to be false
			end

			it 'parses "2004-06~-11": year and month are approximate; day known' do
				d = Parser.new.parse!('2004-06~-11')
				expect(d.approximate?(:year)).to be true
				expect(d.approximate?(:month)).to be true
				expect(d.approximate?(:day)).to be false
			end

			it 'parses "2004-(06)?-11": uncertain month, year and day known' do
				d = Parser.new.parse!('2004-(06)?-11')

				expect(d.uncertain?(:year)).to be false
				expect(d.approximate?(:year)).to be false

				expect(d.uncertain?(:month)).to be true
				expect(d.approximate?(:month)).to be false

				expect(d.uncertain?(:day)).to be false
				expect(d.approximate?(:day)).to be false
			end

			it 'parses "2004-06-(11)~": day is approximate; year, month known' do
				d = Parser.new.parse!('2004-06-(11)~')
				expect(d.approximate?(:year)).to be false
				expect(d.approximate?(:month)).to be false
				expect(d.approximate?(:day)).to be true
			end

			it 'parses "2004-(06)?~": year known, month within year is approximate and uncertain' do
				d = Parser.new.parse!('2004-(06)?~')

				expect(d.approximate?(:year)).to be false
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be true
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be false
				expect(d.uncertain?(:day)).to be false
			end

			it 'parses "2004-(06-11)?": year known, month and day uncertain' do
				d = Parser.new.parse!('2004-(06-11)?')

				expect(d.approximate?(:year)).to be false
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be false
				expect(d.uncertain?(:day)).to be true
			end

			it 'parses "2004?-06-(11)~": year uncertain, month known, day approximate' do
				d = Parser.new.parse('2004?-06-(11)~')

				expect(d.approximate?(:year)).to be false
				expect(d.uncertain?(:year)).to be true

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be false

				expect(d.approximate?(:day)).to be true
				expect(d.uncertain?(:day)).to be false
			end

			it 'parses "(2004-(06)~)?": year uncertain and month is both uncertain and approximate' do
				d = Parser.new.parse!('(2004-(06)~)?')

				expect(d.approximate?(:year)).to be false
				expect(d.uncertain?(:year)).to be true

				expect(d.approximate?(:month)).to be true
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be false
				expect(d.uncertain?(:day)).to be false
			end

			it 'parses "2004~-(06)?-01~": year and day approximate, month uncertain' do
				d = Parser.new.parse!("2004~-(06)?-01~")

				expect(d.approximate?(:year)).to be true
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be true
				expect(d.uncertain?(:day)).to be false
			end

			it 'parses "2004~-(06-(01)~)?": year and day approximate, month and day uncertain' do
				d = Parser.new.parse!("2004~-(06-(01)~)?")

				expect(d.approximate?(:year)).to be true
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be true
				expect(d.uncertain?(:day)).to be true
			end

			it 'parses "2004~-(06)?-01?~": year and day approximate, month and day uncertain' do
				d = Parser.new.parse!("2004~-(06)?-01?~")

				expect(d.approximate?(:year)).to be true
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be true
				expect(d.uncertain?(:day)).to be true
			end

			it 'parses "2004~-(06)?": year approximate, month uncertain' do
				d = Parser.new.parse!("2004~-(06)?")

				expect(d.approximate?(:year)).to be true
				expect(d.uncertain?(:year)).to be false

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be false
				expect(d.uncertain?(:day)).to be false
			end


			it 'parses "2004~-06?": year approximate, year and month uncertain' do
				d = Parser.new.parse!("2004~-06?")

				expect(d.approximate?(:year)).to be true
				expect(d.uncertain?(:year)).to be true

				expect(d.approximate?(:month)).to be false
				expect(d.uncertain?(:month)).to be true

				expect(d.approximate?(:day)).to be false
				expect(d.uncertain?(:day)).to be false

			end



    end
  end
end
