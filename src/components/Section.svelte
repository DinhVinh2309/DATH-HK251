<script>
    export let title;
    /**
	 * @type {any[]}
	 */
     export let items = [];
    import Card from "./Card.svelte"
  </script>
  
  <section class="px-8 mb-8 max-w-full">
    <h2 class="text-lg font-bold text-blue-700 mb-4">{title}</h2>
    <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-4 gap-4">
      {#each items as item}
        <Card {item} />
      {/each}
    </div>
  </section>
  