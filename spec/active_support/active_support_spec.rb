# EDTF-Ruby does not depend on ActiveSupport, but its dates and
# date-times inherit from ::Date and ::Time, which ActiveSupport patches.
# These examples run in their own process (rake spec:active_support),
# because ActiveSupport cannot be unloaded.
require 'active_support/all'
require 'json'

describe 'EDTF with ActiveSupport' do
  around do |example|
    Time.use_zone('Berlin') { example.run }
  end

  describe 'JSON' do
    %w[2004-06? 2016-05-02T16:54:59 Y-17E7 196x 2001-21? 2004-06?/.. [1667,1668..1670] {1984~,1985}].each do |string|
      it "keeps the EDTF string of #{string}" do
        value = EDTF.parse!(string)
        expect(value.as_json).to eq(value.edtf)
        expect(JSON.parse([value].to_json)).to eq([value.edtf])
      end
    end
  end

  describe 'dates' do
    let(:d) { EDTF.parse('2004-06?') }

    it 'return plain dates from duration math and calculations' do
      expect(d + 1.month).to be_instance_of(::Date).and eq(::Date.new(2004, 7, 1))
      expect(d.advance(months: 1)).to be_instance_of(::Date).and eq(::Date.new(2004, 7, 1))
      expect(d.change(day: 15)).to be_instance_of(::Date).and eq(::Date.new(2004, 6, 15))
      expect(d.end_of_month).to be_instance_of(::Date).and eq(::Date.new(2004, 6, 30))
      expect(d.tomorrow).to be_instance_of(::Date)
    end

    it 'format their first day' do
      expect(d.to_fs(:db)).to eq('2004-06-01')
    end

    it 'compare with times in a zone' do
      zoned = Time.zone.local(2004, 6, 11, 7, 30)
      expect(EDTF.parse('2004-06-11') <=> zoned).to eq(-1)
      expect(EDTF.parse('2004-06')).to be_cover(zoned)
      expect(EDTF.parse('2004-07')).not_to be_cover(zoned)
    end
  end

  describe 'date-times' do
    let(:t) { EDTF.parse('2004-06-11T10:30:00+05:00') }

    it 'return plain times from duration math and calculations' do
      expect(t + 1.hour).to be_instance_of(::Time)
      expect(t.advance(days: 1)).to be_instance_of(::Time)
      expect(t.change(hour: 1)).to be_instance_of(::Time)
      expect(t.beginning_of_day).to be_instance_of(::Time)
    end

    it 'equal times in a zone at the same instant' do
      zoned = Time.zone.local(2004, 6, 11, 7, 30)
      expect(t).to eq(zoned)
      expect(zoned).to eq(t)
      expect(t).not_to eql(zoned)
    end

    it 'convert from times in a zone' do
      converted = EDTF(Time.zone.local(2004, 6, 11, 7, 30))
      expect(converted).to be_an(EDTF::DateTime)
      expect(converted.edtf).to eq('2004-06-11T07:30:00+02:00')
    end
  end
end
