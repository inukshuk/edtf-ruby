module EDTF

  # EDTF covers seasons and other divisions of a year (ISO 8601-2 codes 21–41),
  # and EDTF-Ruby provides a dedicated class for them:
  #
  #   21–24  spring, summer, autumn, winter (meteorological, northern)
  #   25–28  the same, northern hemisphere
  #   29–32  spring, summer, autumn, winter, southern hemisphere
  #   33–36  quarters
  #   37–39  quadrimesters (four months each)
  #   40–41  semesters
  #
  # Note that EDTF does not make any assumption about the specifics
  # (which months etc.) of the seasons;
  # EDTF-Ruby uses meteorological seasons (three month periods),
  # so winter (24, 28) and southern summer (30) reach into the next year.
  #
  # Qualifier and unspecified bitmasks cover the year and the code
  # like a year and a month (2001-21?, 2001?-21, 200X-21).
  class Season
    include Period

    # The first month and the number of months of each division.
    DIVISIONS = {
      21 => [3, 3], 22 => [6, 3], 23 => [9, 3], 24 => [12, 3],
      25 => [3, 3], 26 => [6, 3], 27 => [9, 3], 28 => [12, 3],
      29 => [9, 3], 30 => [12, 3], 31 => [3, 3], 32 => [6, 3],
      33 => [1, 3], 34 => [4, 3], 35 => [7, 3], 36 => [10, 3],
      37 => [1, 4], 38 => [5, 4], 39 => [9, 4],
      40 => [1, 6], 41 => [7, 6]
    }.freeze

    # The divisions that follow each other, in calendar order.
    CYCLES = [
      [21, 22, 23, 24], [25, 26, 27, 28], [31, 32, 29, 30],
      [33, 34, 35, 36], [37, 38, 39], [40, 41]
    ].freeze

    WHOLE = Bitmask::YM

    attr_reader :year, :season

    def initialize(year, season, uncertain: nil, approximate: nil, unspecified: nil)
      @year = Integer(year)
      @season = Integer(season)
      raise ArgumentError, "invalid season: #{season}" unless DIVISIONS.key?(@season)

      @uncertain = bits(uncertain)
      @approximate = bits(approximate)
      @unspecified = Bitmask.new(Bitmask.convert(unspecified) & Bitmask::YEAR)
      freeze
    end

    attr_reader :uncertain, :approximate, :unspecified

    def precision
      :season
    end

    def values
      [year, season]
    end

    def uncertain?(part = nil)
      qualified?(uncertain, part)
    end

    def approximate?(part = nil)
      qualified?(approximate, part)
    end

    def unspecified?(part = nil)
      qualified?(unspecified, part)
    end

    def with(**changes)
      return self if changes.empty?

      attributes = %i[year season uncertain approximate unspecified]
      check_keys!(changes, attributes)

      values = attributes.to_h { |name| [name, changes.fetch(name) { send(name) }] }
      self.class.new(values.delete(:year), values.delete(:season), **values)
    end

    def begin
      first, = DIVISIONS[season]
      ::Date.new(years.first, first, 1, ::Date::GREGORIAN)
    end

    def end
      first, months = DIVISIONS[season]
      ::Date.new(years.last, first, 1, ::Date::GREGORIAN).next_month(months).prev_day
    end

    # Returns the next season, or division of the same kind, in calendar order.
    # Unspecified digits step by the unit they leave open.
    def succ(by = 1)
      cycle = CYCLES.find { |codes| codes.include?(season) }
      shift, index = (cycle.index(season) + by).divmod(cycle.length)

      year = self.year + shift
      unless unspecified.zero? || shift.zero?
        year = (shift.positive? ^ year.negative? ? years.last : years.first) + shift
        year = unspecified.min([year.abs])[0] * (year.negative? ? -1 : 1)
      end

      with(year: year, season: cycle[index])
    end

    alias next succ

    def prev(by = 1)
      succ(-by)
    end

    def edtf
      sign = year.negative? ? '-' : ''
      values = [format('%04d', year.abs), season.to_s]

      return sign + unspecified.masks(values).join('-') unless unspecified.zero?

      values = uncertain.marks(values, '?') unless uncertain.zero?
      values = approximate.marks(values, '~').map { |value| value.sub(/~\?|\?~/, '%') } unless approximate.zero?

      sign + values.join('-')
    end

    protected

    def state
      [year, season, uncertain.value, approximate.value, unspecified.value]
    end

    private

    def bits(value)
      mask = value == true ? WHOLE : Bitmask.convert(value)
      Bitmask.new(mask & WHOLE)
    end

    def qualified?(mask, part)
      part.nil? ? !mask.zero? : mask.intersect?(part)
    end

    # The first and last year the unspecified digits allow.
    def years
      return year..year if unspecified.zero?

      low, = unspecified.min([year.abs])
      high, = unspecified.max([year.abs])
      year.negative? ? -high..-low : low..high
    end
  end

end
