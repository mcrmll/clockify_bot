import Config

config :clockify_bot, ClockifyBot.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool_size: 2,
  url: System.get_env("DATABASE_URL")
  

config :clockify_bot, ecto_repos: [ClockifyBot.Repo]
