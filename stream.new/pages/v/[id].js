import { useRouter } from 'next/router';
import Layout from '../../components/layout';
import VideoPlayer from '../../components/video-player';
import Spinner from '../../components/spinner';

export function getStaticProps ({ params: { id: playbackId } }) {
  const src = `https://stream.mux.com/${playbackId}.m3u8`;
  const poster = `https://image.mux.com/${playbackId}/thumbnail.png`;

  return { props: { playbackId, src, poster } };
}

export function getStaticPaths () {
  return {
    paths: [],
    fallback: true,
  };
}

export default function Playback ({ src, poster }) {
  const router = useRouter();

  if (router.isFallback) {
    return (
      <Layout>
        <Spinner />
      </Layout>
    );
  }

  return (
    <Layout
      metaTitle="View this video created on stream.new"
      image={poster}
      darkMode
    >
      <VideoPlayer src={src} poster={poster} />
    </Layout>
  );
}
