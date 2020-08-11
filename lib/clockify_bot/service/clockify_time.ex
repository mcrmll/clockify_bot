defmodule ClockifyBot.Time do
  alias ClockifyBot.Service, as: Service
  alias ClockifyBot.Project, as: Project

  def point_self(slack_id, info) do
    fetch_user(slack_id)
    |> point_time(info)
  end

  defp fetch_user(slack_id) do
    ClockifyBot.User.fetch_user(slack_id)
  end

  defp point_time({:ok, user}, info) do
    Project.get_projects(user.workspace, user.api_key)
    |> add_hours(user, info)
  end

  defp point_time({:error, message}, _info) do
    {:error, message}
  end

  defp add_hours({:ok, projects}, user, %{
         p_name: p_name,
         client: client,
         h_init: h_init,
         h_end: h_end
       }) do
    case Map.get(projects, {p_name, client}) do
      nil -> set_project_time(:error, projects)
      project_id -> set_project_time(user, project_id, h_init, h_end)
    end
  end

  # ClockifyBot.command(:point_self, "1", %{p_name:"memes", client: "", h_init: "2020-06-06T13:00:00.000Z", h_end: "2020-06-06T15:00:00.000Z")
  defp set_project_time(user, project_id, h_init, h_end) do
    create_request_body(project_id, h_init, h_end)
    |> Service.send_body_request("/workspaces/#{user.workspace}/time-entries", user.api_key)
    |> create_time_message(h_init, h_end)
  end

  defp create_time_message({:ok, _info_map}, h_init, h_end) do
    {:ok, "Done. Time worked: #{ParserTimex.get_duration(h_init, h_end)}"}
  end

  defp create_time_message({:error, status}, _h_init, _h_end) do
    {:error, "Verify your input. Returned status: #{status}"}
  end

  defp create_request_body(project_id, h_init, h_end) do
    Map.new([{"start", h_init}, {"end", h_end}, {"projectId", project_id}])
    |> Jason.encode()
    |> get_json_string
  end

  defp get_json_string({:ok, json}) do
    json
  end

  defp set_project_time(:error, projects) do
    {:error,
     "No project with the informed name. Please use one of the below: \n" <>
       Project.format_output(projects)}
  end
end
