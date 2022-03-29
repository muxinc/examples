import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :mux_webhooks, MuxWebhooksWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Ku/c9CKslGqCy1SQu6hMELL15nGFCoLvBF3NSNh8UsJX601NKA2hAqHp8jJ8nuT9",
  server: false

# In test we don't send emails.
config :mux_webhooks, MuxWebhooks.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
