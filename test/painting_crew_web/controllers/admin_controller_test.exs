defmodule PaintingCrewWeb.AdminControllerTest do
  use PaintingCrewWeb.ConnCase, async: true

  test "GET /admin/login renders login form", %{conn: conn} do
    conn = get(conn, "/admin/login")
    assert html_response(conn, 200) =~ "Вход в админ-панель"
  end

  test "GET /admin redirects to login without session", %{conn: conn} do
    conn = get(conn, "/admin")
    assert redirected_to(conn) == "/admin/login"
  end

  test "POST /admin/login with correct credentials", %{conn: conn} do
    conn = post(conn, "/admin/login", %{"user" => "admin", "pass" => "admin"})
    assert redirected_to(conn) == "/admin"

    conn = get(recycle(conn), "/admin")
    assert html_response(conn, 200) =~ "Заявки"
  end

  test "POST /admin/login with wrong credentials", %{conn: conn} do
    conn = post(conn, "/admin/login", %{"user" => "admin", "pass" => "wrong"})
    assert redirected_to(conn) == "/admin/login"
  end
end
