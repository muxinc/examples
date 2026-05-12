# Latency-equalized co-watch room for Mux

`cowatch-spoiler-gate` is a small reference application that solves one
specific problem in co-watching ("watch parties", live sports rooms,
Discord movie nights): **fast viewers spoiling moments for slow
viewers**. It is built on top of
[Mux Player](https://www.mux.com/player) and the
[Mux Data API](https://www.mux.com/data), and is intended as a
contributor example for the [Mux OSS program](https://www.mux.com/oss).

## The problem

When several people watch the same stream together, their playback drifts
apart. Causes include:

- A mix of LL-HLS and standard HLS clients in the same room.
- CDN edge variance and network jitter.
- Backgrounded tabs that fall behind on rebuffer.
- Mixed device classes (mobile decoders vs. desktop).

A spread of one to two seconds is enough for one viewer to type
"OMG goal!" while another viewer is still watching the build-up. The fix
is to give every viewer a common clock and gate reactions to whoever is
furthest behind.

## How it works

The room runs two protocol moves on top of a regular Mux Player.

**1. Sync floor.** Each viewer reports its own latency. The server picks
the slowest viewer's latency and broadcasts it as the room's sync target.
With real LL-HLS, clients are expected to seek to match this floor; the
prototype reports the value so you can see the algorithm at work.

**2. Spoiler-safe chat.** Every chat message is stamped with the sender's
current Program-Date-Time (PDT) at the moment they hit send. The server
holds that message until **every** viewer's perceived PDT has passed the
sender's stamp. Only then does it broadcast the message to the room.

The result: a slow viewer cannot be spoiled by a fast viewer's reaction.
A fast viewer's message is held in a queue until the slow viewer has
caught up to the same moment in the stream.

## Mux integration

Two Mux surfaces are exercised by this example, on both client and
server.

| Mux product | Where it is used | What for |
|-------------|------------------|----------|
| **Mux Player** (`@mux/mux-player`) | `public/room.html` | Plays the stream, exposes `player.currentPdt` (EXT-X-PROGRAM-DATE-TIME) for live streams, and emits Mux Data beacons when `env-key` is set. |
| **Mux Data API** (`@mux/mux-node`) | `server.js` → `/api/metrics` | Reads real-time concurrent-viewer count, rebuffer percentage, and video startup time for the room, scoped by `video_id:<room>` (`data.realTime.retrieveTimeseries`, `data.metrics.getOverallValues`). |

The official `@mux/mux-node` SDK is used for all server-side API calls;
no raw HTTP is hand-rolled. Both surfaces are available on Mux's free
plan.

## Architecture

```
            ┌─────────────────────────────────────────────┐
viewer A ──►│                                             │
viewer B ──►│   WebSocket /ws       (sync-floor + chat)   │
viewer C ──►│   - tracks latency + PDT per viewer         │
            │   - holds chat until every viewer passes    │
            │     the sender's PDT                        │   ┌── Mux Data API ──┐
            │                                             │──►│ realtime + over- │
            │   HTTP /api/metrics  (Mux Data panel)       │   │ all metrics      │
            │                                             │   └──────────────────┘
            └─────────────────────────────────────────────┘
```

Per-viewer server state: `{ latencyMs, currentPdt, lastSeen }`.

Per-pending-message state: `{ from, name, text, releasePdt, recipients }`.
The message is released to all recipients once every eligible recipient
satisfies `currentPdt >= releasePdt`.

## Project layout

```
cowatch-spoiler-gate/
├── server.js          Express + ws server, /api/metrics route, /ws sync server
├── public/
│   ├── index.html     Lobby (join form)
│   └── room.html      Mux Player, sync display, synced chat, Mux Data panel
├── smoke.mjs          Headless protocol smoke test (no Mux account needed)
├── .env.example       Template for the four supported env vars
├── LICENSE.md         MIT
└── package.json
```

## Modes

The room view auto-detects which mode it is in from Mux Player's
reported `streamType`.

| Mode | PDT source | Latency source |
|------|------------|----------------|
| **Live** (LL-HLS, DVR, low-latency DVR) | `player.currentPdt` — the real EXT-X-PROGRAM-DATE-TIME from the manifest | `Date.now() - player.currentPdt` — the real distance between wall-clock and the playhead |
| **VOD demo** | `player.currentTime * 1000` — milliseconds since stream start | A slider, so you can simulate a slower viewer without a live stream |

In live mode the slider is hidden because latency is observed, not
chosen. To run in live mode, set `MUX_PLAYBACK_ID` to a Mux Live Stream
playback ID you already have (Mux Live Stream creation is a paid
feature, so it is not part of this example).

## Setup

```bash
npm install
cp .env.example .env   # then edit .env and fill in real values
npm start              # http://localhost:3000
# or, with auto-reload:
npm run dev
```

The server auto-loads `.env` on startup using Node's built-in
`process.loadEnvFile()` (Node 20.12 or later). No `dotenv` dependency is
required. You can also export the variables in your shell or pass
`--env-file=.env` to `node` directly — any of the three works.

On startup the banner reports the wiring state of each integration:

```
cowatch-spoiler-gate listening on http://localhost:3000
  playback-id:        DS00Spx1CV902MCtPj5WknGlR102V5HFkDe
  Mux Data API:       wired (/api/metrics active)
  Mux Data env-key:   wired (player will emit beacons)
```

If either says `OFF`, the demo still works — `/api/metrics` returns
`503` and the Mux Data panel is hidden, but the WebSocket-based sync
floor and chat-gate continue to function.

### Environment variables

| Variable | Purpose |
|----------|---------|
| `MUX_TOKEN_ID`, `MUX_TOKEN_SECRET` | Mux access token with **Mux Data** read permissions. Required for `GET /api/metrics`. |
| `MUX_DATA_ENV_KEY` | Mux Data environment key (Mux dashboard → *Settings → Environments*). When set, Mux Player emits Data beacons tagged with `metadata-video-id=<room>` and `metadata-viewer-user-id=<display name>`. |
| `MUX_PLAYBACK_ID` | Mux playback ID to play. Defaults to a public VOD demo asset. Point this at any playback ID, including a live one if you have access. |
| `PORT` | HTTP port. Defaults to `3000`. |

`.env` is excluded from git via `.gitignore` so credentials are not
accidentally committed.

## HTTP endpoints

| Route | Description |
|-------|-------------|
| `GET /` | Lobby (join form). |
| `GET /room.html?room=…&name=…` | Room view (player + sync stats + chat + Mux Data panel). |
| `GET /config.json` | Player config: playback ID, Data env-key, whether `/api/metrics` is wired. |
| `GET /api/metrics?room=<room>` | Reads three Mux Data values for `video_id:<room>`: real-time concurrent viewers, last-hour rebuffer percentage, last-hour video startup time. Returns `503` if Mux credentials are not set. |
| `WS /ws?room=…&name=…` | Sync floor and chat protocol. Messages: `latency_report`, `pdt_progress`, `chat_send` (in); `hello_ack`, `sync_update`, `chat_release` (out). |

## How to use it (VOD demo)

This path needs no Mux account.

1. Open `http://localhost:3000` in two browser tabs.
2. Join the same room name (for example, `lobby`) using two different
   display names (for example, `alice` and `bob`).
3. Each tab plays the VOD asset independently. The "Sim latency" slider
   sets that tab's reported latency. The viewer with the higher slider
   value is treated as the slower viewer.

The slowest viewer in the room is marked **◀ floor** in the roster. The
"(N messages held — waiting for slowest viewer)" indicator shows messages
currently held by the server. The sender does **not** see their own
message in the chat list until the server releases it.

To see the spoiler-gate working:

1. Set alice's slider to 500ms and bob's slider to 8000ms.
2. Wait until both players have been playing for around 30 seconds.
   Alice's perceived PDT will be roughly 29.5s; bob's roughly 22s.
3. Send `"spoiler!"` from alice (the faster viewer). Alice's tab shows
   `(1 message held)` and nothing else.
4. Wait. As bob's player advances, his perceived PDT ticks up. Once it
   crosses ~29.5s, the message is released to both tabs at the same time.
5. Now send `"reaction"` from bob (the slower viewer). It releases
   immediately, because alice's perceived PDT is already past bob's stamp.

This asymmetry — fast-sender messages held, slow-sender messages
instantaneous — is the spoiler-gate working correctly.

## How to use it (Live mode)

If you have a Mux Live Stream available (the Live Stream API is a paid
feature and not exercised by this example), point the demo at it:

```bash
echo 'MUX_PLAYBACK_ID=<your-live-playback-id>' >> .env
npm start
```

Mux Player will detect the stream as live, the simulated-latency slider
will disappear, and `player.currentPdt` becomes the source of truth for
both latency and chat gating. You cannot seek ahead of the live edge,
so the cross-tab playback divergence you see in VOD mode is not a
concern.

## Mux Data panel

When `MUX_TOKEN_ID` and `MUX_TOKEN_SECRET` are set, the room view shows
a *Mux Data* panel with three values polled every ten seconds from
`GET /api/metrics?room=<room>`:

- **Concurrent viewers (real-time)** — latest data point from the Mux
  Data Realtime API for the `current-concurrent-viewers` metric,
  filtered by `video_id:<room>`. Mux Player on each viewer is configured
  with `metadata-video-id=<room>` so beacons land under that filter.
- **Rebuffer % (last hour)** — overall value of the
  `rebuffer_percentage` metric, scoped by the same `video_id`.
- **Video startup time (last hour)** — overall value of
  `video_startup_time` over the same window.

Mux Data has a processing delay of roughly a minute, so the first time
a viewer joins a fresh room you will see dashes until the first beacons
are ingested. This panel is intentionally read-only — the
WebSocket-reported latency, not the Data metric, is what drives the
sync-floor algorithm. The Data integration is observational.

## Known limitations of the demo

- **VOD playback is not synchronized across tabs.** Each tab's player
  has its own `currentTime`; pausing or seeking in one tab does not
  affect the others. This is intentional in the demo so that you can
  produce real PDT divergence with a single asset. In a production
  watch-party you would either run on Mux Live (no seeking) or add a
  playback-sync layer (broadcast play/pause/seek over the same socket).
- **Stale-viewer eviction at 10 seconds.** If a viewer stops sending
  `pdt_progress` for ten seconds — closing the tab, backgrounding on
  mobile, or pausing for a long time — the server removes them from the
  eligibility set for held messages, which causes those messages to
  release to the remaining viewers. This is a deliberate "stuck viewer"
  fallback so the room does not freeze permanently.
- **No authentication.** Anyone with the URL can join any room.

## Production hardening (out of scope for the example)

- AuthN/Z on room join, with signed Mux playback policies and a real
  user identity.
- Rate limiting on `chat_send` per viewer.
- Persistent rooms across server restarts.
- Maximum hold time on a chat message before forcing release,
  independent of the stale-viewer timeout.
- Horizontal scale via Redis pub/sub for cross-instance broadcasts.
- Profanity, spoiler-keyword, and image-moderation hooks before release.

## Smoke test

A headless multi-viewer protocol test is included:

```bash
node smoke.mjs
```

It spins up two WebSocket clients, exercises latency reporting, the
sync floor, the chat-hold-and-release behavior in both directions, and
the disconnect path. No Mux account is required to run it.

## License

[MIT](LICENSE.md).
