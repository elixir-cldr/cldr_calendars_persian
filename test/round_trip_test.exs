defmodule Cldr.Calendar.Persian.RoundTrip.Test do
  use ExUnit.Case
  use ExUnitProperties

  @max_runs 2_000

  property "next and previous weeks" do
    check all(date <- Cldr.Calendar.Persian.DateGenerator.generate_date(), max_runs: @max_runs) do
      %{year: y, month: m, day: d} = date

      iso_days = Cldr.Calendar.Persian.date_to_iso_days(y,m,d)
      {year, month, day} = Cldr.Calendar.Persian.date_from_iso_days(iso_days)

      assert year == y
      assert month == m
      assert day == d
    end
  end
end