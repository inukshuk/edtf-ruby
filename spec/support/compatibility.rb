require 'yaml'
require 'edtf'

module EDTF
  # Reduces a parsed EDTF value to a plain hash of strings, numbers and
  # arrays, so that parse results can be listed in a YAML fixture and
  # compared independently of the classes that represent them.
  #
  # Only non-default attributes are included. To produce the entry for a
  # new input, run:
  #
  #   ruby -Ilib -r./spec/support/compatibility -e \
  #     'puts EDTF::Compatibility.entry(ARGV[0]).to_yaml' '2004-06?'
  #
  module Compatibility
    PARTS = %i[year month day].freeze

    FIXTURES = File.expand_path('../fixtures/compatibility.yml', __dir__)

    module_function

    def fixtures
      YAML.safe_load(File.read(FIXTURES))
    end

    def entry(input)
      value = EDTF.parse(input)
      { 'input' => input }.merge(value.nil? ? { 'rejected' => true } : describe(value))
    end

    def describe(value)
      case value
      when EDTF::Unknown
        { 'type' => 'unknown', 'edtf' => value.edtf }
      when ::DateTime
        describe_date_time(value)
      when ::Date
        describe_date(value)
      when EDTF::Season
        describe_season(value)
      when EDTF::Interval
        describe_interval(value)
      when EDTF::Set
        describe_set(value)
      when EDTF::Decade, EDTF::Century
        describe_epoch(value)
      else
        raise ArgumentError, "cannot describe #{value.class}"
      end
    end

    def describe_date(date)
      result = { 'type' => 'date', 'values' => date.values }
      result['uncertain'] = parts(date, :uncertain?)
      result['approximate'] = parts(date, :approximate?)
      result['unspecified'] = date.unspecified.to_s if date.unspecified?
      result['calendar'] = date.calendar if date.calendar
      result['edtf'] = date.edtf
      compact(result)
    end

    def describe_date_time(date)
      {
        'type' => 'datetime',
        'values' => date.values[0..-2],
        'offset' => date.zone,
        'edtf' => date.edtf
      }
    end

    def describe_season(season)
      compact({
        'type' => 'season',
        'year' => season.year,
        'season' => season.season.to_s,
        'qualifier' => season.qualifier,
        'uncertain' => season.uncertain? || nil,
        'approximate' => season.approximate? || nil,
        'bounds' => bounds(season),
        'edtf' => season.edtf
      })
    end

    def describe_interval(interval)
      {
        'type' => 'interval',
        'from' => endpoint(interval.from),
        'to' => endpoint(interval.to),
        'edtf' => interval.edtf
      }
    end

    def describe_set(set)
      compact({
        'type' => set.choice? ? 'choice' : 'list',
        'earlier' => set.earlier? || nil,
        'later' => set.later? || nil,
        'members' => set.map(&:edtf),
        'edtf' => set.edtf
      })
    end

    def describe_epoch(epoch)
      {
        'type' => epoch.class.name.split('::').last.downcase,
        'year' => epoch.year,
        'bounds' => bounds(epoch),
        'edtf' => epoch.edtf
      }
    end

    def endpoint(value)
      value.is_a?(Symbol) ? value.to_s : describe(value)
    end

    def parts(date, predicate)
      PARTS.select { |part| date.public_send(predicate, part) }.map(&:to_s)
    end

    def bounds(value)
      [value.min.strftime('%Y-%m-%d'), value.max.strftime('%Y-%m-%d')]
    end

    def compact(hash)
      hash.reject { |_, v| v.nil? || v == [] }
    end
  end
end
