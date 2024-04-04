import mux from '$lib/mux';
import type { Actions, PageServerLoad } from './$types';
import { redirect, fail } from '@sveltejs/kit';

export const load = (async () => {
	// Create an endpoint for MuxUploader to upload to
	const upload = await mux.video.uploads.create({
		new_asset_settings: {
			playback_policy: ['public'],
			encoding_tier: 'baseline'
		},
		// in production, you'll want to change this origin to your-domain.com
		cors_origin: '*'
	});
	return { id: upload.id, url: upload.url };
}) satisfies PageServerLoad;

export const actions = {
	default: async ({ request }) => {
		const formData = await request.formData();
		const uploadId = formData.get('id');
		const uploadUrl = formData.get('url');
		if (typeof uploadId !== 'string') {
			return fail(400, { id: uploadId, url: uploadUrl, message: 'No uploadId found' });
		}

		// when the upload is complete,
		// the upload will have an assetId associated with it
		// we'll use that assetId to view the video status
		const upload = await mux.video.uploads.retrieve(uploadId);
		if (upload.asset_id) {
			redirect(303, `/status/${upload.asset_id}`);
		}

		// while onSuccess is a strong indicator that Mux has received the file
		// and created the asset, this isn't a guarantee.
		// In production, you might write an api route
		// to listen for the`video.upload.asset_created` webhook
		// https://docs.mux.com/guides/listen-for-webhooks
		// However, to keep things simple here,
		// we'll just ask the user to push the button again.
		// This should rarely happen.
		return fail(409, {
			id: uploadId,
			url: uploadUrl,
			message: 'Upload has no asset yet. Try again.'
		});
	}
} satisfies Actions;
