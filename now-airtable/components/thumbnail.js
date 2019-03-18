import React from 'react';

class Thumbnail extends React.Component {
  onHover = () => this.setState({ hovered: true });

  offHover = () => this.setState({ hovered: false });

  imageSrc = () => {
    const fileAndExtension = this.state.hovered
      ? 'animated.gif'
      : 'thumbnail.png';
    return `https://image.mux.com/${
      this.props.video.playbackId
    }/${fileAndExtension}`;
  };

  constructor(props) {
    super(props);

    this.state = {
      hovered: false,
    };
  }

  render() {
    return (
      <div>
        {this.props.video.playbackId ? (
          <img
            onMouseEnter={this.onHover}
            onMouseLeave={this.offHover}
            src={this.imageSrc()}
          />
        ) : (
          <span>No thumbnail for some reason</span>
        )}

        <style jsx>{`
          img {
            max-width: 100%;
          }
        `}</style>
      </div>
    );
  }
}

export default Thumbnail;
