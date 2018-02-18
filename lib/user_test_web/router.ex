defmodule UserTestWeb.Router do
  use UserTestWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UserTestWeb do
    pipe_through :api

    resources "/users", UserController, except: [:new, :edit]
  end
end
