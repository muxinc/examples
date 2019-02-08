import Hls from 'hls.js';

class Player extends React.Component {
  constructor(props) {
    super(props);

    this.player = React.createRef();
  }

  playbackUrl() {
    return `https://stream.mux.com/${this.props.playbackId}.m3u8`;
  }

  componentDidMount() {
    if (Hls.isSupported()) {
      var hls = new Hls();
      hls.loadSource(this.playbackUrl());
      hls.attachMedia(this.player.current);
    } else if (video.canPlayType('application/vnd.apple.mpegurl')) {
      this.player.current.src = this.playbackUrl();
    }
  }

  render() {
    return (
      <div>
        <video ref={this.player} preload="true" controls />

        <style jsx>{`
          video {
            max-width: 100%;
            margin: 0 auto;
          }
        `}</style>
      </div>
    );
  }
}

export default Player;
