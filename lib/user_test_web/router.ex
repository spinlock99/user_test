defmodule UserTestWeb.Router do
  use UserTestWeb, :router

  scope "/" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :user_test, swagger_file: "swagger.json"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UserTestWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end

  def swagger_info do
    %{
      info: %{
        version: "0.0.2",
        title: "User Test App"
      }
    }
  end
end
