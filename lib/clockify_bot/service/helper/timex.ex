defmodule ParserTimex do
  def gen_hour_string(date, time) do
    Timex.to_datetime({date, time}, "America/Sao_Paulo")
    |> Timex.format("{ISO:Extended:Z}")
  end

  def is_valid_year([year, month, day]) do
    case Timex.is_valid?(%Date{year: year, month: month, day: day}) do
      true -> {year, month, day}
      false -> :error
    end
  end

  def get_duration(h_init, h_end) do
    {uh_init, uh_end} = get_unix_time(h_init, h_end)

    DateTime.diff(uh_init, uh_end)
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end

  defp get_unix_time(h_init, h_end) do
    {:ok, uh_init} = Timex.parse(h_init, "{ISO:Extended:Z}")
    {:ok, uh_end} = Timex.parse(h_end, "{ISO:Extended:Z}")
    {uh_init, uh_end}
  end

  def is_valid_year(_) do
    :error
  end

  def is_valid_time([mm, hh]) do
    case Timex.is_valid_time?({hh, mm, 00}) do
      true -> {hh, mm, 00}
      false -> :error
    end
  end

  def is_valid_time(_) do
    :error
  end

  def init_is_lesser_than_end?(h_init, h_end) do
    {uh_init, uh_end} = get_unix_time(h_init, h_end)

    case Timex.compare(uh_init, uh_end) do
      -1 -> true
      _ -> false
    end
  end
end
