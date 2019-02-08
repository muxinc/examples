import Hls from 'hls.js';
import '../common/style.scss';
import './hlsjs.scss';

const container = document.getElementById('app');
const params = new URLSearchParams(window.location.search.substring(1));
const playbackId = params.get('playback_id');

if (!playbackId) {
  container.innerHTML = `<div class="error"><h2>Mux Playback ID is required</h2></div>`;
} else {
  container.innerHTML = `
    <div class="player-container">
      <video id="player" controls></video>
    </div>
  `;

  const video = document.getElementById('player');
  const streamUrl = `https://stream.mux.com/${playbackId}.m3u8`;
  if (Hls.isSupported()) {
    var hls = new Hls();
    hls.loadSource(streamUrl);
    hls.attachMedia(video);
  } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
    video.src = streamUrl;
  }
}
