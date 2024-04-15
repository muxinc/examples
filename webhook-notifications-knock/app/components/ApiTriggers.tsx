'use client';
export default function ApiTriggers() {
  return (
    <div>
      <h2 className="text-xl mb-4">Mux Webhooks</h2>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callNewAsset}
      >
        New Asset
      </button>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callNewLiveStream}
      >
        New Stream
      </button>
      <h2 className="text-xl mb-4">Knock API Routes</h2>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callCreateChannels}
      >
        Create Channels
      </button>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callDeleteChannels}
      >
        Delete Channels
      </button>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callCreateSubscriptions}
      >
        Create Subscriptions
      </button>
      <button
        className="h-8 border rounded-xl py-2 px-4 flex items-center justify-center my-4"
        onClick={callDeleteSubscriptions}
      >
        Delete Subscriptions
      </button>
    </div>
  );
}
async function callCreateSubscriptions() {
  await fetch('/api/knock/subscriptions', {
    method: 'post',
    body: JSON.stringify({ action: 'create' }),
  });
}
async function callDeleteSubscriptions() {
  await fetch('/api/knock/subscriptions', {
    method: 'post',
    body: JSON.stringify({ action: 'delete' }),
  });
}
async function callCreateChannels() {
  await fetch('/api/knock/channels', {
    method: 'post',
    body: JSON.stringify({ action: 'create' }),
  });
}
async function callDeleteChannels() {
  await fetch('/api/knock/channels', {
    method: 'post',
    body: JSON.stringify({ action: 'delete' }),
  });
}
async function callNewLiveStream() {
  await fetch('/api/webhooks/mux', {
    method: 'post',
    body: JSON.stringify({
      type: 'video.live_stream.active',
      request_id: null,
      object: {
        type: 'live',
        id: '1TaauZVrUfXwkpUxKVWQiSOD02YWhTpan',
      },
      id: '072d5897-baeb-4b5b-b10e-72399463ed35',
      environment: {
        name: 'Testing',
        id: 'j29sb4',
      },
      data: {
        stream_key: '******',
        status: 'active',
        srt_passphrase: '******',
        simulcast_targets: [
          {
            url: 'rtmps://va.pscp.tv:443/x',
            stream_key: '******',
            status: 'broadcasting',
            passthrough: 'Twitter',
            id: 'PYbkjeAddS5JPo1kLRdmjLP5Zu6bb9yMQ8VG00ekC7mCrn6HtZFtRWw',
          },
          {
            url: 'rtmp://a.rtmp.youtube.com/live2',
            stream_key: '******',
            status: 'broadcasting',
            passthrough: 'YouTube',
            id: 'xl9IyCxhrfXKkTbmm5Pk6wez7R48ClywWLt1B1EgMyM39Duevx4Deg',
          },
        ],
        recording: true,
        recent_asset_ids: [],
        playback_ids: [
          {
            policy: 'public',
            id: 'qzrAqvB41wlq5d2hYJ6RT6Y00KRl2Gf2k',
          },
        ],
        new_asset_settings: {
          playback_policies: ['public'],
        },
        max_continuous_duration: 43200,
        low_latency: true,
        latency_mode: 'low',
        id: '1TaauZVrUfXwkpUxKVWQiSOD02YWhTpan',
        created_at: 1706884405,
        connected: true,
        active_ingest_protocol: 'rtmp',
        active_asset_id: 'uGTBjfqFSPO4kgAj6Sll01LITWMLf500Gl',
      },
      created_at: '2024-04-04T19:00:37.613000Z',
      attempts: [],
      accessor_source: null,
      accessor: null,
    }),
  });
}

async function callNewAsset() {
  await fetch('/api/webhooks/mux', {
    method: 'post',
    body: JSON.stringify({
      type: 'video.asset.ready',
      request_id: null,
      object: {
        type: 'asset',
        id: 'IlEvde8ZuiOOjOZP9RjDC5k4kv00WZT3B',
      },
      id: '072d5897-baeb-4b5b-b10e-72399463ed35',
      environment: {
        name: 'Testing',
        id: 'j29sb4',
      },
      data: {
        upload_id: 'fib5TohlksKstELSGJHiGWTLkzTX72f00',
        tracks: [
          {
            type: 'video',
            max_width: 1920,
            max_height: 1080,
            max_frame_rate: 29.926,
            id: 'Xc2dXkAjz01sJNuExusNdT6jPycir48Na',
            duration: 10.024767,
          },
          {
            type: 'audio',
            status: 'ready',
            primary: true,
            name: 'Default',
            max_channels: 2,
            language_code: 'und',
            id: 'n4wBZBHPdmdCHT1RbsTgxBS6Ig3U40202Z5Tyh2Cze2HNTZNqR3ST1gA',
          },
        ],
        status: 'ready',
        resolution_tier: '1080p',
        playback_ids: [
          {
            policy: 'public',
            id: 'SJOkDeyn6asBEJ735VfQ7tQ6qotMhmkY',
          },
        ],
        mp4_support: 'none',
        max_stored_resolution: 'HD',
        max_stored_frame_rate: 29.926,
        max_resolution_tier: '1080p',
        master_access: 'none',
        ingest_type: 'on_demand_direct_upload',
        id: 'IlEvde8ZuiOOjOZP9RjDC5k4kv00WZT3B',
        encoding_tier: 'baseline',
        duration: 10.066667,
        created_at: 1712262539,
        aspect_ratio: '16:9',
      },
      created_at: '2024-04-04T20:29:02.294000Z',
      attempts: [],
      accessor_source: null,
      accessor: null,
    }),
  });
}
