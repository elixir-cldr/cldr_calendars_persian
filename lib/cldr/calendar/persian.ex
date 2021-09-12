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

  use Cldr.Calendar.Behaviour,
    epoch: ~D[0622-03-20 Cldr.Calendar.Julian],
    cldr_calendar_type: :persian

  @mean_tropical_year 365.24219
  @months_with_30_days 7..11
  @months_with_31_days 1..6

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

end
