defmodule Cldr.Calendar.PersianTest do
  use ExUnit.Case

  doctest Cldr.Calendar.Persian

  test "Persian calendar localization" do
    {:ok, date} = Date.new(1354,1,1, Cldr.Calendar.Persian)

    assert Cldr.Calendar.localize(date, :month, locale: "en") == "Farvardin"
    assert Cldr.Calendar.localize(date, :month, locale: "fa") ==  "فروردین"
    assert Cldr.Calendar.localize(date, :day_of_week, locale: "fa") == "جمعه"
    assert Cldr.Calendar.localize(date, :day_of_week, locale: "en") == "Fri"
  end

  test "day of week" do
    {:ok, gregorian_date} = Date.new(2019,12,9, Cldr.Calendar.Gregorian)
    {:ok, persian_date} = Date.convert(gregorian_date, Cldr.Calendar.Persian)
    assert Cldr.Calendar.day_of_week(persian_date) == 1
  end

end
