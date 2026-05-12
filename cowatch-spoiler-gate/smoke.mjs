// End-to-end smoke test for cowatch-spoiler-gate.
// Connects two WS clients to the same room, exercises the sync-floor
// algorithm and the spoiler-safe chat gating, and verifies expected
// state transitions.
//
// Run:
//   PORT=3987 node server.js &       # start server
//   PORT=3987 node smoke.mjs

import WebSocket from 'ws';
import { setTimeout as sleep } from 'node:timers/promises';

const HOST = process.env.HOST || 'localhost';
const PORT = process.env.PORT || '3000';
const ROOM = `smoke-${Date.now()}`;

let failures = 0;
function check(name, ok, info = '') {
  const tag = ok ? 'PASS' : 'FAIL';
  if (!ok) failures++;
  console.log(`  ${tag}  ${name}${info ? ' — ' + info : ''}`);
}

function open(name, latencyMs) {
  return new Promise((resolve, reject) => {
    const url = `ws://${HOST}:${PORT}/ws?room=${ROOM}&name=${name}`;
    const ws = new WebSocket(url);
    const events = [];
    const state = { viewerId: null, lastSync: null, releases: [] };
    ws.on('message', (raw) => {
      const msg = JSON.parse(raw);
      events.push(msg);
      if (msg.type === 'hello_ack') state.viewerId = msg.viewerId;
      if (msg.type === 'sync_update') state.lastSync = msg;
      if (msg.type === 'chat_release') state.releases.push(msg);
    });
    ws.once('open', () => {
      ws.send(JSON.stringify({ type: 'latency_report', latencyMs }));
      resolve({ ws, events, state });
    });
    ws.once('error', reject);
  });
}

function send(ws, payload) {
  ws.send(JSON.stringify(payload));
}

async function main() {
  console.log(`\ncowatch-spoiler-gate smoke test (room=${ROOM})\n`);

  // 1. HTTP sanity
  const httpRes = await fetch(`http://${HOST}:${PORT}/`);
  check('GET /', httpRes.ok, `status ${httpRes.status}`);
  const cfgRes = await fetch(`http://${HOST}:${PORT}/config.json`);
  const cfg = cfgRes.ok ? await cfgRes.json() : {};
  check(
    'GET /config.json',
    cfgRes.ok && typeof cfg.muxPlaybackId === 'string',
    `playback-id=${cfg.muxPlaybackId}`,
  );

  // 2. Two viewers join, different latencies
  const fast = await open('fast', 1000);
  const slow = await open('slow', 4500);
  await sleep(150);

  // 3. Sync floor should equal slowest (4500)
  check(
    'sync floor = max latency',
    fast.state.lastSync && fast.state.lastSync.slowestMs === 4500,
    `slowestMs=${fast.state.lastSync?.slowestMs}`,
  );
  check(
    'target offset = floor + 500ms safety',
    fast.state.lastSync && fast.state.lastSync.targetOffsetMs === 5000,
    `targetOffsetMs=${fast.state.lastSync?.targetOffsetMs}`,
  );
  check(
    'roster has both viewers',
    fast.state.lastSync && fast.state.lastSync.roster.length === 2,
    `n=${fast.state.lastSync?.roster.length}`,
  );

  // 4. Set per-viewer perceived PDTs.
  //    Fast at 10s, slow at 7s. Fast sends a chat at PDT=10s.
  send(fast.ws, { type: 'pdt_progress', currentPdt: 10000 });
  send(slow.ws, { type: 'pdt_progress', currentPdt: 7000 });
  await sleep(80);
  send(fast.ws, { type: 'chat_send', text: 'hello from the future' });
  await sleep(150);

  check(
    'chat held while slow viewer behind sender PDT',
    fast.state.releases.length === 0 && slow.state.releases.length === 0,
    `fast=${fast.state.releases.length}, slow=${slow.state.releases.length}`,
  );

  // 5. Slow viewer advances past 10s. Server should release.
  send(slow.ws, { type: 'pdt_progress', currentPdt: 10500 });
  await sleep(200);

  check(
    'fast received release after slow caught up',
    fast.state.releases.length === 1,
    `n=${fast.state.releases.length}`,
  );
  check(
    'slow received release after slow caught up',
    slow.state.releases.length === 1,
    `n=${slow.state.releases.length}`,
  );
  if (fast.state.releases.length === 1) {
    const r = fast.state.releases[0];
    check(
      'released msg preserves sender + text',
      r.name === 'fast' && r.text === 'hello from the future',
      `name=${r.name}, releasePdt=${r.releasePdt}`,
    );
  }

  // 6. New send when slow is already past sender's PDT → instant release.
  send(slow.ws, { type: 'pdt_progress', currentPdt: 12000 });
  send(fast.ws, { type: 'pdt_progress', currentPdt: 11500 });
  await sleep(80);
  send(fast.ws, { type: 'chat_send', text: 'instant' });
  await sleep(150);
  check(
    'chat releases immediately when all viewers already past sender PDT',
    fast.state.releases.length === 2,
    `n=${fast.state.releases.length}`,
  );

  // 7. Sender slowest case: floor follows them, chat releases instantly.
  send(slow.ws, { type: 'latency_report', latencyMs: 2000 });
  send(fast.ws, { type: 'latency_report', latencyMs: 6000 });
  await sleep(120);
  check(
    'floor moves when latencies change',
    fast.state.lastSync.slowestMs === 6000,
    `slowestMs=${fast.state.lastSync.slowestMs}`,
  );

  // 8. Disconnect cleanup
  fast.ws.close();
  await sleep(120);
  check(
    'roster shrinks on disconnect',
    slow.state.lastSync.roster.length === 1,
    `n=${slow.state.lastSync.roster.length}`,
  );

  slow.ws.close();
  await sleep(80);

  console.log(`\n${failures === 0 ? 'all checks passed' : failures + ' check(s) failed'}\n`);
  process.exit(failures === 0 ? 0 : 1);
}

main().catch((e) => {
  console.error('smoke test error:', e);
  process.exit(2);
});
