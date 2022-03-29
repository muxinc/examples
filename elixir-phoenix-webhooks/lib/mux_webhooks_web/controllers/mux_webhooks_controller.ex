defmodule MuxWebhooksWeb.MuxWebhooksController do
  use MuxWebhooksWeb, :controller
  require Logger

  plug MuxWebhooksWeb.MuxWebhookVerification when action == :index

  def index(conn, %{"type" => "video.asset.created"} = params) do
    %{"data" => %{"id" => asset_id}} = params
    Logger.debug("Asset #{asset_id} created")
    send_ok_resp(conn)
  end

  def index(conn, %{"type" => "video.asset.ready"} = params) do
    %{"data" => %{"id" => asset_id}} = params
    Logger.debug("Asset #{asset_id} ready")
    send_ok_resp(conn)
  end

  def index(conn, %{"type" => "video.asset.errored"} = params) do
    %{"data" => %{"id" => asset_id}} = params
    Logger.alert("Asset #{asset_id} errored")
    send_ok_resp(conn)
  end

  def index(conn, %{"type" => "video.asset.updated"} = params) do
    %{"data" => %{"id" => asset_id}} = params
    Logger.debug("Asset #{asset_id} updated")
    send_ok_resp(conn)
  end

  def index(conn, %{"type" => "video.asset.deleted"} = params) do
    %{"data" => %{"id" => asset_id}} = params
    Logger.debug("Asset #{asset_id} deleted")
    send_ok_resp(conn)
  end

  def index(conn, _params) do
    send_ok_resp(conn)
  end

  defp send_ok_resp(conn) do
    send_resp(conn, :ok, "")
  end
end
