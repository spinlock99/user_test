defmodule UserTestWeb.UserControllerTest do
  use UserTestWeb.ConnCase
  use PhoenixSwagger.SchemaTest, "priv/static/swagger.json"

  alias UserTest.Accounts
  alias UserTest.Accounts.User

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:user) do
    {:ok, user} = Accounts.create_user(@create_attrs)
    user
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all users", %{conn: conn, swagger_schema: swagger_schema} do
      %{"data" => data} = conn
                        |> get(user_path(conn, :index))
                        |> validate_resp_schema(swagger_schema, "Users")
                        |> json_response(200)
      assert data == []
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn, swagger_schema: swagger_schema} do
      %{"data" => data} = conn
                          |> post(user_path(conn, :create), user: @create_attrs)
                          |> validate_resp_schema(swagger_schema, "User")
                          |> json_response(201)
      assert %{"id" => id} = data

      %{"data" => data} = conn
                          |> get(user_path(conn, :show, id))
                          |> validate_resp_schema(swagger_schema, "User")
                          |> json_response(200)
      assert data == %{"id" => id, "name" => "some name"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, user_path(conn, :create), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user, swagger_schema: swagger_schema} do
      %{"data" => data} = conn
                          |> put(user_path(conn, :update, user), user: @update_attrs)
                          |> validate_resp_schema(swagger_schema, "User")
                          |> json_response(200)
      assert %{"id" => ^id} = data

      %{"data" => data} = conn
                          |> get(user_path(conn, :show, id))
                          |> validate_resp_schema(swagger_schema, "User")
                          |> json_response(200)
      assert data == %{"id" => id, "name" => "some updated name"}
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete conn, user_path(conn, :delete, user)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, user_path(conn, :show, user)
      end
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
