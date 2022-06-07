module EDTF

  # TODO use bitmasks instead of arrays

  class Uncertainty < Struct.new(:year, :month, :day)

    attr_reader :hash_base

    def initialize(year = nil, month = nil, day = nil, hash_base = 1)
      @hash_base = hash_base
      super(year, month, day)
    end

    def hash_base=(base)
      @hash_map = false
      @hash_base = base
    end

    def uncertain?(parts = members)
      [*parts].any? { |p| !!send(p) }
    end

    def uncertain!(parts = members)
      [*parts].each { |p| send("#{p}=", true) }
      self
    end

    def certain?(parts = members); !uncertain?(parts); end

    def certain!(parts = members)
      [*parts].each { |p| send("#{p}=", false) }
      self
    end

    def eql?(other)
      hash == other.hash
    end

    def hash
      values.zip(hash_map).reduce(0) { |s, (v, h)|  s + (v ? h : 0) }
    end

    private

    def hash_map
      @hash_map ||= (0...length).map { |i| hash_base << i }
    end

  end


  class Unspecified < Struct.new(:year, :month, :day)

    # U = 'u'.freeze
    X = 'X'.freeze

    def initialize
      super Array.new(4),Array.new(2), Array.new(2)
    end

    def unspecified?(parts = members)
      [*parts].any? { |p| send(p).any? { |u| !!u } }
    end

    def unspecified!(parts = members)
      [*parts].each { |p| send(p).map! { true } }
      self
    end

    def specified?(parts = members); !unspecified?(parts); end

    def specified!(parts = members)
      [*parts].each { |p| send(p).map! { false } }
      self
    end

    alias specific? specified?
    alias unspecific? unspecified?

    alias specific! specified!
    alias unspecific! unspecified!

    private :year=, :month=, :day=

    def to_s
      mask(%w{ ssss ss ss }).join('-')
    end

    def mask(values)
      if values[0] && values[0][0] == "-"
        values[0].delete!("-")
        negative_year = true
      end
      results = values.zip(members.take(values.length)).map do |value, mask|
        value.split(//).zip(send(mask)).map { |v,m| m ? X : v }.join
      end
      results[0] = "-#{results[0]}" if negative_year
      results
    end
  end

end
