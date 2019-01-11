import fetch from 'isomorphic-unfetch';
import Link from 'next/link';

const Thumbnail = video =>
  video.playbackId ? (
    <img src={`https://image.mux.com/${video.playbackId}/thumbnail.jpg`} />
  ) : (
    <span>No thumbnail for some reason</span>
  );

const Index = ({ videos }) => (
  <div>
    <h2>Total Videos: {videos.length}</h2>

    <ul>
      {videos.map(video => (
        <li key={video.id} className={video.status}>
          <Link href={{ pathname: '/show', query: { id: video.id } }}>
            <a>Look at it</a>
          </Link>
          <Thumbnail {...video} />
          {video.title}
        </li>
      ))}
    </ul>

    <style jsx>{`
      .ready {
        color: green;
      }
    `}</style>
  </div>
);

Index.getInitialProps = async ({ req }) => {
  const res = await fetch('https://airtable-video-cms.now.sh/api/videos');
  const allVideos = await res.json();

  const ready = allVideos.filter(v => v.status === 'ready');
  return { videos: ready };
};

export default Index;
