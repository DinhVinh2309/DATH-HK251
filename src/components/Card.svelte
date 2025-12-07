<script>
  import {goto} from "$app/navigation"
  export let item;
</script>
  
<div
  role="button"
  tabindex="0"
  class="group flex cursor-pointer flex-col overflow-hidden rounded-2xl border border-slate-100 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-xl"
  on:click={() => {goto("/info?bookId=" + item.bookId);}}
  on:keydown={(e) => {
    if (e.key === "Enter" || e.key === " ") {
      e.preventDefault();
      goto("/info?bookId=" + item.bookId);
    }
  }}>
  <div class="relative overflow-hidden bg-slate-100">
    <img
      src={item.image}
      alt={item.title}
      class="h-56 w-full object-cover transition duration-300 group-hover:scale-105"
    />
  </div>
  <div class="flex flex-1 flex-col gap-1 p-4">
    <h1 class="line-clamp-2 text-sm font-semibold text-slate-900">{item.title}</h1>
    <p class="text-xs font-medium text-slate-500">{item.author}</p>
  </div>
</div>
  