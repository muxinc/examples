import React from 'react';
import videojs from 'video.js';

import './Player.scss';
import 'videojs-contrib-hls.js';

class Player extends React.Component {

  constructor(props) {
    super(props);
  }

  componentDidMount() {
    this.player = videojs(this.videoNode, this.props.playerOptions);
  }

  // destroy player on unmount
  componentWillUnmount() {
    if (this.player) {
      this.player.dispose();
    }
  }

  shouldComponentUpdate(nextProps) {
    if (this.player && nextProps.playerOptions.sources[0].src !== this.props.playerOptions.sources[0].src) {
      this.player.src(nextProps.playerOptions.sources[0]);
      this.player.play();
      return true;
    }
    return false;
  }

  render() {
    const playerRef = (node) => this.videoNode = node;
    return (
      <div className="Player">
        <div className="Player__wrapper">
          <div data-vjs-player>
            <video ref={playerRef} className="video-js"/>
          </div>
        </div>
      </div>
    );
  }
}

Player.defaultProps = {
};

export default Player;
