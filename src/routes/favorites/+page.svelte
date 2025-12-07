<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let username = '';
  let books = [];
  let currentPage = 1;
  let totalPages = 1;
  let userId = '';
  let loading = false;

  // Fetch user favorites
  async function fetchFavorites() {
    let user = JSON.parse(localStorage.getItem('user'));
    if (!user) {
      books = [];
      return;
    }

    userId = user.userId;
    username = user.username || '';
    
    if (!userId) {
      books = [];
      return;
    }

    try {
      loading = true;
      const response = await fetch(`http://localhost:3000/getUserFavorites?userId=${userId}`);
      const result = await response.json();
      
      if (result.success) {
        books = result.books.map(item => ({
          id: item.book_id,
          title: item.title,
          author: item.author || '',
          cover: `covers/${item.cover_path}` || "/path/to/default-cover.jpg",
        }));
        totalPages = Math.ceil(books.length / 12); // Assuming 12 books per page
      } else {
        console.error("Failed to fetch favorites:", result.error);
        books = [];
      }
    } catch (error) {
      console.error("Error fetching favorites:", error);
      books = [];
    } finally {
      loading = false;
    }
  }

  // Handle pagination
  function goToPage(page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
    }
  }

  // Go back to the previous page
  function goBack() {
    goto("/");
  }

  // Fetch favorites on component mount
  onMount(fetchFavorites);
</script>

<div class="min-h-screen bg-slate-100 pt-24 pb-16">
  <div class="mx-auto flex max-w-6xl gap-8 px-4 sm:px-6">
    <!-- Sidebar navigation -->
    <aside
      class="hidden w-60 shrink-0 rounded-3xl bg-white p-5 text-sm text-slate-700 shadow-sm md:block"
    >
      <div class="mb-6">
        <p class="text-xs text-center font-semibold uppercase tracking-[0.16em] text-slate-400">Menu</p>
      </div>
      <nav class="space-y-1">
        <button
          type="button"
          class="flex w-full items-center justify-between rounded-xl bg-teal-50 px-3 py-2 text-left font-medium text-teal-700"
        >
          <span>Sách yêu thích</span>
        </button>
        <button
          type="button"
          class="flex w-full items-center justify-between rounded-xl px-3 py-2 text-left text-slate-600 hover:bg-slate-50"
          on:click={() => goto('/history')}
        >
          <span>Lịch sử đọc</span>
        </button>
      </nav>

      <div class="mt-8 rounded-2xl bg-slate-50 px-3 py-3 text-xs text-slate-500">
        <p class="font-medium text-slate-700">Xin chào, {username}</p>
        <p class="mt-1">Những cuốn sách bạn đã yêu thích và đánh dấu.</p>
      </div>
    </aside>

    <!-- Main content -->
    <section class="flex-1">
      <header class="mb-5 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-xl font-semibold text-slate-900">Sách yêu thích</h1>
          <p class="mt-1 text-sm text-slate-500">
            Những cuốn sách bạn đã yêu thích trên hệ thống.
          </p>
        </div>
        <button
          class="rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
          on:click={goBack}
        >
          Quay lại trang chủ
        </button>
      </header>

      <div class="rounded-3xl bg-white p-5 shadow-sm">
        {#if loading}
          <div class="flex items-center justify-center py-12">
            <div class="text-slate-500">Đang tải...</div>
          </div>
        {:else if books.length === 0}
          <div class="flex flex-col items-center justify-center py-12 text-center">
            <p class="text-lg text-slate-600">Chưa có sách yêu thích nào</p>
            <p class="mt-2 text-sm text-slate-500">Hãy thêm sách vào danh sách yêu thích của bạn</p>
            <button
              type="button"
              class="mt-4 rounded-full bg-orange-500 px-6 py-2 text-sm font-semibold text-white hover:bg-orange-600"
              on:click={() => goto('/')}
            >
              Khám phá sách
            </button>
          </div>
        {:else}
          <div class="mb-4 flex flex-wrap items-center justify-between gap-3">
            <div class="text-sm text-slate-600">
              Người dùng:{' '}
              <span class="font-semibold text-slate-900">{username}</span>
            </div>
          </div>

          <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
            {#each books.slice((currentPage - 1) * 12, currentPage * 12) as book}
              <div
                class="flex cursor-pointer flex-col overflow-hidden rounded-2xl border border-slate-100 bg-slate-50/60 p-3 shadow-sm transition hover:-translate-y-1 hover:shadow-md"
                role="button"
                tabindex="0"
                on:click={() => goto(`/info?bookId=${book.id}`)}
                on:keydown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    goto(`/info?bookId=${book.id}`);
                  }
                }}
              >
                <div class="overflow-hidden rounded-xl bg-slate-100">
                  <img
                    src={book.cover}
                    alt={book.title}
                    class="h-40 w-full object-cover"
                  />
                </div>
                <div class="mt-3 flex flex-1 flex-col text-sm">
                  <h3 class="line-clamp-2 font-semibold text-slate-900">{book.title}</h3>
                  {#if book.author}
                    <p class="mt-1 text-xs text-slate-500">{book.author}</p>
                  {/if}
                </div>
              </div>
            {/each}
          </div>

          <!-- Pagination -->
          {#if totalPages > 1}
            <div class="mt-6 flex justify-center gap-2">
              {#each Array(totalPages) as _, i}
                <button
                  class="px-3 py-1 text-xs font-medium rounded-full border border-slate-200 text-slate-700 hover:bg-slate-50"
                  class:bg-teal-600={currentPage === i + 1}
                  class:text-white={currentPage === i + 1}
                  on:click={() => goToPage(i + 1)}
                >
                  {i + 1}
                </button>
              {/each}
            </div>
          {/if}
        {/if}
      </div>
    </section>
  </div>
</div>

