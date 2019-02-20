import React from 'react';
import Player from '../Player/Player';
import './PlayerContainer.scss';

const StatusMessage = ({ message }) => {
  return (
    <div className="PlayerContainer__statusContainer">
      <span className="PlayerContainer__statusMessage">{message}</span>
    </div>
  )
};

class PlayerContainer extends React.Component {

  constructor(props) {
    super(props);
  }

  getStatusMessage = () => {
    let message = '';
    switch(this.props.videoStatus) {
      case 'errored':
        message = this.props.errorMessage;
        break;
      case 'preparing':
        message = this.props.preparingMessage;
        break;
      default:
        message = 'Upload a video and encode with Mux';
    }
    return message;
  };

  render() {
    return (
      <div className="PlayerContainer">
        { this.props.videoStatus !== 'ready'
          ? (<StatusMessage message={this.getStatusMessage()} />)
          : (<Player playerOptions={this.props.playerOptions} />)
        }
      </div>
    )
  }
}

PlayerContainer.defaultProps = {
  videoStatus: '',
  errorMessage: 'An error with this video has occurred',
  emptyMessage: 'No video to load',
  preparingMessage: 'Mux is preparing your video',
  playerOptions: {
    fluid: true,
    width: '100%',
    height: '100%',
    autoplay: false,
    controls: true,
    sources: [{
      src: '',
      type: 'application/x-mpegURL'
    }]
  }
};

export default PlayerContainer;
