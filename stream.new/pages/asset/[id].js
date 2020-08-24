import { useState, useEffect } from 'react';
import Router, { useRouter } from 'next/router';
import useSwr from 'swr';
import Layout from '../../components/layout';

const fetcher = (url) => fetch(url).then((res) => res.json());

export default function Asset () {
  const router = useRouter();
  const [isDarkMode, setIsDarkMode] = useState(true);

  const { data, error } = useSwr(
    () => (router.query.id ? `/api/asset/${router.query.id}` : null),
    fetcher,
    { refreshInterval: 5000 },
  );

  const asset = data && data.asset;

  useEffect(() => {
    if (asset && asset.playback_id && asset.status === 'ready') {
      Router.push(`/v/${asset.playback_id}`);
    }
  }, [asset]);

  useEffect(() => {
    const interval = setInterval(() => {
      setIsDarkMode((val) => !val);
    }, 3000);
    return () => clearInterval(interval);
  }, []);

  let errorMessage;

  if (error) {
    errorMessage = 'Error fetching api';
  }

  if (data && data.error) {
    errorMessage = data.error;
  }

  if (asset && asset.status === 'errored') {
    const message = asset.errors && asset.errors.messages[0];
    errorMessage = `Error creating this asset: ${message}`;
  }

  return (
    <Layout footerLinks={[]} darkMode={isDarkMode}>
      {
        errorMessage
          ? <div>{errorMessage}</div>
          : <div className="preparing">Preparing</div>
      }
      <style jsx>{`
        .preparing {
          font-size: 96px;
          line-height: 120px;
          color: ${isDarkMode ? '#fff' : '#111'};
          transition: color 1s ease;
        }
      `}
      </style>
    </Layout>
  );
}
