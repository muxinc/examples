import fetch from 'isomorphic-unfetch';
import Player from '../components/player';

const Show = ({ video }) => (
  <div>
    <h1>{video.title}</h1>

    <p>{video.description}</p>

    {video.status === 'ready' && (
      <div className="player">
        <Player playbackId={video.playbackId} />
      </div>
    )}
  </div>
);

Show.getInitialProps = async ({ query }) => {
  const res = await fetch(
    `https://airtable-video-cms.now.sh/api/videos/${query.id}`
  );
  const video = await res.json();

  return { video };
};

export default Show;
