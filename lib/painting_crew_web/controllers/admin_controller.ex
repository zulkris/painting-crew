defmodule PaintingCrewWeb.AdminController do
  use PaintingCrewWeb, :controller

  alias PaintingCrew.Submissions

  plug PaintingCrewWeb.Plugs.AdminAuth when action in [:index]

  def login(conn, _params) do
    render(conn, :login, layout: false)
  end

  def do_login(conn, %{"user" => user, "pass" => pass}) do
    config = Application.get_env(:painting_crew, :admin)
    expected_user = config[:user] || "admin"
    expected_pass = config[:pass] || "admin"

    if Plug.Crypto.secure_compare(user, expected_user) &&
         Plug.Crypto.secure_compare(pass, expected_pass) do
      conn
      |> put_session(:admin_authenticated, true)
      |> redirect(to: "/admin")
    else
      conn
      |> put_flash(:error, "Неверные данные")
      |> redirect(to: "/admin/login")
    end
  end

  def logout(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: "/admin/login")
  end

  def index(conn, _params) do
    submissions = Submissions.list_submissions()
    render(conn, :index, submissions: submissions)
  end
end
