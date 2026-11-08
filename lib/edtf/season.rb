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

    MASK = Bitmask::YM

    attr_reader :year, :season

    def initialize(year, season, uncertain: nil, approximate: nil, unspecified: nil, calendar: nil, year_zero: true)
      @year = Integer(year)
      @season = Integer(season)
      raise ArgumentError, "invalid season: #{season}" unless DIVISIONS.key?(@season)

      @uncertain = bits(uncertain)
      @approximate = bits(approximate)
      @unspecified = Bitmask.new(Bitmask.convert(unspecified) & Bitmask::YEAR)
      @calendar = Period.calendar(calendar)
      @historical = !year_zero
      freeze
    end

    attr_reader :uncertain, :approximate, :unspecified, :calendar

    # False if years are written without year 0 (1 BC is -0001).
    def year_zero?
      !@historical
    end

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
      self.class.new(values.delete(:year), values.delete(:season), **values, calendar: calendar, year_zero: year_zero?)
    end

    def begin
      first, = DIVISIONS[season]
      ::Date.new(years.first, first, 1, Period.start(calendar))
    end

    def end
      first, months = DIVISIONS[season]
      ::Date.new(years.last, first, 1, Period.start(calendar)).next_month(months).prev_day
    end

    # Returns the next season, or division of the same kind, in calendar order.
    # Unspecified digits step by the unit they leave open.
    def succ(by = 1)
      cycle = CYCLES.find { |codes| codes.include?(season) }
      shift, index = (cycle.index(season) + by).divmod(cycle.length)

      year = self.year + shift
      unless unspecified.zero? || shift.zero?
        year = (shift.positive? ^ written_year.negative? ? years.last : years.first) + shift
        year = Period.written_year(year, year_zero?)
        sign = year.negative? ? -1 : 1
        year = unspecified.min([year.abs])[0]
        year = unspecified.least_year(year) if year.zero? && !year_zero?
        year = Period.astronomical_year(sign * year, year_zero?)
      end

      with(year: year, season: cycle[index])
    end

    alias next succ

    def prev(by = 1)
      succ(-by)
    end

    def edtf
      sign = written_year.negative? ? '-' : ''
      values = [format('%04d', written_year.abs), season.to_s]

      return sign + unspecified.masks(values).join('-') unless unspecified.zero?

      values = uncertain.marks(values, '?') unless uncertain.zero?
      values = approximate.marks(values, '~').map { |value| value.sub(/~\?|\?~/, '%') } unless approximate.zero?

      sign + values.join('-')
    end

    protected

    def state
      [year, season, uncertain.value, approximate.value, unspecified.value, calendar,
        year_zero? || unspecified.zero?]
    end

    private

    def bits(value)
      mask = value == true ? MASK : Bitmask.convert(value)
      Bitmask.new(mask & MASK)
    end

    def qualified?(mask, part)
      part.nil? ? !mask.zero? : mask.intersect?(part)
    end

    def written_year
      Period.written_year(year, year_zero?)
    end

    # The first and last year the unspecified digits allow,
    # from the written year.
    def years
      return year..year if unspecified.zero?

      low, = unspecified.min([written_year.abs])
      high, = unspecified.max([written_year.abs])
      low = unspecified.least_year(low) if low.zero? && !year_zero?
      years = written_year.negative? ? [-high, -low] : [low, high]
      years.map { |year| Period.astronomical_year(year, year_zero?) }.then { |a, b| a..b }
    end
  end

end
