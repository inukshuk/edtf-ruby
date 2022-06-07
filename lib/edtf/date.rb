class Date

  PRECISION = [:year, :month, :day].freeze
  PRECISIONS = Hash[*PRECISION.map { |p| [p, "#{p}s".to_sym] }.flatten].freeze

  FORMATS = %w{ %04d %02d %02d }.freeze

  SYMBOLS = {
    :uncertain   => '?',
    :approximate => '~',
    :calendar    => '^',
    :unspecified => 'X'
  }.freeze

  EXTENDED_ATTRIBUTES = %w{
    calendar precision uncertain approximate unspecified skip_timezone
  }.map(&:to_sym).freeze

  extend Forwardable

  class << self

    def edtf(input, options = {})
      edtf!(input, options)
    rescue
      nil
    end

    def edtf!(input, options = {})
      ::EDTF::Parser.new(options).parse!(input)
    end
  end

  attr_accessor :calendar, :skip_timezone

  PRECISION.each do |p|
    define_method("#{p}_precision?") { precision == p }

    define_method("#{p}_precision!") do
      self.precision = p
      self
    end

    define_method("#{p}_precision") do
      change(:precision => p)
    end
  end


  alias original_initialize_copy initialize_copy

  def initialize_copy(other)
    original_initialize_copy(other)
    copy_extended_attributes(other)
  end


  # Alias advance method from Active Support.
  alias original_advance advance

  # Provides precise Date calculations for years, months, and days.  The +options+ parameter takes a hash with
  # any of these keys: <tt>:years</tt>, <tt>:months</tt>, <tt>:weeks</tt>, <tt>:days</tt>.
  def advance(options)
    original_advance(options).copy_extended_attributes(self)
  end

  # Alias change method from Active Support.
  alias original_change change

  # Returns a new Date where one or more of the elements have been changed according to the +options+ parameter.
  def change(options)
    d = original_change(options)
    EXTENDED_ATTRIBUTES.each do |attribute|
      d.send("#{attribute}=", options[attribute] || send(attribute))
    end
    d
  end


  # Returns this Date's precision.
  def precision
    @precision ||= :day
  end

  # Sets this Date/Time's precision to the passed-in value.
  def precision=(precision)
    precision = precision.to_sym
    raise ArgumentError, "invalid precision #{precision.inspect}" unless PRECISION.include?(precision)
    @precision = precision
    update_precision_filter[-1]
  end

  def uncertain
    @uncertain ||= EDTF::Uncertainty.new
  end

  def approximate
    @approximate ||= EDTF::Uncertainty.new(nil, nil, nil, 8)
  end

  def unspecified
    @unspecified ||= EDTF::Unspecified.new
  end

  def_delegators :uncertain, :uncertain?, :certain?

  def certain!(arguments = precision_filter)
    uncertain.certain!(arguments)
    self
  end

  def uncertain!(arguments = precision_filter)
    uncertain.uncertain!(arguments)
    self
  end

  def approximate?(arguments = precision_filter)
    approximate.uncertain?(arguments)
  end

  alias approximately? approximate?

  def approximate!(arguments = precision_filter)
    approximate.uncertain!(arguments)
    self
  end

  alias approximately! approximate!

  def precise?(arguments = precision_filter)
    !approximate?(arguments)
  end

  alias precisely? precise?

  def precise!(arguments = precision_filter)
    approximate.certain!(arguments)
    self
  end

  alias precisely! precise!

  def_delegators :unspecified, :unspecified?, :specified?, :unspecific?, :specific?

  def unspecified!(arguments = precision_filter)
    unspecified.unspecified!(arguments)
    self
  end

  alias unspecific! unspecified!

  def specified!(arguments = precision_filter)
    unspecified.specified!(arguments)
    self
  end

  alias specific! specified!

  # Returns false for Dates.
  def season?; false; end

  # Returns true if the Date has an EDTF calendar string attached.
  def calendar?; !!@calendar; end

  # Returns true if the Date's EDTF string should be printed without timezone.
  def skip_timezone?; !!@skip_timezone; end

  # Converts the Date into a season.
  def season
    Season.new(self)
  end

  # Returns the Date's EDTF string.
  def edtf
    return "Y#{year}" if long_year?

    v = values
    s = FORMATS.take(v.length).zip(v).map { |f,d| f % d.abs }
    s[0] = "-#{s[0]}" if year < 0
    s = unspecified.mask(s)

    unless (h = ua_hash).zero?
      #
      # To efficiently calculate the uncertain/approximate state we use
      # the bitmask. The primary flags are:
      #
      # Uncertain:    1 - year,  2 - month,  4 - day
      # Approximate:  8 - year, 16 - month, 32 - day
      #
      # Invariant: assumes that uncertain/approximate are not set for values
      # not covered by precision!
      #
      y, m, d = s

      # ?/~ if true-false or true-true and other false-true
      y << SYMBOLS[:uncertain]   if  3&h==1 || 27&h==19
      y << SYMBOLS[:approximate] if 24&h==8 || 27&h==26


      # combine if false-true-true and other m == d
      if 7&h==6 && (48&h==48 || 48&h==0)  || 56&h==48 && (6&h==6 || 6&h==0)
        m[0,0] = '('
        d << ')'
      else
        case
        # false-true
        when 3&h==2 || 24&h==16
          m[0,0] = '('
          m << ')'

        # *-false-true
        when 6&h==4 || 48&h==32
          d[0,0] = '('
          d << ')'
        end

        # ?/~ if *-true-false or *-true-true and other m != d
        m << SYMBOLS[:uncertain]   if h!=31 && (6&h==2  ||  6&h==6  && (48&h==16 || 48&h==32))
        m << SYMBOLS[:approximate] if h!=59 && (48&h==16 || 48&h==48 && (6&h==2 || 6&h==4))
      end

      # ?/~ if *-*-true
      d << SYMBOLS[:uncertain]   if  4&h==4
      d << SYMBOLS[:approximate] if 32&h==32
    end

    s = s.join('-')
    s << SYMBOLS[:calendar] << calendar if calendar?
    s
  end

  alias to_edtf edtf

  remove_method :next

  # Returns an array of the next n days, months, or years depending on the
  # current Date/Time's precision.
  def next(n = 1)
    1.upto(n).map { |by| advance(PRECISIONS[precision] => by) }
  end

  remove_method :succ

  def succ
    advance(PRECISIONS[precision] => 1)
  end

  # Returns the Date of the previous day, month, or year depending on the
  # current Date/Time's precision.
  def prev(n = 1)
    if n > 1
      1.upto(n).map { |by| advance(PRECISIONS[precision] => -by) }
    else
      advance(PRECISIONS[precision] => -1)
    end
  end

  def <=>(other)
    case other
    when ::Date
      values <=> other.values
    when EDTF::Interval, EDTF::Season, EDTF::Epoch
      other.cover?(self) ? other.min <=> self : 0
    else
      nil
    end
  end


  # Returns an array of the current year, month, and day values filtered by
  # the Date/Time's precision.
  def values
    precision_filter.map { |p| send(p) }
  end

  # Returns the same date but with negated year.
  def negate
    change(:year => year * -1)
  end

  alias -@ negate

  # Returns true if this Date/Time has year precision and the year exceeds four digits.
  def long_year?
    year_precision? && year.abs > 9999
  end


  private

  def ua_hash
    uncertain.hash + approximate.hash
  end

  def precision_filter
    @precision_filter ||= update_precision_filter
  end

  def update_precision_filter
    @precision_filter = case precision
    when :year
      [:year]
    when :month
      [:year,:month]
    else
      [:year,:month,:day]
    end
  end

  protected

  attr_writer :uncertain, :unspecified, :approximate

  def copy_extended_attributes(other)
    @uncertain   = other.uncertain.dup
    @approximate = other.approximate.dup
    @unspecified = other.unspecified.dup

    @calendar    = other.calendar.dup if other.calendar?
    @precision   = other.precision

    self
  end

end
