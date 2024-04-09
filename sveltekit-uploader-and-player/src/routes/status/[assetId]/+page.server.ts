import { error, redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
import mux from '$lib/mux';

export const load: PageServerLoad = (async ({ params }) => {
	// now that we have an assetId, we can see how the video is doing.
	// in production, you might have some setup where a Mux webhook
	// tells your server the status of your asset.
	// https://docs.mux.com/guides/listen-for-webhooks
	// for this example, however, we'll just ask the Mux API ourselves
	const { assetId } = params;
	if (typeof assetId !== 'string') {
		error(404, { message: 'No assetId found' });
	}
	const asset = await mux.video.assets.retrieve(assetId);

	// if the asset is ready and it has a public playback ID,
	// (which it should, considering the upload settings we used)
	// redirect to its playback page
	if (asset.status === 'ready') {
		const playbackIds = asset.playback_ids;
		if (Array.isArray(playbackIds)) {
			const playbackId = playbackIds.find((id) => id.policy === 'public');
			if (playbackId) {
				redirect(303, `/playback/${playbackId.id}`);
			}
		}
	}

	// if the asset is not ready, we'll keep polling
	return {
		status: asset.status,
		errors: asset.errors
	};
}) satisfies PageServerLoad;
