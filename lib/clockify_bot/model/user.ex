defmodule ClockifyBot.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field(:slack_id, :string)
    field(:clockify_id, :string)
    field(:workspace, :string)
    field(:api_key, :string)
  end

  defp changeset(user, params) do
    user
    |> cast(params, [:slack_id, :clockify_id, :workspace, :api_key])
  end

  def save_user(slack_id, id, workspace, api_key) do
    user_params = %ClockifyBot.User{
      slack_id: slack_id,
      clockify_id: id,
      workspace: workspace,
      api_key: api_key
    }

    save_or_update(user_params)
  end

  defp save_or_update(user_params) do
    case ClockifyBot.Repo.get_by(ClockifyBot.User, slack_id: user_params.slack_id) do
      nil -> ClockifyBot.Repo.insert(user_params)
      db_user -> update_user(db_user, user_params)
    end
  end

  defp update_user(db_user, user_params) do
    mod_user =
      changeset(db_user, %{
        api_key: user_params.api_key,
        workspace: user_params.workspace,
        clockify_id: user_params.clockify_id
      })

    ClockifyBot.Repo.update(mod_user)
  end

  def fetch_user(slack_id) do
    case ClockifyBot.Repo.get_by(ClockifyBot.User, slack_id: slack_id) do
      nil -> {:error, "Configure your user API KEY, then do stuff!"}
      user -> {:ok, user}
    end
  end
end
