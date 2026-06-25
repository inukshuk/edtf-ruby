module EDTF

  class Set
    extend Forwardable

    include Enumerable
    include Comparable

    def_delegators :@dates, :size, :length, :empty?

    attr_accessor :choice, :later, :earlier


    def initialize(*dates)
      @dates = ::Set.new(dates.flatten)
      @choice, @later, @earlier = false, false, false
    end

    def initialize_copy(other)
      @set = other.to_set
    end

    [:choice, :later, :earlier].each do |m|
      define_method("#{m}?") { send(m) }
      define_method("#{m}!") do
        send("#{m}=", true)
        self
      end
    end

    def include?(v)
      return false unless v.is_a?(Date)
      return false if empty?

      dates_array = to_a
      if earlier?
        (min = dates_array.first) >= v && min.precision == v.precision
      elsif later?
        (max = dates_array.last) <= v && max.precision == v.precision
      else
        dates_array.member?(v)
      end
    end
    alias member? include?

    def <<(date)
      dates << date
      self
    end

    def each(&block)
      if block_given?
        to_a.each(&block)
        self
      else
        to_enum
      end
    end

    def edtf
      parenthesize(dates.map { |d|
        d.respond_to?(:edtf) ? d.edtf : d.to_s
      }.sort.join(','))
    end

    def to_a
      dates.map { |d| Array(d) }.flatten.sort
    end

    def to_set
      to_a.to_set
    end

    alias to_s edtf

    def <=>(other)
      return nil unless other.respond_to?(:to_a)
      to_a <=> other.to_a
    end

    protected

    attr_reader :dates

    private

    def parenthesize(string)
      p = choice? ? %w([ ]) : %w({ })
      p[-1,0] = '..' if earlier?
      p[-1,0] = string unless string.empty?
      p[-1,0] = '..' if later?
      p.join
    end

  end

end
