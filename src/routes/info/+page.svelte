<script>
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';

  let book = null;
  let bookId = null;
  let userId = 'U0000001'; // Static userId for demonstration
  let isLiked = false;
  let isFollowing = false;
  let showModal = false; // Modal state

  // Dynamically extract the `bookId` from the URL query params
  $: bookId = $page.url.searchParams.get('bookId');

  // Fetch book details from the endpoint
  async function fetchBookDetails() {
    let user = JSON.parse(localStorage.getItem('user'));
    userId = user.userId;
    if (!bookId) return;

    try {
      const response = await fetch(`http://localhost:3000/getBookDetails?bookId=${bookId}&userId=${userId}`);
      const data = await response.json();

      if (data.success) {
        book = data.book;
        isLiked = book.isFavorite === 1; // Map API response to `isLiked`
        isFollowing = book.totalFollowers > 0; // Map follow status
      } else {
        console.error('Failed to fetch book details:', data.message);
      }
    } catch (error) {
      console.error('Error fetching book details:', error);
    }
  }

  async function updateReadHistory() {
    if (!bookId || !userId) return;

    try {
      const response = await fetch(`http://localhost:3000/updateReadHistory?bookId=${bookId}&userId=${userId}&lastReadPage=${Math.floor(Math.random() * 100)}`, {
        method: 'POST',
      });
      const data = await response.json();

      if (!data.success) {
        console.error('Failed to update read history:', data.message);
      }
    } catch (error) {
      console.error('Error updating read history:', error);
    }
  }

  function toggleLike() {
    isLiked = !isLiked;
    // Handle API request for updating like status
  }

  function toggleFollow() {
    isFollowing = !isFollowing;
    // Handle API request for updating follow status
  }

  async function openReaderModal() {
    await updateReadHistory(); // Call the updateReadHistory endpoint
    showModal = true; // Open the modal
  }

  function closeReaderModal() {
    showModal = false;
  }

  // Fetch book details when the component mounts
  onMount(fetchBookDetails);
</script>

{#if book}
<div class="bg-blue-50 min-h-screen p-4">
  <div class="max-w-4xl mx-auto bg-white rounded-lg shadow-md p-6 mt-20">
    <header class="flex justify-between items-center mb-4">
      <h1 class="text-2xl font-bold text-blue-600">{book.title}</h1>
      <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600" on:click={() => goto('/')}>Quay Lại</button>
    </header>

    <div class="flex gap-4">
      <!-- Cover Image -->
      <img src={"covers/" + book.coverPath} class="w-32 h-40 rounded-md" alt="Book Cover" />

      <!-- Book Details -->
      <div class="flex-1">
        <p class="text-gray-600">Tác giả: <span class="font-semibold">{book.author}</span></p>
        <div class="mt-3">
          <p class="text-gray-600">Lượt thích: <span class="font-semibold">{book.totalFavorites || 0}</span></p>
          <p class="text-gray-600">Người đọc: <span class="font-semibold">{book.totalReaders || 0}</span></p>
          <p class="text-gray-600">Lượt theo dõi: <span class="font-semibold">{book.totalFollowers}</span></p>
        </div>

        <div class="mt-4 flex flex-wrap gap-2">
          {#each book.categories as category}
            <span class="px-3 py-1 bg-blue-100 text-blue-600 rounded-full text-sm">{category}</span>
          {/each}
        </div>

        <div class="mt-6 flex gap-4">
          <button
            class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
            on:click={openReaderModal}
          >
            Bắt Đầu Đọc
          </button>
          <button
            class="px-4 py-2 border rounded text-gray-700 hover:bg-gray-100"
            class:is-liked={isLiked}
            on:click={toggleLike}
          >
            {isLiked ? 'Đã Thích' : 'Thích'}
          </button>
          <button
            class="px-4 py-2 border rounded text-gray-700 hover:bg-gray-100"
            class:is-following={isFollowing}
            on:click={toggleFollow}
          >
            {isFollowing ? 'Đang Theo Dõi' : 'Theo Dõi'}
          </button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Modal -->
{#if showModal}
<div class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center">
  <div class="bg-white rounded-lg shadow-lg p-6 max-w-3xl w-full">
    <header class="flex justify-between items-center mb-4">
      <h2 class="text-xl font-semibold">Nội dung của {book.title}</h2>
      <button class="text-gray-500 hover:text-gray-700" on:click={closeReaderModal}>
        &times;
      </button>
    </header>
    <div class="overflow-y-auto max-h-96">
      <p class="text-gray-700 leading-relaxed">
        Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer nec odio. Praesent libero. Sed cursus ante dapibus diam. Sed nisi. Nulla quis sem at nibh elementum imperdiet. Duis sagittis ipsum. Praesent mauris. Fusce nec tellus sed augue semper porta. Mauris massa. Vestibulum lacinia arcu eget nulla. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
      </p>
    </div>
  </div>
</div>
{/if}
{:else}
<div class="flex items-center justify-center min-h-screen">
  <p class="text-gray-500">Đang tải...</p>
</div>
{/if}

<style>
  /* Add custom styles if needed */
  .modal-content {
    max-height: 80vh;
    overflow-y: auto;
  }
</style>
