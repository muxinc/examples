import Router from 'next/router';
import Layout from '../components/layout';

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
    console.log('finished!!', event);
    this.setState({ progress: 100, status: 'uploaded' });

    this.pollAsset();
  };

  changeTitle = e => {
    this.setState({ title: e.target.value });
  };

  changeDescription = e => {
    this.setState({ description: e.target.value });
  };

  upload = () => {
    this.uploader = UpChunk.createUpload({
      endpoint: this.getUploadUrl,
      file: this.file,
      chunkSize: 5120,
    });
    this.setState({ status: 'uploading' });

    this.uploader.on('progress', this.updateProgress);
    this.uploader.on('success', this.uploadFinished);
  };

  onAddFile = e => {
    this.file = e.target.files[0];
  };

  pollAsset = async () => {
    console.log('aww yeah we pollin now');
    const res = await fetch(
      `https://airtable-video-cms.now.sh/api/videos/${this.state.video.id}`
    );
    const video = await res.json();

    if (
      video.status === 'waiting for upload' ||
      video.status === 'processing'
    ) {
      setTimeout(this.pollAsset, 750);
    }

    this.setState(video);
  };

  render() {
    console.log(this.state.status);
    return (
      <Layout>
        <h1>Upload a new video</h1>
        {this.state.error && <div className="error">{this.state.error}</div>}
        {this.state.status === 'editing_details' && (
          <div className="form">
            <input
              type="text"
              className="title"
              onChange={this.changeTitle}
              value={this.state.title}
              placeholder="Some Great Title"
            />
            <textarea
              onChange={this.changeDescription}
              placeholder="Wow what an interesting description."
              value={this.state.description}
            />
            <input type="file" onChange={this.onAddFile} />
            <button onClick={this.upload}>Upload</button>
          </div>
        )}

        {this.state.status === 'uploading' && (
          <div className="progress">Uploaded {this.state.progress}%</div>
        )}

        {(this.state.status === 'uploaded' ||
          this.state.status === 'waiting for upload' ||
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

        <style jsx>{`
          .form {
            display: flex;
            flex-direction: column;
          }

          .form input,
          .form textarea,
          .form button {
            margin: 0.5em 0;
            padding: 0.5em;
            border: 1px solid #ccc;
          }

          .form textarea {
            height: 100px;
          }

          .form button {
            display: block;
            background-color: #fff;
            padding: 1em 0;
            cursor: pointer;
            text-align: center;
          }
        `}</style>
      </Layout>
    );
  }
}

export default Upload;
