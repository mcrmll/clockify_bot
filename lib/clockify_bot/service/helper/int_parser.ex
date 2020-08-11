defmodule IntParser do
  def to_int_values(values) do
    Enum.reduce(values, [], &parse_int(&1, &2))
  end

  defp parse_int(value, list) do
    case Integer.parse(value, 10) do
      {value, _} -> [value | list]
      :error -> :error
    end
  end
end
