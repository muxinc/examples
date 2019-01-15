import fetch from 'isomorphic-unfetch';
import Link from 'next/link';
import Layout from '../components/layout';

const Thumbnail = video => (
  <div>
    {video.playbackId ? (
      <img src={`https://image.mux.com/${video.playbackId}/thumbnail.jpg`} />
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

const Index = ({ videos }) => (
  <Layout>
    <h1>MeTube</h1>
    <p>Total Videos: {videos.length}</p>

    <ul>
      {videos.map(video => (
        <li key={video.id} className={video.status}>
          <Link href={{ pathname: '/show', query: { id: video.id } }}>
            <a>
              <strong>{video.title}</strong>
              <Thumbnail {...video} />
            </a>
          </Link>
        </li>
      ))}
    </ul>

    <style jsx>{`
      a {
        color: #fff;
      }

      ul {
        display: flex;
        flex-wrap: wrap;
        justify-content: space-between;
        padding: 0;
      }

      li {
        display: block;
        width: 200px;
        list-style: none;
      }

      .ready {
        color: green;
      }
    `}</style>
  </Layout>
);

Index.getInitialProps = async ({ req }) => {
  const res = await fetch('https://airtable-video-cms.now.sh/api/videos');
  const allVideos = await res.json();

  const ready = allVideos.filter(v => v.status === 'ready');
  return { videos: ready };
};

export default Index;
