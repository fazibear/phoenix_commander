defmodule PhoenixCommanderWeb.PageController do
  use PhoenixCommanderWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
