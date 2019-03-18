import fetch from 'isomorphic-unfetch';
import Link from 'next/link';
import Layout from '../components/layout';
import Thumbnail from '../components/thumbnail';
import { colors } from '../utils/theme';
import { path } from '../utils/config';

const Index = ({ videos }) => (
  <Layout>
    <h1>MeTube: Now + Airtable + Mux</h1>
    <p>
      Total Videos: <span className="total">{videos.length}</span>
    </p>

    <ul>
      {videos.map(video => (
        <li key={video.id} className={video.status}>
          <Link href={{ pathname: '/show', query: { id: video.id } }} prefetch>
            <a>
              <strong>{video.title}</strong>
              <Thumbnail video={video} />
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
        margin: 0.5em;
      }

      .ready {
        color: ${colors.success()};
      }

      .total {
        color: ${colors.success()};
      }
    `}</style>
  </Layout>
);

Index.getInitialProps = async ({ req }) => {
  const res = await fetch(path(req, '/api/videos'));
  const allVideos = await res.json();

  const ready = allVideos.filter(v => v.status === 'ready');
  return { videos: ready };
};

export default Index;
