import Head from 'next/head';
import Link from 'next/link';
import { useDropzone } from 'react-dropzone';
import { breakpoints } from '../style-vars';
import Globe from './globe';
// import { MUX_HOME_PAGE_URL } from '../constants';

const InfoLink = () => <Link href="/about"><a>Info</a></Link>;
const GlobeLink = () => <Link href="/"><a><Globe /></a></Link>;

export default function Layout ({
  title,
  description,
  metaTitle,
  metaDescription,
  image,
  alignTop,
  footerLinks = [<InfoLink />, <GlobeLink />],
  onFileDrop,
  darkMode,
  children,
}) {
  const { getRootProps, isDragActive } = useDropzone({ onDrop: onFileDrop });

  return (
    <div className="container" {...getRootProps()}>
      <Head>
        <title>stream.new</title>
        <link rel="icon" href="/favicon.ico" />
        {metaTitle && <meta property="og:title" content={metaTitle} />}
        {metaTitle && <meta property="twitter:title" content={metaTitle} />}
        {metaDescription && (
          <meta property="og:description" content={description} />
        )}
        {metaDescription && (
          <meta property="twitter:description" content={description} />
        )}
        {image && <meta property="og:image" content={image} />}
        {image && (
          <meta property="twitter:card" content="summary_large_image" />
        )}
        {image && <meta property="twitter:image" content={image} />}
      </Head>
      <div className={`drag-overlay ${isDragActive ? 'active' : ''}`}><h1>Upload to stream.new</h1></div>

      <main>
        <div className="grid">{children}</div>
      </main>
      <footer>
        {footerLinks.map((link, idx) => <div key={idx} className="footer-link">{link}</div>)} {/* eslint-disable-line react/no-array-index-key */}
      </footer>

      <style jsx>{`
        .container {
          min-height: 100vh;
          min-height: -webkit-fill-available;
          display: flex;
          flex-direction: column;
          justify-content: center;
          align-items: center;
          background: ${darkMode ? '#000' : '#fff'};
          transition: background 1s ease;
        }
        .drag-overlay {
          height: 100%;
          width: 100%;
          position: absolute;
          z-index: 1;
          background-color:  rgba(226, 253, 255, 0.95);
          transition: 0.5s;
          display: none;
          flex-direction: column;
          justify-content: center;
          align-items: center;
        }

        .drag-overlay h1 {
          font-size: 46px;
          line-height: 46px;
          text-align: center;
        }

        .drag-overlay.active {
          display: flex;
        }

        main {
          padding: 20px;
          flex: 1;
          display: flex;
          flex-direction: column;
          justify-content: ${(alignTop && 'flex-start') || 'center'};
          align-items: center;
        }

        footer {
          width: 100%;
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding-left: 30px;
          padding-right: 30px;
          padding-bottom: 30px;
        }

        .footer-link {
          font-size: 26px;
          line-height: 33px;
        }

        .footer-link :global(a), .footer-link :global(a:visited) {
          color: ${darkMode ? '#ccc' : '#383838'};
          text-decoration: none;
        }

        .grid {
          display: flex;
          flex-direction: column;
          align-items: flex-start;
          justify-content: center;
          max-width: 800px;
        }

        @media only screen and (min-width: ${breakpoints.md}px) {
          .grid {
            align-items: center;
          }
          .drag-overlay h1 {
            font-size: 96px;
            line-height: 120px;
          }
        }
      `}
      </style>

      <style jsx global>{`
        html,
        body,
        a,
        a:visited {
          padding: 0;
          margin: 0;
          font-family: Akkurat;
          color: #383838;
        }

        h1 {
          font-family: Akkurat;
          font-style: normal;
          font-weight: normal;
          font-size: 36px;
          line-height: 45px;
          margin: 0;
          text-align: left;
          color: #383838;
        }

        h2 {
          font-family: Akkurat;
          font-style: normal;
          font-weight: normal;
          font-size: 26px;
          line-height: 33px;
          color: #383838;
        }

        * {
          box-sizing: border-box;
        }
      `}
      </style>
    </div>
  );
}
