<script lang="ts">
	import { page } from '$app/stores';
	import '@mux/mux-player';

	let playbackId = $derived($page.params.playbackId);
</script>

<div class="px-8 py-4 mb-8 text-center bg-green-500/30 rounded-full">
	This video is ready for playback
</div>
<div class="bg-black aspect-video mb-8 -mx-4 flex">
	<mux-player
		class="w-full"
		playback-id={playbackId}
		metadata={{ player_name: 'muxinc/examples/sveltekit-uploader-and-player' }}
		accentColor="rgb(220 38 38)"
	/>
</div>
<p>
	Go <a class="underline hover:no-underline focus-visible:no-underline text-blue-600" href="/">
		back home
	</a> to upload another video.
</p>
