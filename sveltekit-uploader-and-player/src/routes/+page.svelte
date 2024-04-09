<script lang="ts">
	import { enhance, applyAction } from '$app/forms';
	import '@mux/mux-uploader';
	import type { PageData, ActionData } from './$types';
	import { goto } from '$app/navigation';

	type Props = {
		data: PageData;
		form: ActionData;
	};
	let { data, form }: Props = $props();

	let isUploadSuccess = $state(false);
</script>

<form
	method="POST"
	use:enhance={() => {
		// after submitting the form, we don't need to run load again.
		// to avoid that default functionality, let's write our own enhance function.
		return async ({ result }) => {
			if (result.type === 'redirect') {
				goto(result.location);
			} else {
				await applyAction(result);
			}
		};
	}}
>
	<mux-uploader endpoint={data.url} on:success={() => (isUploadSuccess = true)} />
	<input type="hidden" name="url" value={form?.url ?? data.url} />
	<input type="hidden" name="id" value={form?.id ?? data.id} />
	<!-- you might have other fields here, like name and description,
			that you'll save in your CMS alongside the uploadId and assetId -->
	<button
		type="submit"
		class="my-4 p-4 py-2 rounded border border-blue-600 text-blue-600 disabled:border-gray-400 disabled:text-gray-400"
		disabled={!isUploadSuccess}
	>
		{isUploadSuccess ? 'Watch video' : 'Waiting for upload...'}
	</button>
	{#if form?.message}
		<p>{form?.message}</p>
	{/if}
</form>
