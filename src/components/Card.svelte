<script>
    import {goto} from "$app/navigation"
    export let item;
  </script>
  
  <div class="flex flex-col bg-white shadow rounded overflow-hidden cursor-pointer"
    on:click={()=>{goto("/info?bookId="+item.bookId)}}>
    <img src={item.image} alt={item.title} class="w-full object-cover mb-auto " />
    <div class="p-4">
      <h1 class="text-base font-bold text-2xl">{item.title}</h1>
      <p>{item.author}</p>
    </div>
  </div>
  