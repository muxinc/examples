import { useState, useEffect, useRef } from 'react';
import Hls from 'hls.js';

const noop = () => {};

export default function VideoPlayer ({ src, poster, onLoaded = noop }) {
  const videoRef = useRef(null);
  const [isVertical, setIsVertical] = useState(null);

  const canplay = (event) => {
    const [w, h] = [event.target.videoWidth, event.target.videoHeight];
    setIsVertical((w / h) < 1);
    onLoaded();
  };

  useEffect(() => {
    const video = videoRef.current;
    let hls;
    if (video) {
      video.controls = true;
      video.addEventListener('canplay', canplay);

      if (video.canPlayType('application/vnd.apple.mpegurl')) {
        // This will run in safari, where HLS is supported natively
        video.src = src;
      } else if (Hls.isSupported()) {
        // This will run in all other modern browsers
        hls = new Hls();
        hls.loadSource(src);
        hls.attachMedia(video);
      } else {
        console.error( // eslint-disable-line no-console
          'This is an old browser that does not support MSE https://developer.mozilla.org/en-US/docs/Web/API/Media_Source_Extensions_API',
        );
      }
    }

    return () => {
      video.removeEventListener('loadedMetadata', canplay);
      if (hls) {
        hls.destroy();
      }
    };
  }, [src, videoRef]);

  return (
    <>
      <video ref={videoRef} poster={poster} />
      <style jsx>{`
        video {
          display: ${isVertical === null ? 'none' : 'block'};
          width: ${isVertical ? '500px' : '1000px'};
          height: ${isVertical ? '70vh' : 'auto'};
          max-width: 100%;
          cursor: pointer;
          padding-top: 40px;
          padding-bottom: 40px;
        }
      `}
      </style>
    </>
  );
}
