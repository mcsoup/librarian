# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

config :librarian, Librarian.Robot,
  token: System.get_env("SLACK_BOT_TOKEN")

config :logger, level: :info
