import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

import Mux from '@mux/mux-node';

import { Knock } from '@knocklabs/node';
const knockClient = new Knock(process.env.KNOCK_SECRET_KEY);

// const mux = new Mux({
//   webhookSecret: process.env.MUX_WEBHOOK_SECRET,
// });

export async function POST(request: Request) {
  const headersList = headers();
  const body = await request.text();
  const event = JSON.parse(body);
  console.log(event);
  //   const event = mux.webhooks.unwrap(body, headersList);

  switch (event.type) {
    case 'video.live_stream.active':
      console.log('📺 live stream started.....');
      const channel = await knockClient.objects.get('channels', 'knock');
      const { workflow_run_id } = await knockClient.workflows.trigger(
        'new-stream',
        {
          recipients: [{ collection: 'channels', id: 'knock' }],
          data: {
            channel,
          },
        }
      );
      break;
    case 'video.asset.ready':
      console.log('🎞️ new asset ready.....');

      console.log(`📨 new workflow run started: ${workflow_run_id}`);
      break;
    default:
      break;
  }

  return Response.json({ message: 'ok' });
}
