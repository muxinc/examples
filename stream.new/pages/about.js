import Link from 'next/link';
import Layout from '../components/layout';
import { MUX_HOME_PAGE_URL, OPEN_SOURCE_URL } from '../constants';

const CloseLink = () => <Link href="/"><a>Close</a></Link>;

export default function About () {
  return (
    <Layout
      alignTop
      footerLinks={[<CloseLink />]}
    >
      <h1>This is an <a href={OPEN_SOURCE_URL}>open source</a> project from <a href={MUX_HOME_PAGE_URL}>Mux</a>, the video streaming API.</h1>
      <style jsx>{`
      `}
      </style>
    </Layout>
  );
}
