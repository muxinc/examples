<script lang="ts">
	import { page } from '$app/stores';
	import '@videojs/html/video/player';
	import '@videojs/html/video/skin';
	import '@videojs/html/media/mux-video';
	import '@videojs/html/extensions/mux-data';

	let playbackId = $derived($page.params.playbackId);
	const title = 'View this video created with Mux + SvelteKit';
	const description =
		'This video was uploaded and processed by Mux in an example SvelteKit application.';
</script>

<div class="px-8 py-4 mb-8 text-center bg-green-500/30 rounded-full">
	This video is ready for playback
</div>
<div class="bg-black aspect-video mb-8 -mx-4 flex">
	<video-player class="w-full">
		<video-skin class="aspect-video" style="--media-accent-color: rgb(220 38 38)">
			<mux-video
				src="https://stream.mux.com/{playbackId}.m3u8"
				playsinline
				crossorigin="anonymous"
			></mux-video>
			<mux-data metadata={{ player_name: 'muxinc/examples/sveltekit-uploader-and-player' }}
			></mux-data>
		</video-skin>
	</video-player>
</div>
<p>
	Go <a class="underline hover:no-underline focus-visible:no-underline text-blue-600" href="/">
		back home
	</a> to upload another video.
</p>

<svelte:head>
	<title>{title}</title>
	<meta name="description" content={description} />
	<meta property="og:type" content="video" />
	<meta property="og:title" content={title} />
	<meta property="og:description" content={description} />
	<meta
		property="og:image"
		content="https://image.mux.com/{playbackId}/thumbnail.png?width=1200&height=630&fit_mode=pad"
	/>
	<meta property="og:image:width" content="1200" />
	<meta property="og:image:height" content="630" />
	<meta property="twitter:card" content="summary_large_image" />
	<meta property="twitter:title" content={title} />
	<meta property="twitter:description" content={description} />
	<meta
		property="twitter:image"
		content="https://image.mux.com/{playbackId}/thumbnail.png?width=1200&height=600&fit_mode=pad"
	/>
	<meta property="twitter:image:width" content="1200" />
	<meta property="twitter:image:height" content="600" />
	<!-- 
		These tags should be sufficient for social sharing.
  	However, if you're really committed video SEO, I'd suggest adding ld+json, as well.
  	https://developers.google.com/search/docs/appearance/structured-data/video
	-->
</svelte:head>
