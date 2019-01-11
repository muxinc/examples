import Router from 'next/router';

let UpChunk;
if (typeof window !== 'undefined') {
  UpChunk = require('@mux/upchunk');
}

class Upload extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      progress: 0,
      status: 'editing_details',
      error: undefined,
      uploader: undefined,
      title: '',
      description: '',
      video: undefined,
    };
  }

  getUploadUrl = async () => {
    const res = await fetch('https://airtable-video-cms.now.sh/api/videos', {
      method: 'POST',
      body: JSON.stringify({
        title: this.state.title,
        description: this.state.description,
      }),
    });

    if (!res.ok) {
      return this.setState({ error: 'Unable to get an upload url' });
    }

    const video = await res.json();
    this.state.video = video;

    return video.uploadUrl;
  };

  updateProgress = event => {
    console.log('progress', event);
    console.log(this.state);
    this.setState({ progress: event.detail });
  };

  uploadFinished = event => {
    console.log('finished', event);
    this.setState({ progress: 100, status: 'uploaded' });

    this.pollAsset();
  };

  changeTitle = e => {
    this.setState({ title: e.target.value });
  };

  changeDescription = e => {
    this.setState({ description: e.target.value });
  };

  finishEditing = () => {
    this.setState({ status: 'pick_file' });
  };

  onAddFile = e => {
    console.log('this thing happened');
    this.uploader = UpChunk.createUpload({
      endpoint: this.getUploadUrl,
      file: e.target.files[0],
      chunkSize: 5120,
    });

    this.setState({ status: 'uploading' });

    this.uploader.on('progress', this.updateProgress);
    this.uploader.on('success', this.uploadFinished);
  };

  pollAsset = async () => {
    const res = await fetch(
      `https://airtable-video-cms.now.sh/api/videos/${this.state.video.id}`
    );
    const video = res.json();
    if (video.status === 'processing') {
      setTimeout(() => this.pollAsset(), 750);
    }

    this.state.video = video;
  };

  render() {
    if (this.state.status === 'ready') {
    }
    return (
      <div>
        {this.state.error && <div className="error">{this.state.error}</div>}
        {this.state.status === 'editing_details' && (
          <div>
            <input
              type="text"
              onChange={this.changeTitle}
              value={this.state.title}
              placeholder="Some Great Title"
            />
            <textarea
              onChange={this.changeDescription}
              placeholder="Wow what an interesting description."
              value={this.state.description}
            />
            <button onClick={this.finishEditing}>Pick a file</button>
          </div>
        )}

        {this.state.status === 'pick_file' && (
          <input type="file" onChange={this.onAddFile} />
        )}

        {this.state.status === 'uploading' && (
          <div className="progress">Uploaded {this.state.progress}%</div>
        )}

        {(this.state.status === 'uploaded' ||
          this.state.status === 'processing') && (
          <div className="processing">
            Your file is uploaded! Waiting for the asset to be playable...
          </div>
        )}

        {this.state.status === 'ready' && (
          <div className="success">
            Video is ready! Redirecting you to the view page...
            {setTimeout(
              () => Router.push(`/show?id=${this.state.video.id}`),
              2500
            )}
          </div>
        )}
      </div>
    );
  }
}

export default Upload;
