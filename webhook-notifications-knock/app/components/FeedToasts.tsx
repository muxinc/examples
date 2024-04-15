import toast, { Toaster } from 'react-hot-toast';
import { useEffect } from 'react';
import { useKnockFeed } from '@knocklabs/react';

const FeedToasts = () => {
  const { feedClient } = useKnockFeed();

  const onNotificationsReceived = ({ items }) => {
    // Whenever we receive a new notification from our real-time stream, show a toast
    // (note here that we can receive > 1 items in a batch)
    console.log(items);
    items.forEach((notification) => {
      toast(
        `New view on ${notification.data.videoId} by ${notification.data.user}`,
        {
          id: notification.id,
          icon: '👏',
        }
      );
    });

    // Optionally, you may want to mark them as "seen" as well
    feedClient.markAsArchived(items);
  };

  useEffect(() => {
    // Receive all real-time notifications on our feed
    feedClient.on('items.received.realtime', onNotificationsReceived);

    // Cleanup
    return () =>
      feedClient.off('items.received.realtime', onNotificationsReceived);
  }, [feedClient]);

  return <Toaster />;
};

export default FeedToasts;
