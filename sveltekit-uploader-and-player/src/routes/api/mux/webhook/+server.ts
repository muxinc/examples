import mux from '$lib/mux';
import { json, type RequestHandler } from '@sveltejs/kit';
import { MUX_WEBHOOK_SIGNING_SECRET } from '$env/static/private';

// while this isn't called anywhere in this example,
// It might be helpful to see what a mux webhook handler looks like.

export const POST: RequestHandler = async ({ request }) => {
	const body = await request.text();
	// mux.webhooks.unwrap will validate that the given payload was sent by Mux and parse the payload.
	// It will also provide type-safe access to the payload.
	// Generate MUX_WEBHOOK_SIGNING_SECRET in the Mux dashboard
	// https://dashboard.mux.com/settings/webhooks
	const event = mux.webhooks.unwrap(body, request.headers, MUX_WEBHOOK_SIGNING_SECRET);

	// you can also unwrap the payload yourself:
	// const event = await request.json();
	switch (event.type) {
		case 'video.upload.asset_created':
			// we might use this to know that an upload has been completed
			// and we can save its assetId to our database
			break;
		case 'video.asset.ready':
			// we might use this to know that a video has been encoded
			// and we can save its playbackId to our database
			break;
		// there are many more Mux webhook events
		// check them out at https://docs.mux.com/webhook-reference
		default:
			break;
	}

	return json({ message: 'ok' });
};
