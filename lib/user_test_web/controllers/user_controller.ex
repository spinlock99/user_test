defmodule UserTestWeb.UserController do
  use UserTestWeb, :controller
  use PhoenixSwagger

  alias UserTest.Accounts
  alias UserTest.Accounts.User

  action_fallback UserTestWeb.FallbackController

  def swagger_definitions do
    %{
      User: swagger_schema do
        title "User"
        description "A user"
        properties do
          user (Schema.new do
            properties do
              name :string, "the name of the user", required: true
            end
          end)
        end
        example %{
          user: %{
            name: "Wat?"
          }
        }
      end,
      Users: swagger_schema do
        title "Users"
        description "A list of all users"
        properties do
          data (Schema.new do
            type :array
            items Schema.ref(:User)
          end)
        end
      end,
      Error: swagger_schema do
        title "Errors"
        description "Error responses from the API"
        properties do
          error :string, "The error message", required: true
        end
      end
    }
  end

  swagger_path :index do
    get "/api/users"
    summary "List users"
    response 200, "Success", Schema.ref(:Users)
  end

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.json", users: users)
  end

  swagger_path :create do
    post "/api/users"
    summary "Create a new user"
    parameters do
      user :body, Schema.ref(:User), "User to add", required: true
    end
    response 201, "Ok", Schema.ref(:User)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def create(conn, %{"user" => user_params}) do
    with {:ok, %User{} = user} <- Accounts.create_user(user_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", user_path(conn, :show, user))
      |> render("show.json", user: user)
    end
  end

  swagger_path :show do
    get "/api/users/{id}"
    summary "Retrieve a user"
    parameters do
      id :path, :string, "The id of the user", required: true
    end
    response 200, "Ok", Schema.ref(:User)
    response 404, "Not found", Schema.ref(:Error)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    render(conn, "show.json", user: user)
  end

  swagger_path :update do
    patch "/api/users/{id}"
    summary "Update an existing user"
    parameters do
      id :path, :string, "The id of the user to update", required: true
      user :body, Schema.ref(:User), "The user details to update"
    end
    response 201, "Ok", Schema.ref(:User)
    response 422, "Unprocessable Entity", Schema.ref(:Error)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Accounts.get_user!(id)

    with {:ok, %User{} = user} <- Accounts.update_user(user, user_params) do
      render(conn, "show.json", user: user)
    end
  end

  swagger_path :delete do
    delete "/api/users/{id}"
    summary "Delete a user"
    parameters do
      id :path, :string, "The id of the user", required: true
    end
    response 204, "No content"
    response 404, "Not found"
  end

  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    with {:ok, %User{}} <- Accounts.delete_user(user) do
      send_resp(conn, :no_content, "")
    end
  end
end
