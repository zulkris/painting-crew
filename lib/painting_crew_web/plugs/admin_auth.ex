defmodule PaintingCrewWeb.Plugs.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if get_session(conn, :admin_authenticated) do
      conn
    else
      conn
      |> put_flash(:error, "Необходима авторизация")
      |> redirect(to: "/admin/login")
      |> halt()
    end
  end
end
