// cowatch-spoiler-gate — latency-equalized co-watch sync server.
//
// Two protocol moves the room runs:
//
//   1. SYNC FLOOR: every viewer reports its own latency. Server picks
//      slowest, broadcasts as the group's sync target. (In real LL-HLS
//      the player would seek to match this; the prototype only displays
//      it because we use VOD playback.)
//
//   2. SPOILER-SAFE CHAT: a chat message is stamped with the sender's
//      current PDT (Program-Date-Time). Server holds the message until
//      every recipient's playback has passed that PDT. Fast viewers
//      can't react before slow viewers see the moment.
//
// Swap path for real Mux Live: replace the simulated latency in room.html
// with `player.currentPdt` (or HLS.js fragment PDT) and remove the slider.

import express from 'express';
import { WebSocketServer } from 'ws';
import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';
import { existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import Mux from '@mux/mux-node';

const envPath = join(dirname(fileURLToPath(import.meta.url)), '.env');
if (existsSync(envPath) && typeof process.loadEnvFile === 'function') {
  process.loadEnvFile(envPath);
}

const PORT = Number(process.env.PORT) || 3000;
const SYNC_BUFFER_MS = 500;
const STALE_VIEWER_MS = 10_000;
const DEFAULT_PLAYBACK_ID =
  process.env.MUX_PLAYBACK_ID || 'DS00Spx1CV902MCtPj5WknGlR102V5HFkDe';

const MUX_TOKEN_ID = process.env.MUX_TOKEN_ID || null;
const MUX_TOKEN_SECRET = process.env.MUX_TOKEN_SECRET || null;
const MUX_DATA_ENV_KEY = process.env.MUX_DATA_ENV_KEY || null;

const mux =
  MUX_TOKEN_ID && MUX_TOKEN_SECRET
    ? new Mux({ tokenId: MUX_TOKEN_ID, tokenSecret: MUX_TOKEN_SECRET })
    : null;

const app = express();
app.use(express.json());
app.use(express.static('public'));

app.get('/config.json', (_req, res) => {
  res.json({
    muxPlaybackId: DEFAULT_PLAYBACK_ID,
    muxDataEnvKey: MUX_DATA_ENV_KEY,
    muxApiReady: !!mux,
  });
});

function requireMux(res) {
  if (mux) return true;
  res.status(503).json({
    error:
      'MUX_TOKEN_ID and MUX_TOKEN_SECRET are not set; the metrics endpoint is disabled in this server',
  });
  return false;
}

app.get('/api/metrics', async (req, res) => {
  if (!requireMux(res)) return;
  const videoId = String(req.query.room || 'default').slice(0, 64);
  const filters = [`video_id:${videoId}`];
  const now = Math.floor(Date.now() / 1000);
  const timeframe = [String(now - 3600), String(now)];
  try {
    const [concurrent, rebuffer, startup] = await Promise.allSettled([
      mux.data.realTime.retrieveTimeseries('current-concurrent-viewers', { filters }),
      mux.data.metrics.getOverallValues('rebuffer_percentage', { filters, timeframe }),
      mux.data.metrics.getOverallValues('video_startup_time', { filters, timeframe }),
    ]);
    const concurrentPoints =
      concurrent.status === 'fulfilled' ? concurrent.value?.data || [] : [];
    const latestConcurrent = concurrentPoints.length
      ? concurrentPoints[concurrentPoints.length - 1]?.value ?? null
      : null;
    res.json({
      videoId,
      windowSeconds: 3600,
      concurrentViewers: latestConcurrent,
      rebufferPercentage:
        rebuffer.status === 'fulfilled' ? rebuffer.value?.data?.value ?? null : null,
      videoStartupTimeMs:
        startup.status === 'fulfilled' ? startup.value?.data?.value ?? null : null,
      errors: [concurrent, rebuffer, startup]
        .filter((r) => r.status === 'rejected')
        .map((r) => String(r.reason?.message || r.reason)),
    });
  } catch (err) {
    res.status(502).json({ error: String(err?.message || err) });
  }
});

const server = createServer(app);
const wss = new WebSocketServer({ server, path: '/ws' });

// rooms: roomId -> {
//   viewers: Map<viewerId, { ws, name, latencyMs, currentPdt, lastSeen }>,
//   pending: Map<msgId, { from, name, text, releasePdt, recipients: Set<viewerId> }>,
// }
const rooms = new Map();

function getRoom(id) {
  let room = rooms.get(id);
  if (!room) {
    room = { viewers: new Map(), pending: new Map() };
    rooms.set(id, room);
  }
  return room;
}

function broadcast(room, msg) {
  const payload = JSON.stringify(msg);
  for (const v of room.viewers.values()) {
    if (v.ws.readyState === 1) v.ws.send(payload);
  }
}

function rosterSnapshot(room) {
  return [...room.viewers.entries()].map(([id, v]) => ({
    id,
    name: v.name,
    latencyMs: Number.isFinite(v.latencyMs) ? v.latencyMs : null,
  }));
}

function broadcastSync(room) {
  const latencies = [...room.viewers.values()]
    .map((v) => v.latencyMs)
    .filter((n) => Number.isFinite(n));
  const slowestMs = latencies.length ? Math.max(...latencies) : null;
  const targetOffsetMs = slowestMs == null ? null : slowestMs + SYNC_BUFFER_MS;
  broadcast(room, {
    type: 'sync_update',
    slowestMs,
    targetOffsetMs,
    roster: rosterSnapshot(room),
  });
}

function tryReleaseMessages(room) {
  const now = Date.now();
  for (const [msgId, msg] of room.pending) {
    const stillPresent = [...msg.recipients].some((id) => room.viewers.has(id));
    if (!stillPresent) {
      room.pending.delete(msgId);
      continue;
    }
    const eligible = [...room.viewers.entries()].filter(
      ([id, v]) =>
        msg.recipients.has(id) &&
        Number.isFinite(v.currentPdt) &&
        now - v.lastSeen < STALE_VIEWER_MS,
    );
    const allPassed =
      eligible.length > 0 &&
      eligible.every(([, v]) => v.currentPdt >= msg.releasePdt);
    if (allPassed) {
      broadcast(room, {
        type: 'chat_release',
        msgId,
        from: msg.from,
        name: msg.name,
        text: msg.text,
        releasePdt: msg.releasePdt,
      });
      room.pending.delete(msgId);
    }
  }
}

setInterval(() => {
  for (const room of rooms.values()) tryReleaseMessages(room);
}, 1000);

wss.on('connection', (ws, req) => {
  const url = new URL(req.url, 'http://localhost');
  const roomId = (url.searchParams.get('room') || 'default').slice(0, 64);
  const name = (url.searchParams.get('name') || 'anon').slice(0, 32);
  const viewerId = randomUUID();
  const room = getRoom(roomId);

  room.viewers.set(viewerId, {
    ws,
    name,
    latencyMs: NaN,
    currentPdt: NaN,
    lastSeen: Date.now(),
  });

  ws.send(JSON.stringify({ type: 'hello_ack', viewerId, roomId }));
  broadcastSync(room);

  ws.on('message', (raw) => {
    let msg;
    try {
      msg = JSON.parse(raw);
    } catch {
      return;
    }
    const v = room.viewers.get(viewerId);
    if (!v) return;
    v.lastSeen = Date.now();

    if (msg.type === 'latency_report') {
      const n = Number(msg.latencyMs);
      if (Number.isFinite(n) && n >= 0 && n < 60_000) {
        v.latencyMs = n;
        broadcastSync(room);
      }
    } else if (msg.type === 'pdt_progress') {
      const n = Number(msg.currentPdt);
      if (Number.isFinite(n)) {
        v.currentPdt = n;
        tryReleaseMessages(room);
      }
    } else if (msg.type === 'chat_send') {
      const text = String(msg.text ?? '').slice(0, 500).trim();
      const senderPdt = v.currentPdt;
      if (!text || !Number.isFinite(senderPdt)) return;
      const msgId = randomUUID();
      room.pending.set(msgId, {
        from: viewerId,
        name: v.name,
        text,
        releasePdt: senderPdt,
        recipients: new Set(room.viewers.keys()),
      });
      tryReleaseMessages(room);
    }
  });

  ws.on('close', () => {
    room.viewers.delete(viewerId);
    if (room.viewers.size === 0) {
      rooms.delete(roomId);
    } else {
      broadcastSync(room);
      tryReleaseMessages(room);
    }
  });
});

server.listen(PORT, () => {
  console.log(`cowatch-spoiler-gate listening on http://localhost:${PORT}`);
  console.log(`  playback-id:        ${DEFAULT_PLAYBACK_ID}`);
  console.log(`  Mux Data API:       ${mux ? 'wired (/api/metrics active)' : 'OFF (set MUX_TOKEN_ID and MUX_TOKEN_SECRET to enable)'}`);
  console.log(`  Mux Data env-key:   ${MUX_DATA_ENV_KEY ? 'wired (player will emit beacons)' : 'OFF (set MUX_DATA_ENV_KEY to enable)'}`);
});
