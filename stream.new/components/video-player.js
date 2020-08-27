import { useState, useEffect, useRef } from 'react';
import Hls from 'hls.js';
import { breakpoints } from '../style-vars';

const noop = () => {};

/*
 * We need to set the width/height of the player depending on what the dimensions of
 * the underlying video source is.
 *
 * On most platforms we know the dimensions on 'loadedmetadata'
 * However, on Desktop Safari we don't know the dimensions until 'canplay'
 *
 * The smart thing to do here seems to be to keep the `video` element `display: none` until
 * we know the dimensions. This works great, except that on Mobile Safari we don't get any
 * of those callbacks until *the user interacts with the player*
 *
 * Therefore, we're kind of stuck here. We have to show the player and then adjust the dimensions
 * as soon as we get those callbacks.
 *
 * For that reason, vertical videos sort of "jump" and re-size right after loaded.
 *
 */
export default function VideoPlayer ({ src, poster, onError = noop }) {
  const videoRef = useRef(null);
  const [playerWidth, setPlayerWidth] = useState('1000px');
  const [playerHeight, setPlayerHeight] = useState('auto');

  const canplay = (event) => {
    const [w, h] = [event.target.videoWidth, event.target.videoHeight];
    if (w && h) {
      const vertical = (w / h) < 1;
      if (vertical) {
        setPlayerWidth('auto');
        setPlayerHeight('70vh');
      } else {
        setPlayerWidth('1000px');
        setPlayerHeight('auto');
      }
    }
  };

  const error = (event) => onError(event);

  useEffect(() => {
    const video = videoRef.current;
    let hls;
    if (video) {
      video.addEventListener('canplay', canplay);
      video.addEventListener('loadedmetadata', canplay);
      video.addEventListener('error', error);

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
      video.removeEventListener('canplay', canplay);
      video.addEventListener('loadedmetadata', canplay);
      video.removeEventListener('error', error);
      if (hls) {
        hls.destroy();
      }
    };
  }, [src, videoRef]);

  return (
    <>
      <video ref={videoRef} poster={poster} controls />
      <style jsx>{`
        video {
          display: block;
          width: ${playerWidth};
          height: ${playerHeight};
          max-width: 100%;
          max-height: 50vh;
          cursor: pointer;
          margin-top: 40px;
          margin-bottom: 40px;
        }
        @media only screen and (min-width: ${breakpoints.md}px) {
          video {
            max-height: 80vh;
          }
        }
      `}
      </style>
    </>
  );
}
