module EDTF

  # EDTF supports two kinds of sets:
  # choice lists, meaning one date out of a list (EDTF::Set, [...]),
  # or inclusive lists (EDTF::List, {...}).
  # Both share their member handling through this module.
  #
  # Sets remember which members were specified as a range;
  # ranges are however enumerated for membership tests:
  #
  #     EDTF('{1667,1668,1670..1672}').values.length       -> 3
  #     EDTF('{1667,1668,1670..1672}').map(&:year)         -> [1667, 1668, 1670, 1671, 1672]
  #
  #     EDTF('{1667,1668,1670..1672}').include? EDTF('1671')  -> true
  #     EDTF('{1667,1668,1670..1672}').include? EDTF('1669')  -> false
  #
  # Sets also feature #earlier? and #later?:
  # an open start (..1667) or end (1672..) without bound.
  module Members
    include Period
    include Enumerable

    attr_reader :values

    def initialize(*values, earlier: false, later: false)
      @values = values.map { |value| coerce(value) }.freeze
      @earlier = !!earlier
      @later = !!later
      freeze
    end

    def earlier?
      @earlier
    end

    def later?
      @later
    end

    def empty?
      values.empty?
    end

    # The precision of the first member.
    def precision
      members.first&.precision
    end

    def begin
      members.map(&:begin).min unless earlier? || empty?
    end

    def end
      members.map(&:end).max unless later? || empty?
    end

    def with(**changes)
      return self if changes.empty?

      unknown = changes.keys - %i[values earlier later]
      raise ArgumentError, "unknown keyword#{'s' if unknown.length > 1}: #{unknown.join(', ')}" unless unknown.empty?

      self.class.new(
        *changes.fetch(:values, values),
        earlier: changes.fetch(:earlier, earlier?),
        later: changes.fetch(:later, later?)
      )
    end

    # Yields each member, enumerating ranges.
    def each(&block)
      return to_enum(:each) unless block_given?

      values.each { |value| value.is_a?(Range) ? value.each(&block) : yield(value) }
      self
    end

    # Returns true if other is one of the (enumerated) members,
    # or lies beyond an open start or end at the same precision.
    def include?(other)
      return false if empty?
      return true if any? { |member| member == other }

      first, last = members.first, members.last
      (earlier? && Period.precision(other) == first.precision && other <= first) ||
        (later? && Period.precision(other) == last.precision && other >= last)
    end

    # Returns a Ruby Set of the enumerated members.
    def to_set
      raise RangeError, "cannot enumerate the open set #{edtf}" if earlier? || later?

      ::Set.new(to_a)
    end

    def eql?(other)
      other.instance_of?(self.class) && state.eql?(other.state)
    end

    def hash
      [self.class, *state].hash
    end

    def edtf
      content = values.map { |value| value.is_a?(Range) ? "#{value.begin.edtf}..#{value.end.edtf}" : value.edtf }
      return wrap('') if content.empty?

      wrap("#{'..' if earlier?}#{content.join(',')}#{'..' if later?}")
    end

    alias to_s edtf

    def inspect
      "#<#{self.class} #{edtf}>"
    end

    protected

    def state
      [values, earlier?, later?]
    end

    private

    # The members as written, with ranges as their two ends.
    def members
      values.flat_map { |value| value.is_a?(Range) ? [value.begin, value.end] : [value] }
    end

    def coerce(value)
      case value
      when Period then value
      when ::Date then EDTF(value)
      when Range then coerce(value.begin)..coerce(value.end)
      else raise ArgumentError, "invalid #{self.class} member: #{value.inspect}"
      end
    end
  end

  # One of a set: [1667,1668,1670..1672].
  class Set
    include Members

    private

    def wrap(content)
      "[#{content}]"
    end
  end

  # All members of a set: {1667,1668,1670..1672}.
  class List
    include Members

    private

    def wrap(content)
      "{#{content}}"
    end
  end

end
