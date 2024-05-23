import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

import { Knock } from '@knocklabs/node';
const knockClient = new Knock(process.env.KNOCK_SECRET_KEY);

export async function POST(request: Request) {
  const body = await request.text();
  const inlineUser = {
    id: 'fde69556-a3a5-4812-a3e9-c9ded0cbc950',
    name: 'John Hammond',
    email: 'hammond@ingen.net',
  };
  knockClient.workflows.trigger('new-view', {
    recipients: [process.env.NEXT_PUBLIC_KNOCK_USER_ID as string],
    data: JSON.parse(body),
  });

  return Response.json({ message: 'ok' });
}
