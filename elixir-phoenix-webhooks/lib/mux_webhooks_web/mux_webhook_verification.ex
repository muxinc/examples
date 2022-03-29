defmodule MuxWebhooksWeb.MuxWebhookVerification do
  import Plug.Conn
  alias MuxWebhooksWeb.CachingBodyReader
  require Logger

  @signing_secret Application.fetch_env!(:mux, :webhook_signing_secret)

  def init(opts), do: opts

  def call(conn, _opts) do
    case verify_request(conn) do
      :ok ->
        conn

      {:error, reason} ->
        Logger.alert("Failed to verify Mux webhook: #{inspect(reason)}")

        conn
        |> send_resp(:unauthorized, "")
        |> halt()
    end
  end

  defp verify_request(conn) do
    case get_req_header(conn, "mux-signature") do
      [signature] ->
        conn
        |> CachingBodyReader.get_raw_body()
        |> Mux.Webhooks.verify_header(signature, @signing_secret)

      _ ->
        {:error, "Missing signature header"}
    end
  end
end
