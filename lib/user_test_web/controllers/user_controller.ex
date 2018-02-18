defmodule UserTestWeb.UserController do
  use UserTestWeb, :controller
  use PhoenixSwagger

  alias UserTest.Accounts
  alias UserTest.Accounts.User

  action_fallback UserTestWeb.FallbackController

  def swagger_definitions do
    %{
      UserResource: JsonApi.resource do
        description "A user of the application"
        attributes do
          name :string, "User's name", required: true
        end
        link :self, "The link to this user resource"
      end,
      Users: JsonApi.page(:UserResource),
      User: JsonApi.single(:UserResource)
    }
  end

  swagger_path :index do
    get "/api/users"
    description "List users"
    response 200, "Success", Schema.ref(:Users)
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
