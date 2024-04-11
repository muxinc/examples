import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';

import Mux from '@mux/mux-node';

const { Knock } = require("@knocklabs/node");
const knockClient = new Knock(process.env.KNOCK_API_KEY);

const mux = new Mux({
    webhookSecret: process.env.MUX_WEBHOOK_SECRET,
});

export async function POST(request: Request) {
    const headersList = headers();
    const body = await request.text();
    const event = mux.webhooks.unwrap(body, headersList);

    switch (event.type) {
        case 'video.live_stream.active':
        case 'video.asset.ready':
            // The key of the workflow (from Knock dashboard)
            await knockClient.notify("dinosaurs-loose", {
                // user id of who performed the action
                actor: "dnedry",
                // list of user ids for who should receive the notification
                recipients: ["jhammond", "agrant", "imalcolm", "esattler"],
                // data payload to send through
                data: event.data,
                // an optional identifier for the tenant that the notifications belong to
                tenant: "jurassic-park",
            });
            break;
        default:
            break;
    }

    return Response.json({ message: 'ok' });
}
