defmodule ClockifyBot.Config do
  alias ClockifyBot.Service, as: Service

  def config(slack_id, api_key) do
    get_user_info(api_key)
    |> config_user_info(api_key, slack_id)
  end

  defp config_user_info({:ok, info_map}, api_key, slack_id) do
    ClockifyBot.User.save_user(
      slack_id,
      Map.get(info_map, "id"),
      Map.get(info_map, "defaultWorkspace"),
      api_key
    )
    {:ok, "You're ready to go!"}
  end

  defp config_user_info({:error, _info_map}, _api_key, _slack_id) do
    {:error, "Verify your API KEY."}
  end

  defp get_user_info(api_key) do
    Service.send_request("/user", api_key)
  end
end
