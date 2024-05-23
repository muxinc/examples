'use client';

import MuxPlayer from '@mux/mux-player-react';

export default function Player() {
  return (
    <MuxPlayer
      playbackId="O6LdRc0112FEJXH00bGsN9Q31yu5EIVHTgjTKRkKtEq1k"
      onPlay={callOnPlay}
    />
  );
}

async function callOnPlay() {
  await fetch('/api/knock/on-play', {
    method: 'post',
    body: JSON.stringify({ videoId: 'test video', user: 'test user' }),
  });
}
