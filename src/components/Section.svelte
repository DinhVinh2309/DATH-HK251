<script>
    export let title;
    /**
	 * @type {any[]}
	 */
     export let items = [];
    import Card from "./Card.svelte"
  </script>
  
  <section class="max-w-6xl mx-auto w-full">
    <div class="mb-4 flex items-baseline justify-between">
      <h2 class="text-xl font-semibold tracking-tight text-slate-900">{title}</h2>
    </div>
    <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5">
      {#each items as item}
        <Card {item} />
      {/each}
    </div>
  </section>
  