'use client';
import { useState, useRef, useEffect } from 'react';
import {
  KnockProvider,
  KnockFeedProvider,
  NotificationIconButton,
  NotificationFeedPopover,
  BellIcon,
} from '@knocklabs/react';

// Required CSS import, unless you're overriding the styling
import '@knocklabs/react/dist/index.css';
import FeedToasts from './FeedToasts';

const FeedContainer = () => {
  const [isVisible, setIsVisible] = useState(false);
  const [isClient, setIsClient] = useState(false);
  const notifButtonRef = useRef(null);
  useEffect(() => {
    setIsClient(true);
  }, []);
  return isClient ? (
    <KnockProvider
      apiKey={process.env.NEXT_PUBLIC_KNOCK_API_KEY as string}
      userId={process.env.NEXT_PUBLIC_KNOCK_USER_ID as string}
    >
      <KnockFeedProvider
        feedId={process.env.NEXT_PUBLIC_KNOCK_FEED_CHANNEL_ID as string}
        colorMode="dark"
      >
        <>
          <NotificationIconButton
            ref={notifButtonRef}
            onClick={(e) => setIsVisible(!isVisible)}
          />
          <NotificationFeedPopover
            buttonRef={notifButtonRef}
            isVisible={isVisible}
            onClose={() => setIsVisible(false)}
          />
          {/* <FeedToasts></FeedToasts> */}
        </>
      </KnockFeedProvider>
    </KnockProvider>
  ) : (
    <BellIcon />
  );
};

export default FeedContainer;
