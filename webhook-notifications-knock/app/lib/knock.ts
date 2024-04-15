import { Knock } from '@knocklabs/node';
const knockClient = new Knock(process.env.KNOCK_SECRET_KEY);

export async function createChannel(channelName: string, props: Object) {
  await knockClient.objects.set('channels', channelName, props);
  return 'success';
}

export async function getSubscriptions(channelName: string) {
  const subscriptions = await knockClient.objects.getSubscriptions(
    'channels',
    channelName
  );
  return subscriptions;
}

export async function subscribeToChannel(channelName: string, userId: string) {
  const subscription = await knockClient.objects.addSubscriptions(
    'channels',
    channelName,
    { recipients: [userId] }
  );

  return subscription;
}
