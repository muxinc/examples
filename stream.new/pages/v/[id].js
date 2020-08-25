import { useState } from 'react';
import { useRouter } from 'next/router';
import Link from 'next/link';
import Layout from '../../components/layout';
import VideoPlayer from '../../components/video-player';
import Spinner from '../../components/spinner';
import { breakpoints } from '../../style-vars';

export function getStaticProps ({ params: { id: playbackId } }) {
  const src = `https://stream.mux.com/${playbackId}.m3u8`;
  const poster = `https://image.mux.com/${playbackId}/thumbnail.png`;
  const shareUrl = `https://stream.new/v/${playbackId}`;

  return { props: { playbackId, src, poster, shareUrl } };
}

const InfoLink = () => <Link href="/about"><a>Info</a></Link>;
const HomeLink = () => <Link href="/"><a>Home</a></Link>;

export function getStaticPaths () {
  return {
    paths: [],
    fallback: true,
  };
}

export default function Playback ({ shareUrl, src, poster }) {
  const [isLoaded, setIsLoaded] = useState(false);
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
      footerLinks={[<InfoLink />, <HomeLink />]}
      darkMode
    >
      <div className="wrapper">
        <VideoPlayer src={src} poster={poster} onLoaded={() => setIsLoaded(true)} />
        <div className="share-url">{shareUrl}</div>
      </div>
      <style jsx>{`
        @media only screen and (min-width: ${breakpoints.md}px) {
          .wrapper {
            flex-grow: 1;
            display: ${isLoaded ? 'flex' : 'none'};
            flex-direction: column;
            align-items: center;
            justify-content: center;
          }
        }
        .share-url {
          word-break: break-word;
          color: #777;
        }
      `}
      </style>
    </Layout>
  );
}
