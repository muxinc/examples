import fetch from 'isomorphic-unfetch';
import Player from '../components/player';
import Layout from '../components/layout';
import Link from 'next/link';
import { colors } from '../utils/theme';

const Show = ({ video }) => (
  <Layout>
    <h1>
      <Link href="/" prefetch>
        <a className="back">&lt;</a>
      </Link>
      {video.title}
    </h1>

    {video.status === 'ready' && (
      <div className="player">
        <Player playbackId={video.playbackId} />
      </div>
    )}

    <p>{video.description}</p>

    <style jsx>{`
      h1 {
        position: relative;
      }

      .back {
        color: ${colors.success()};
        text-decoration: none;
        position: absolute;
        left: -1em;
      }
    `}</style>
  </Layout>
);

Show.getInitialProps = async ({ query }) => {
  const res = await fetch(
    `https://airtable-video-cms.now.sh/api/videos/${query.id}`
  );
  const video = await res.json();

  return { video };
};

export default Show;
