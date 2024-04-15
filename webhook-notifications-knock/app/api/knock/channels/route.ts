import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

import { Knock } from '@knocklabs/node';
const knockClient = new Knock(process.env.KNOCK_SECRET_KEY);

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

export async function POST(request: Request) {
  const body = await request.text();
  const payload = JSON.parse(body);
  if (payload.action === 'create') {
    channels.forEach(async (channel) => {
      await knockClient.objects.set('channels', channel.id, channel.properties);
    });
  }

  if (payload.action === 'delete') {
    channels.forEach(async (channel) => {
      await knockClient.objects.delete('channels', channel.id);
    });
  }
  return Response.json({ message: 'ok' });
}
