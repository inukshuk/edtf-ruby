require_relative '../support/compatibility'

describe 'Compatibility baseline' do
  fixtures = EDTF::Compatibility.fixtures

  def describe_value(value)
    EDTF::Compatibility.describe(value)
  end

  (fixtures.keys - %w[rejected unsupported]).each do |section|
    describe section do
      fixtures[section].each do |entry|
        input = entry['input']
        expected = entry.reject { |key, _| %w[input note].include?(key) }

        describe input.inspect do
          let(:value) { EDTF.parse!(input) }

          it "parses as #{expected['edtf'].inspect}" do
            expect(describe_value(value)).to eq(expected)
          end

          it 'round-trips through its EDTF string' do
            expect(describe_value(EDTF.parse!(value.edtf))).to eq(expected)
          end
        end
      end
    end
  end

  describe 'rejected' do
    fixtures['rejected'].each do |entry|
      input = entry['input']

      it "rejects #{input.inspect}" do
        expect(EDTF.parse(input)).to be_nil
        expect { EDTF.parse!(input) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'unsupported' do
    fixtures['unsupported'].each do |entry|
      input = entry['input']

      it "parses #{input.inspect} (#{entry['note']})" do
        pending 'not supported yet'
        expect(EDTF.parse(input)).not_to be_nil
      end
    end
  end
end
