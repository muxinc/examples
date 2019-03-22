import fetch from 'isomorphic-unfetch';
import Link from 'next/link';

import Player from '../components/player';
import Layout from '../components/layout';
import { colors } from '../utils/theme';
import { getRequestPath } from '../utils/config';

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

Show.getInitialProps = async ({ req, query }) => {
  const res = await fetch(getRequestPath(req, `/api/videos/${query.id}`));
  const video = await res.json();

  return { video };
};

export default Show;
