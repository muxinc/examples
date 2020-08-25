import Link from 'next/link';
import Layout from '../components/layout';
import { breakpoints } from '../style-vars';
import { MUX_HOME_PAGE_URL, OPEN_SOURCE_URL } from '../constants';

const CloseLink = () => <Link href="/"><a>Close</a></Link>;

export default function About () {
  return (
    <Layout
      footerLinks={[<CloseLink />]}
    >
      <div className="wrapper">
        <h1>This is an <a href={OPEN_SOURCE_URL}>open source</a> project from <a href={MUX_HOME_PAGE_URL}>Mux</a>, the video streaming API.</h1>
      </div>
      <style jsx>{`
        @media only screen and (min-width: ${breakpoints.md}px) {
          .wrapper {
            flex-grow: 1;
            display: flex;
            align-items: center;
          }
          h1 {
            text-align: center;
          }
        }
      `}
      </style>
    </Layout>
  );
}
