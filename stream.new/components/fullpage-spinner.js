import Layout from './layout';
import Spinner from './spinner';

export default function FullpageSpinner ({ darkMode }) {
  return (
    <Layout darkMode={darkMode}>
      <div className="wrapper">
        <Spinner />
      </div>
      <style jsx>{`
        .wrapper {
          justify-content: center;
          flex-direction: column;
          display: flex;
          flex-grow: 1;
        }
      `}
      </style>
    </Layout>
  );
}
