defmodule Cldr.Calendar.Persian.NewYear.Test do
  use ExUnit.Case

  test "Gregorian new year start and end" do
    for [_, from_day, _, from_year, to_day, _, _, _] <- Cldr.Calendar.Persian.TestData.new_year() do
      {:ok, start_date} = Cldr.Calendar.Persian.new_year_gregorian(from_year)
      {:ok, next_year_start} = Cldr.Calendar.Persian.new_year_gregorian(from_year + 1)
      end_date = Date.add(next_year_start, -1)
      assert start_date.day == from_day
      assert end_date.day == to_day
    end
  end

  test "leap years" do
    for [persian_year, _, _, _, _, _, _, leap_year?] <- Cldr.Calendar.Persian.TestData.new_year() do
      assert Cldr.Calendar.Persian.leap_year?(persian_year) == leap_year?
    end
  end

  test "conversion of Persian date to Gregorian Date" do
    for [persian_year, from_day, _, from_year, to_day, _, to_year, _] <- Cldr.Calendar.Persian.TestData.new_year() do
      {:ok, first_day} = Date.new(persian_year, 1, 1, Cldr.Calendar.Persian)

      days_in_month = Cldr.Calendar.Persian.days_in_month(persian_year, 12)
      {:ok, last_day} = Date.new(persian_year, 12, days_in_month, Cldr.Calendar.Persian)

      {:ok, first_gregorian_day} = Date.convert(first_day, Calendar.ISO)
      {:ok, last_gregorian_day} = Date.convert(last_day, Calendar.ISO)

      assert first_gregorian_day.day == from_day
      assert first_gregorian_day.year == from_year

      assert last_gregorian_day.day == to_day
      assert last_gregorian_day.year == to_year
    end
  end

end