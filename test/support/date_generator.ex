defmodule Cldr.Calendar.Persian.DateGenerator do
  require ExUnitProperties

  # These persian years fit into the range of 1000..3000
  # which is where Astro.equinox is considered accurate
  def generate_date do
    ExUnitProperties.gen all(
                           year <- StreamData.integer(380..2378),
                           month <- StreamData.integer(1..12),
                           day <- StreamData.integer(1..Cldr.Calendar.Persian.days_in_month(year, month))
                         ) do
      {:ok, date} = Date.new(year, month, day, Cldr.Calendar.Persian)
      date
    end
  end
end