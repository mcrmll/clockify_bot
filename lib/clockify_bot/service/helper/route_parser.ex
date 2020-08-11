defmodule ClockifyBot.RouteParser do

  def get_config(body_params) do
    ConfigParser.get_config(body_params)
  end

  def point_self(body_params) do
    DateParser.get_date_info(body_params)
  end

end
