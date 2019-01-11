import videojs from 'video.js';
import 'video.js/src/css/video-js.scss';
import '../common/style.scss';

const container = document.getElementById('app');
const params = new URLSearchParams(window.location.search.substring(1));
const playbackId = params.get('playback_id');

if (!playbackId) {
  container.innerHTML = `<div class="error"><h2>Mux Playback ID is required</h2></div>`;
} else {
  container.innerHTML = `
    <div class="player-container">
      <video id="player" class="video-js vjs-fluid"></video>
    </div>
  `;

  videojs('player', {
    autoplay: true,
    controls: true,
    sources: [
      {
        src: `https://stream.mux.com/${playbackId}.m3u8`,
        type: 'application/x-mpegurl',
      },
    ],
  });
}
