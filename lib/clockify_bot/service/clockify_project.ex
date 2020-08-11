defmodule ClockifyBot.Project do
  alias ClockifyBot.Service, as: Service

  def my_projects(workspace_id, api_key) do
    case get_projects(workspace_id, api_key) do
      {:error, message} -> message
      {:ok, projects} -> format_output(projects)
    end
  end

  def get_projects(workspace_id, api_key) do
    find_projects(workspace_id, api_key)
    |> format_projects
  end

  def format_output(projects) do
    Map.keys(projects)
    |> Enum.reduce("", &(&2 <> format_key(&1)))
  end

  defp format_key({p_name, p_client}) do
    case p_client do
      "" -> "Project: #{p_name} Client: Not specified yet \n"
      _ -> "Project: #{p_name} Client: #{p_client} \n"
    end
  end

  defp find_projects(workspace_id, api_key) do
    Service.send_request("/workspaces/#{workspace_id}/projects", api_key)
  end

  defp format_projects({:ok, projects}) do
    {:ok,
     Enum.reduce(
       projects,
       %{},
       &Map.put(&2, {format_field(&1, "name"), format_field(&1, "clientName")}, Map.get(&1, "id"))
     )}
  end

  defp format_projects({:error, status_code}) do
    {:error, "#{status_code} - Something went wrong ):"}
  end

  defp format_field(map, field) do
    Map.get(map, field)
    |> String.downcase()
  end
end
