import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

import { Knock } from '@knocklabs/node';
const knockClient = new Knock(process.env.KNOCK_SECRET_KEY);

const subscriptions = [
  {
    id: '9d17eb2d-1980-4614-bcfe-5696ca9be631',
    properties: {
      role: 'regular',
    },
  },
  {
    id: 'a12896b9-658b-43ff-8d5b-79c34215778a',
    properties: {
      role: 'allAccess',
    },
  },
];

export async function POST(request: Request) {
  const body = await request.text();
  const payload = JSON.parse(body);
  if (payload.action === 'create') {
    channels.forEach(async (channel) => {
      subscriptions.forEach(async (subscription) => {
        await knockClient.objects.addSubscriptions('channels', channel.id, {
          recipients: [subscription.id],
          properties: subscription.properties,
        });
      });
    });
  }

  if (payload.action === 'delete') {
    channels.forEach(async (channel) => {
      subscriptions.forEach(async (subscription) => {
        await knockClient.objects.deleteSubscriptions('channels', channel.id, {
          recipients: [subscription.id],
        });
      });
    });
  }
  return Response.json({ message: 'ok' });
}
const channels = [
  {
    id: 'knock',
    properties: {
      name: 'Knock',
      icon: '🔔',
      YouTube: 'https://www.youtube.com/channel/UCDScOjujAI3-_9iJ0Me0Aug',
      Twitter: 'https://twitter.com/knocklabs',
    },
  },
  {
    id: 'mux',
    properties: {
      name: 'Mux',
      icon: '📹',
      YouTube: 'https://www.youtube.com/@MuxHQ',
      Twitter: 'https://twitter.com/MuxHQ',
    },
  },
];
