<script lang="ts">
	import { invalidateAll } from '$app/navigation';
	import type { PageData } from './$types';

	type Props = {
		data: PageData;
	};
	let { data }: Props = $props();

	// let's set off an interval to periodically re-run the loader...
	$effect(() => {
		const interval = setInterval(invalidateAll, 2000);
		return () => clearInterval(interval);
	});
</script>

{#if data.status === 'preparing'}
	<p class="animate-pulse font-mono">Asset is preparing...</p>
{:else}
	<!-- 
		if not preparing, then "errored" or "ready"
		if "errored", we'll show the errors
		we don't expect to see "ready" because "ready" should redirect in the action 
	-->
	<p class="mb-4 font-mono">
		Asset is in an unexpected state: <code>{data.status}</code>.
	</p>
	{#if Array.isArray(data.errors)}
		<ul class="mb-4 font-mono">
			{#each data.errors as error}
				<li>{JSON.stringify(error)}</li>
			{/each}
		</ul>
	{/if}
	<p class="font-mono">
		This is awkward. Let&apos;s <a
			class="underline hover:no-underline focus-visible:no-underline text-blue-600"
			href="/"
		>
			refresh
		</a> and try again.
	</p>
{/if}
