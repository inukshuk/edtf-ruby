# Partly ported from edtf.js test/season.js. Bounds follow decision 5:
# meteorological seasons (edtf.js maps 21-24 to quarters).
module EDTF
  describe Season do
    def season(*values, **attributes)
      Season.new(*values, **attributes)
    end

    it_behaves_like 'a period' do
      let(:period) { season(2001, 21) }
    end

    it_behaves_like 'a period' do
      let(:period) { season(2001, 24, approximate: true) }
    end

    it_behaves_like 'a period', parses: false do
      let(:period) { season(2001, 30) }
    end

    it 'has season precision and two values' do
      expect([season(2001, 21).precision, season(2001, 21).values]).to eq([:season, [2001, 21]])
    end

    it 'rejects invalid codes' do
      expect { season(2001, 20) }.to raise_error(ArgumentError)
      expect { season(2001, 42) }.to raise_error(ArgumentError)
    end

    describe 'bounds' do
      {
        21 => %w[2001-03-01 2001-05-31], 22 => %w[2001-06-01 2001-08-31],
        23 => %w[2001-09-01 2001-11-30], 24 => %w[2001-12-01 2002-02-28],
        25 => %w[2001-03-01 2001-05-31], 28 => %w[2001-12-01 2002-02-28],
        29 => %w[2001-09-01 2001-11-30], 30 => %w[2001-12-01 2002-02-28],
        31 => %w[2001-03-01 2001-05-31], 32 => %w[2001-06-01 2001-08-31],
        33 => %w[2001-01-01 2001-03-31], 34 => %w[2001-04-01 2001-06-30],
        35 => %w[2001-07-01 2001-09-30], 36 => %w[2001-10-01 2001-12-31],
        37 => %w[2001-01-01 2001-04-30], 38 => %w[2001-05-01 2001-08-31],
        39 => %w[2001-09-01 2001-12-31],
        40 => %w[2001-01-01 2001-06-30], 41 => %w[2001-07-01 2001-12-31]
      }.each do |code, bounds|
        it "are #{bounds.join(' and ')} for 2001-#{code}" do
          s = season(2001, code)
          expect([s.begin, s.end].map(&:iso8601)).to eq(bounds)
        end
      end

      it 'include leap days' do
        expect(season(2003, 24).end.iso8601).to eq('2004-02-29')
      end

      it 'cover the years unspecified digits allow' do
        expect(season(2010, 33, unspecified: 'yyyxmmdd').to_range.minmax.map(&:iso8601))
          .to eq(%w[2010-01-01 2019-03-31])
      end

      it 'end the day before the next division begins' do
        [21, 24, 29, 30, 33, 37, 39, 41].each do |code|
          s = season(2016, code)
          expect(s.end + 1).to eq(s.succ.begin)
        end
      end
    end

    describe '#succ and #prev' do
      it 'step through a cycle' do
        expect([1, 2, 3, 4].map { |k| season(2018, 21).succ(k).edtf }).to eq(%w[2018-22 2018-23 2018-24 2019-21])
        expect(season(2018, 25).succ(9).edtf).to eq('2020-26')
        expect([1, 2, 3, 4].map { |k| season(2018, 24).prev(k).edtf }).to eq(%w[2018-23 2018-22 2018-21 2017-24])
        expect(season(2018, 24).prev(9).edtf).to eq('2016-23')
      end

      it 'step through southern seasons in calendar order' do
        # edtf.js steps by code: 30 -> 31 would go back in time.
        expect(season(2018, 29).succ.edtf).to eq('2018-30')
        expect(season(2018, 30).succ.edtf).to eq('2019-31')
        expect(season(2018, 31).prev.edtf).to eq('2017-30')
      end

      it 'step through quarters, quadrimesters and semesters' do
        expect(season(2018, 36).succ.edtf).to eq('2019-33')
        expect(season(2018, 39).succ.edtf).to eq('2019-37')
        expect(season(2018, 40).succ(3).edtf).to eq('2019-41')
      end

      it 'keep qualifiers and step over unspecified digits' do
        expect(season(2018, 21, uncertain: true).succ.edtf).to eq('2018-22?')
        s = season(2010, 24, unspecified: 'yyyxmmdd')
        expect([s.succ, s.prev].map(&:edtf)).to eq(%w[202X-21 201X-23])
        expect(s.succ).to eql(season(2020, 21, unspecified: 'yyyxmmdd'))
      end

      it 'make ranges' do
        expect((season(2001, 23)..season(2002, 22)).map(&:edtf)).to eq(%w[2001-23 2001-24 2002-21 2002-22])
      end
    end

    describe '#edtf' do
      it 'pads the year' do
        expect(season(2014, 23).edtf).to eq('2014-23')
        expect(season(14, 21).edtf).to eq('0014-21')
        expect(season(-14, 21).edtf).to eq('-0014-21')
      end

      it 'marks qualifiers' do
        expect(season(2014, 22, uncertain: true).edtf).to eq('2014-22?')
        expect(season(2014, 22, uncertain: true, approximate: true).edtf).to eq('2014-22%')
        expect(season(2014, 22, uncertain: :year).edtf).to eq('2014?-22')
      end

      it 'masks unspecified digits' do
        expect(season(2014, 22, unspecified: 'yyyxmmdd').edtf).to eq('201X-22')
      end

    end

    describe 'qualifiers' do
      let(:s) { EDTF.parse('2001-21?') }

      it 'test the whole season or a part' do
        expect([s.uncertain?, s.uncertain?(:year), s.uncertain?(:season)]).to eq([true, true, true])
        expect(season(2001, 21, uncertain: :year).uncertain?(:season)).to be false
        expect(s).not_to be_approximate
      end

      it 'are replaced by #with' do
        expect(s.with(uncertain: nil, approximate: true).edtf).to eq('2001-21~')
        expect(s.with(season: 22).edtf).to eq('2001-22?')
        expect { s.with(month: 3) }.to raise_error(ArgumentError)
      end
    end

    describe 'comparison' do
      it '== means the same period; eql? includes qualifiers' do
        expect(season(2001, 21)).to eq(season(2001, 21, uncertain: true))
        expect(season(2001, 21)).not_to eql(season(2001, 21, uncertain: true))
        expect(season(2001, 21)).to eq(season(2001, 25))
        expect(season(2001, 21)).not_to eql(season(2001, 25))
      end

      it 'orders by bounds' do
        expect(season(2001, 22)).to be > season(2001, 21)
        expect(season(2001, 33)).to be < season(2001, 21)
        expect(season(2001, 21) <=> ::Date.new(2001, 4, 1)).to eq(-1)
        expect(::Date.new(2001, 4, 1) <=> season(2001, 21)).to eq(1)
      end

      it 'covers the dates within' do
        expect(season(2001, 24)).to be_cover(::Date.new(2002, 1, 15))
        expect(season(2001, 24)).to be_cover(EDTF.parse('2002-01'))
        expect(season(2001, 24)).not_to be_cover(::Date.new(2001, 11, 30))
      end

      it 'has no include?, as it is not a collection' do
        expect(season(2001, 24)).not_to respond_to(:include?)
      end
    end

    describe 'legacy season qualifiers' do
      it 'become hemisphere seasons' do
        expect(EDTF.parse('2001-21^southern')).to eql(season(2001, 29))
        expect(EDTF.parse('2001-24^northernHemisphere')).to eql(season(2001, 28))
      end

      it 'are dropped otherwise' do
        expect(EDTF.parse('2003-23^european')).to eql(season(2003, 23))
      end
    end

    it 'takes :season as a part' do
      expect(season(2001, 21, uncertain: :season).edtf).to eq('2001-?21')
      expect(season(2010, 21, unspecified: 'yyyxmmdd').unspecified?(:year)).to be true
      expect(season(2010, 21, unspecified: 'yyyxmmdd').unspecified?(:season)).to be false
    end

    it 'stays frozen through Marshal' do
      s = season(2001, 21, approximate: true)
      expect(Marshal.load(Marshal.dump(s))).to be_frozen.and eql(s)
    end
  end
end
