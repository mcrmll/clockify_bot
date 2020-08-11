defmodule ConfigParser do
  def get_config(body_params) do
    user_id = Map.get(body_params, "user_id")
    text = Map.get(body_params, "text")
    {user_id, parse_config(text)}
  end

  defp parse_config(text) do
    String.replace(text, " ", "")
  end
end
