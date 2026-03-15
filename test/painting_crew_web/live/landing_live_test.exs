defmodule PaintingCrewWeb.LandingLiveTest do
  use PaintingCrewWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders landing page", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Запуск покрасочной"
    assert html =~ "Получить консультацию"
    assert html =~ "Что входит"
  end

  test "form submission creates a submission", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    html =
      view
      |> form("form", submission: %{name: "Тест", phone: "+79001234567", email: "test@example.com"})
      |> render_submit()

    assert html =~ "Заявка отправлена"
  end

  test "form validation shows errors", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    html =
      view
      |> form("form", submission: %{name: "", phone: ""})
      |> render_change()

    assert html =~ "can" || html =~ "blank"
  end
end
