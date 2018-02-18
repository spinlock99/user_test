# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :user_test,
  ecto_repos: [UserTest.Repo]

# Configures the endpoint
config :user_test, UserTestWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "zXoQTdQk+8qV7ajGLY/OazPdSyRdMic4jDKGBNvBWicEmgPLrWzQqIc9VQHqxmWZ",
  render_errors: [view: UserTestWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: UserTest.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configure Swagger
config :user_test, :phoenix_swagger,
swagger_files: %{
  "priv/static/swagger.json" => [
    router: UserTestWeb.Router, # phoenix routes will be converted to swagger paths
    endpoint: UserTestWeb.Endpoint # endpoint config used to set host, poret and https schemes.
  ]
}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
