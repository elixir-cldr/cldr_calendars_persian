defmodule Cldr.Calendar.Persian do
  @moduledoc """
  The present Iranian calendar was legally adopted on 31
  March 1925, under the early Pahlavi dynasty. The law
  said that the first day of the year should be the
  first day of spring in "the true solar year", "as it
  has been" ever so. It also fixes the number of days
  in each month, which previously varied by year with
  the sidereal zodiac.

  It revived the ancient Persian names, which are still
  used. It specifies the origin of the calendar to be
  the Hegira of Muhammad from Mecca to Medina in 622 CE).

  """
  @behaviour Calendar
  @behaviour Cldr.Calendar

  @type year :: -9999..-1 | 1..9999
  @type month :: 1..12
  @type day :: 1..31

  @quarters_in_year 4
  @months_in_year 12
  @months_in_quarter 3
  @days_in_week 7

  @mean_tropical_year 365.24219

  @doc """
  Defines the CLDR calendar type for this calendar.

  This type is used in support of `Cldr.Calendar.
  localize/3`.

  """
  @impl true
  def cldr_calendar_type do
    :persian
  end

  @doc """
  Identifies that this calendar is month based.
  """
  @impl true
  def calendar_base do
    :month
  end

  @epoch Cldr.Calendar.Julian.date_to_iso_days(622, 3, 19)
  def epoch do
    @epoch
  end

  @doc """
  Determines if the date given is valid according to
  this calendar.

  """
  @impl true
  @months_with_30_days 7..11
  def valid_date?(_year, month, day) when month in @months_with_30_days and day in 1..30 do
    true
  end

  @months_with_31_days 1..6
  def valid_date?(_year, month, day) when month in @months_with_31_days and day in 1..31 do
    true
  end

  def valid_date?(year, 12, 30) do
    if leap_year?(year), do: true, else: false
  end

  def valid_date?(_year, 12, day) when day in 1..29 do
    true
  end

  def valid_date?(_year, _month, _day) do
    false
  end

  @doc """
  Calculates the year and era from the given `year`.
  The ISO calendar has two eras: the current era which
  starts in year 1 and is defined as era "1". And a
  second era for those years less than 1 defined as
  era "0".

  """
  @spec year_of_era(year) :: {year, era :: 0..1}
  @impl true
  def year_of_era(year) when year > 0 do
    {year, 1}
  end

  def year_of_era(year) when year < 0 do
    {abs(year), 0}
  end

  @doc """
  Calculates the quarter of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 4.

  """
  @spec quarter_of_year(year, month, day) :: 1..4
  @impl true
  def quarter_of_year(_year, month, _day) do
    Float.ceil(month / @months_in_quarter)
    |> trunc
  end

  @doc """
  Calculates the month of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 12.

  """
  @spec month_of_year(year, month, day) :: month
  @impl true
  def month_of_year(_year, month, _day) do
    month
  end

  @doc """
  Calculates the week of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 53.

  """
  @spec week_of_year(year, month, day) :: {:error, :not_defined}
  @impl true
  def week_of_year(_year, _month, _day) do
    {:error, :not_defined}
  end

  @doc """
  Calculates the ISO week of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 53.

  """
  @spec iso_week_of_year(year, month, day) :: {:error, :not_defined}
  @impl true
  def iso_week_of_year(_year, _month, _day) do
    {:error, :not_defined}
  end

  @doc """
  Calculates the week of the year from the given `year`, `month`, and `day`.
  It is an integer from 1 to 53.

  """
  @spec week_of_month(year, month, day) :: {pos_integer(), pos_integer()} | {:error, :not_defined}
  @impl true
  def week_of_month(_year, _month, _day) do
    {:error, :not_defined}
  end

  @doc """
  Calculates the day and era from the given `year`, `month`, and `day`.

  """
  @spec day_of_era(year, month, day) :: {day :: pos_integer(), era :: 0..1}
  @impl true
  def day_of_era(year, month, day) do
    {_, era} = year_of_era(year)
    days = date_to_iso_days(year, month, day)
    {days + epoch(), era}
  end

  @doc """
  Calculates the day of the year from the given `year`, `month`, and `day`.

  """
  @spec day_of_year(year, month, day) :: 1..366
  @impl true
  def day_of_year(year, month, day) do
    first_day = date_to_iso_days(year, 1, 1)
    this_day = date_to_iso_days(year, month, day)
    this_day - first_day + 1
  end

  @doc """
  Calculates the day of the week from the given `year`, `month`, and `day`.
  It is an integer from 1 to 7, where 1 is Monday and 7 is Sunday.

  """
  @spec day_of_week(year, month, day) :: 1..7
  @impl true
  @epoch_day_of_week 5
  def day_of_week(year, month, day) do
    days = date_to_iso_days(year, month, day)
    days_after_saturday = rem(days, 7)
    Cldr.Math.amod(days_after_saturday + @epoch_day_of_week, @days_in_week)
  end

  @doc """
  Calculates the number of period in a given `year`. A period
  corresponds to a month in month-based calendars and
  a week in week-based calendars..

  """
  @impl true
  def periods_in_year(_year) do
    @months_in_year
  end

  @impl true
  def weeks_in_year(_year) do
    {:error, :not_defined}
  end

  @doc """
  Returns the number days in a given year.

  """
  @impl true
  def days_in_year(year) do
    if leap_year?(year), do: 366, else: 365
  end

  @doc """
  Returns how many days there are in the given year-month.

  """
  @spec days_in_month(year, month) :: 29..31
  @impl true

  def days_in_month(year, 12) do
    if leap_year?(year), do: 30, else: 29
  end

  def days_in_month(_year, month) when month in @months_with_30_days do
    30
  end

  def days_in_month(_year, month) when month in @months_with_31_days do
    31
  end

  @doc """
  Returns the number days in a a week.

  """
  def days_in_week do
    @days_in_week
  end

  @doc """
  Returns a `Date.Range.t` representing
  a given year.

  """
  @impl true
  def year(year) do
    last_month = months_in_year(year)
    days_in_last_month = days_in_month(year, last_month)

    with {:ok, start_date} <- Date.new(year, 1, 1, __MODULE__),
         {:ok, end_date} <- Date.new(year, last_month, days_in_last_month, __MODULE__) do
      Date.range(start_date, end_date)
    end
  end

  @doc """
  Returns a `Date.Range.t` representing
  a given quarter of a year.

  """
  @impl true
  def quarter(year, quarter) do
    months_in_quarter = div(months_in_year(year), @quarters_in_year)
    starting_month = months_in_quarter * (quarter - 1) + 1
    starting_day = 1

    ending_month = starting_month + months_in_quarter - 1
    ending_day = days_in_month(year, ending_month)

    with {:ok, start_date} <- Date.new(year, starting_month, starting_day, __MODULE__),
         {:ok, end_date} <- Date.new(year, ending_month, ending_day, __MODULE__) do
      Date.range(start_date, end_date)
    end
  end

  @doc """
  Returns a `Date.Range.t` representing
  a given month of a year.

  """
  @impl true
  def month(year, month) do
    starting_day = 1
    ending_day = days_in_month(year, month)

    with {:ok, start_date} <- Date.new(year, month, starting_day, __MODULE__),
         {:ok, end_date} <- Date.new(year, month, ending_day, __MODULE__) do
      Date.range(start_date, end_date)
    end
  end

  @doc """
  Returns a `Date.Range.t` representing
  a given week of a year.

  """
  @impl true
  def week(_year, _week) do
    {:error, :not_defined}
  end

  @doc """
  Adds an `increment` number of `date_part`s
  to a `year-month-day`.

  `date_part` can be `:quarters`
   or`:months`.

  """
  @impl true
  def plus(year, month, day, date_part, increment, options \\ [])

  def plus(year, month, day, :quarters, quarters, options) do
    months = quarters * @months_in_quarter
    plus(year, month, day, :months, months, options)
  end

  def plus(year, month, day, :months, months, options) do
    months_in_year = months_in_year(year)
    {year_increment, new_month} = Cldr.Math.div_amod(month + months, months_in_year)
    new_year = year + year_increment

    new_day =
      if Keyword.get(options, :coerce, false) do
        max_new_day = days_in_month(new_year, new_month)
        min(day, max_new_day)
      else
        day
      end

    {new_year, new_month, new_day}
  end

  @doc """
  Returns if the given year is a leap year.

  Since this calendar is observational we
  calculate the start of successive years
  and then calcualate the difference in
  days to determine if its a leap year.

  """
  @spec leap_year?(year) :: boolean()
  @impl true
  def leap_year?(year) do
    new_year = date_to_iso_days(year, 1, 1)
    next_year = date_to_iso_days(year + 1, 1, 1)
    next_year - new_year == 366
  end

  @doc """
  Returns the Gregorian date of the
  Persian new year for a given
  Gregorian year
  """
  def new_year_gregorian(year) do
    {:ok, equinox} = vernal_equinox(year)
    {:ok, solar_noon} = midday_in_tehran(equinox)

    if Time.compare(equinox, solar_noon) in [:gt, :eq] do
      Date.new(equinox.year, equinox.month, equinox.day + 1)
    else
      Date.new(equinox.year, equinox.month, equinox.day)
    end
  end

  @doc """
  Returns the Gregorian date of the
  Persian last day of a given
  Gregorian year
  """
  def year_end_gregorian(year) do
    {:ok, new_year} = new_year_gregorian(year + 1)
    {:ok, Date.add(new_year, -1)}
  end

  @tehran %Geo.PointZ{coordinates: {51.3890, 35.6892, 1100}}

  defp midday_in_tehran(date) do
    Astro.solar_noon(@tehran, date)
  end

  defp vernal_equinox(year) do
    Astro.equinox(year, :march)
  end

  @doc """
  Returns the number of days since the calendar
  epoch for a given `year-month-day`

  """
  def date_to_iso_days(year, month, day) do
    new_year =
      new_year_on_or_before(epoch() + 180 +
        :math.floor(@mean_tropical_year * if(0 < year, do: year - 1, else: year)) |> trunc)
    new_year - 1 + if(month <= 7, do: 31 * (month - 1), else: 30 * (month - 1) + 6) + day
  end

  @doc """
  Returns a `{year, month, day}` calculated from
  the number of `iso_days`.

  """
  def date_from_iso_days(iso_days) do
    new_year_iso_days = new_year_on_or_before(iso_days)
    y = round((new_year_iso_days - epoch()) / @mean_tropical_year) + 1
    year = if y > 0, do: y, else: y - 1
    day_of_year = 1 + iso_days - date_to_iso_days(year, 1, 1)

    month = if day_of_year <= 186, do: ceil(day_of_year / 31),
             else: :math.ceil((day_of_year - 6) / 30)

    day = iso_days - date_to_iso_days(year, month, 1) + 1
    {year, trunc(month), trunc(day)}
  end

  def new_year_on_or_before(iso_days) when is_integer(iso_days) do
    {year, month, day} = Cldr.Calendar.Gregorian.date_from_iso_days(iso_days)
    {:ok, date} = Date.new(year, month, day)
    {:ok, new_year_gregorian} = new_year_gregorian(year)
    {:ok, prior_year_gregorian} = new_year_gregorian(year - 1)

    new_year =
      if Date.compare(new_year_gregorian, date) == :gt do
        prior_year_gregorian
      else
        new_year_gregorian
      end
    Cldr.Calendar.Gregorian.date_to_iso_days(new_year.year, new_year.month, new_year.day)
  end

  @doc """
  Returns the `t:Calendar.iso_days/0` format of the specified date.

  """
  @impl true
  @spec naive_datetime_to_iso_days(
          Calendar.year(),
          Calendar.month(),
          Calendar.day(),
          Calendar.hour(),
          Calendar.minute(),
          Calendar.second(),
          Calendar.microsecond()
        ) :: Calendar.iso_days()

  def naive_datetime_to_iso_days(year, month, day, hour, minute, second, microsecond) do
    {date_to_iso_days(year, month, day), time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts the `t:Calendar.iso_days/0` format to the datetime format specified by this calendar.

  """
  @spec naive_datetime_from_iso_days(Calendar.iso_days()) :: {
          Calendar.year(),
          Calendar.month(),
          Calendar.day(),
          Calendar.hour(),
          Calendar.minute(),
          Calendar.second(),
          Calendar.microsecond()
        }
  @impl true
  def naive_datetime_from_iso_days({days, day_fraction}) do
    {year, month, day} = date_from_iso_days(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
  end

  @doc false
  defdelegate day_rollover_relative_to_midnight_utc, to: Calendar.ISO

  @doc false
  defdelegate months_in_year(year), to: Calendar.ISO

  @doc false
  defdelegate time_from_day_fraction(day_fraction), to: Calendar.ISO

  @doc false
  defdelegate time_to_day_fraction(hour, minute, second, microsecond), to: Calendar.ISO

  # Calendar callbacks that appear in Elixir 1.10
  if Version.match?(System.version(), ">= 1.10.0-dev") do
    @doc false
    defdelegate parse_date(date_string), to: Calendar.ISO

    @doc false
    defdelegate parse_time(time_string), to: Calendar.ISO

    @doc false
    defdelegate parse_utc_datetime(dt_string), to: Calendar.ISO

    @doc false
    defdelegate parse_naive_datetime(dt_string), to: Calendar.ISO
  end

  @doc false
  defdelegate date_to_string(year, month, day), to: Calendar.ISO

  @doc false
  defdelegate datetime_to_string(
                year,
                month,
                day,
                hour,
                minute,
                second,
                microsecond,
                time_zone,
                zone_abbr,
                utc_offset,
                std_offset
              ),
              to: Calendar.ISO

  @doc false
  defdelegate naive_datetime_to_string(
                year,
                month,
                day,
                hour,
                minute,
                second,
                microsecond
              ),
              to: Calendar.ISO

  @doc false
  defdelegate time_to_string(hour, minute, second, microsecond), to: Calendar.ISO

  @doc false
  defdelegate valid_time?(hour, minute, second, microsecond), to: Calendar.ISO
end
