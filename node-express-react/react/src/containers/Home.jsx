import React from 'react';
import PlayerContainer from '../components/PlayerContainer/PlayerContainer';
import NavBar from '../components/NavBar/NavBar';
import SpinnerWrapper from '../components/SpinnerWrapper/SpinnerWrapper';

import {joinRoom, loginUser} from '../actions/auth';
import { getAssets, getPreSignedUrl, ingestVideo, uploadVideo } from '../actions/assets';

import {
  hasPersistedSession,
  getPersistedSession,
} from '../utils/auth';

import AssetDetails from '../components/AssetDetails/AssetDetails';
import BottomNav from "../components/BottomNav/BottomNav";

class Home extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      user: undefined,
      loadedAsset: undefined,
      videoSubmitting: false,
      slideIndex: 0,
      assets: [],
      loading: true,
    };
  }

  componentDidMount () {
    if (!hasPersistedSession()) {
      return loginUser()
        .then(() => this.initializeUserData())
    } else {
      return this.initializeUserData();
    }
  }

  initializeUserData = () => {
    const user = getPersistedSession();
    const socket = joinRoom(user.id);
    this.setState({ user });
    this.getUserAssets()
      .then(() => this.setState({ loadedAsset: this.state.assets[0], slideIndex: 0, loading: false }));

    socket.on('asset-updated', (updatedAsset) => {
      this.getUserAssets()
        .then(() => {
          const assetIndex = this.state.assets.length - 1;
          this.setState({ loadedAsset: this.state.assets[assetIndex], slideIndex: assetIndex });
        })
    });
  };

  handleFileUpload = (event) => {
    event.preventDefault();
    const file = event.target.files[0];
    this.setState({ videoSubmitting: true, loading: true });
    return getPreSignedUrl(file.name)
      .then(res => uploadVideo(res.url, file))
      .then(() => ingestVideo(file.name))
      .then(() => this.setState({ videoSubmitting: false, loading: false }))
      .catch(() => this.setState({ videoSubmitting: false, loading: false }))
  };

  getUserAssets = () => {
    return getAssets()
      .then(res => this.setState({ assets: res.data }));
  };

  loadVideo = (assetIndex) => {
    this.setState({ loadedAsset: this.state.assets[assetIndex], slideIndex: assetIndex });
  };

  handlePreviousClick = () => {
    const currentIndex = this.state.slideIndex;

    if (currentIndex !== 0) {
      const nextIndex = currentIndex - 1;
      this.setState({
        loadedAsset: this.state.assets[nextIndex],
        slideIndex: nextIndex,
      });
      this.loadVideo(nextIndex);
    }
  };

  handleNextClick = () => {
    const currentIndex = this.state.slideIndex;

    if (currentIndex !== this.state.assets.length - 1) {
      const nextIndex = currentIndex + 1;
      this.setState({
        loadedAsset: this.state.assets[nextIndex],
        slideIndex: nextIndex,
      });
      this.loadVideo(nextIndex);
    }
  };

  getLoadedAssetDetails = () => {
    if (this.state.assets.length) {
      const loadedAsset = !this.state.loadedAsset ? this.state.assets[0] : this.state.loadedAsset;
      return {
        url: `https://stream.mux.com/${loadedAsset.playback_ids[0].id}.m3u8`,
        status: loadedAsset.status,
      }
    }
    return { url: '' }
  };

  render() {
    const loadedAssetDetails = this.getLoadedAssetDetails();
    const playerOptions = {
      fluid: true,
      aspectRatio: '16:9',
      autoplay: true,
      controls: true,
      sources: [{
        src: loadedAssetDetails.url,
        type: 'application/x-mpegURL',
      }]
    };

    return (
      <div className="Home">
        <SpinnerWrapper loading={this.state.loading}>
          <NavBar user={this.state.user} history={this.props.history} />
          <PlayerContainer playerOptions={playerOptions} videoStatus={loadedAssetDetails.status} />
          {this.state.loadedAsset && (<AssetDetails asset={this.state.loadedAsset} />)}
        </SpinnerWrapper>
        {this.state.user &&
        (<BottomNav
          handlePreviousClick={this.handlePreviousClick}
          handleNextClick={this.handleNextClick}
          loading={this.state.videoSubmitting}
          handleFileUpload={this.handleFileUpload} />)}
      </div>
    )
  }
}

export default Home;
