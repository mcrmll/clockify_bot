defmodule ClockifyBot.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user) do
      add :slack_id, :string
      add :clockify_id, :string
      add :workspace, :string
      add :api_key, :string
    end

  end
end
