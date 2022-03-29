# Mux Webhooks Example

This project uses [Elixir](https://elixir-lang.org/), [the Phoenix web framework](https://www.phoenixframework.org/),
and the official [Mux Elixir SDK](https://github.com/muxinc/mux-elixir) to build an app that listens for webhooks
from your Mux account.

See [the docs](https://docs.mux.com/guides/video/listen-for-webhooks) for a complete list of webhook event types.

## Running the app

1. [Install the Elixir programming language](https://elixir-lang.org/install.html)
1. Follow the [Phoenix installation guide](https://hexdocs.pm/phoenix/installation.html)
1. Create a free account with [ngrok](https://ngrok.com/) to forward webhooks from Mux to your local machine
1. [Download, install, and authenticate ngrok for your platform](https://ngrok.com/download)
1. Start ngrok on port 4000 `ngrok http 4000`
1. Generate a new Mux [Access Token](https://dashboard.mux.com/settings/access-tokens)
1. Add your **Access Token ID** and **Secret Key** to `config/config.exs` under the `:mux` configuration
1. Create a new Mux [webhook](https://dashboard.mux.com/settings/webhooks)
1. Enter your ngrok URL with the path `/api/webhooks/mux` into **URL to notify**
    1. **Example URL:** `https://xx12-345-67-89-100.ngrok.io/api/webhooks/mux`
1. Add the webhook signing secret to `config/config.exs` under the `:mux` configuration
1. Run the application using `mix phx.server`
1. Create, update, or delete video assets and watch the the application logs!

## How it works

We've added a caching body reader to `lib/mux_webhooks_web/endpoint.ex` to read and store the raw request body prior to parsing
the it so that we have access to the original request data for verification. See [this issue in the Phoenix repository](https://github.com/phoenixframework/phoenix/issues/459) and the [official Plug.Parsers documentation](https://hexdocs.pm/plug/Plug.Parsers.html) for more background.

```elixir
# lib/mux_webhooks_web/endpoint.ex

plug Plug.Parsers,
  parsers: [:urlencoded, :multipart, :json],
  pass: ["*/*"],
  body_reader: {MuxWebhooksWeb.CachingBodyReader, :read_body, []}, # Custom body reader
  json_decoder: Phoenix.json_library()
```

The body reader implementation in `lib/mux_webhooks_web/caching_body_reader.ex` checks whether the request path is in `/api/webhooks/*`
and uses `Plug.Conn.read_body/2` to read and store the raw request body into the connection.

Later, we will read the request body back so that we can verify the webhook signature.

In `lib/mux_webhooks_web/router.ex`, we add our webhook route:

```elixir
# lib/mux_webhooks_web/router.ex

scope "/api", MuxWebhooksWeb do
  pipe_through :api

  post "/webhooks/mux", MuxWebhooksController, :index
end
```

This will call the `index/2` function in the `MuxWebhooksWeb.MuxWebhooksController` module.

Looking at `lib/mux_webhooks_web/controllers/mux_webhooks_controller.ex`, we find a plug at the top of the file:

```elixir
# lib/mux_webhooks_web/controllers/mux_webhooks_controller.ex

plug MuxWebhooksWeb.MuxWebhookVerification when action == :index
```

This will verify any request going to the `index` action using `lib/mux_webhooks_web/mux_webhook_verification.ex`.

The `index/2` function declaration mas multiple clauses. Each clause pattern matches on the `type` of the webhook event
so that we can support and handle each event accordingly. The last `index/2` clause acts as a catch-all an
ignores the parameters so that we can safely handle incoming events that we are not interested in.

To add a handler for a new webhook event, just write a new `index/2` clause. For example:

```elixir
# lib/mux_webhooks_web/controllers/mux_webhooks_controller.ex

def index(conn, %{"type" => "video.live_stream.connected"}) do
  # TODO: Something amazing!
  send_ok_resp(conn)
end
```

Notice that each `index/2` ends with our helper function `send_ok_resp/2`. It is important to respond with a 200 status code
no matter the result of the operation in your implementation. This is how Mux knows to stop sending webhooks for the particular event!

In `lib/mux_webhooks_web/mux_webhook_verification.ex`, we use the [mux-elixir package](https://github.com/muxinc/mux-elixir) to verify
the webhook request via the `Mux.Webhooks.verify_header/3` function using the `Mux-Signature` header from the request, the raw request
body we stored with `MuxWebhooksWeb.CachingBodyReader`, and the signing secret we generated earlier.

If verification passes, we send the connection (conn) to the next action. In this case, it's `MuxWebhooksWeb.MuxWebhooksController.index/2`.
If verification failed, we send a 401 status code and halt the connection from continuing.

```elixir
# lib/mux_webhooks_web/mux_webhook_verification.ex

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
```
