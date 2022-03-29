defmodule MuxWebhooksWeb.PageController do
  use MuxWebhooksWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
