<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import Navbar from '../../components/NavBar.svelte';
  import Section from '../../components/Section.svelte';
  import LoginModal from '../../components/LoginModal.svelte';

  let showLoginModal = false;
  let isAuthenticated = false;
  const nullUser = { username: null, profilePic: null };
  let user = nullUser;
  let books = [];
  let loading = false;

  $: queryParam = $page.url.searchParams.get('q') || '';

  function toggleLoginModal() {
    showLoginModal = !showLoginModal;
  }

  function handleLoginSuccess(loggedinUser) {
    isAuthenticated = true;
    user = loggedinUser;
    showLoginModal = false;
    localStorage.setItem('user', JSON.stringify(loggedinUser));
  }

  function logout() {
    isAuthenticated = false;
    user = nullUser;
    localStorage.removeItem('user');
  }

  function openBook(bookId) {
    goto(`/info?bookId=${bookId}`);
  }

  async function performSearch(query) {
    if (!query.trim()) {
      books = [];
      return;
    }

    loading = true;
    try {
      const response = await fetch(`http://localhost:3000/searchBooks?q=${encodeURIComponent(query)}`);
      const data = await response.json();
      if (data.success) {
        books = data.books.map((book) => ({
          bookId: book.book_id,
          title: book.title,
          image: 'covers/' + book.cover_path,
          author: book.author,
          totalFavorites: book.total_favorites || 0
        }));
      } else {
        books = [];
      }
    } catch (error) {
      console.error('Failed to search books:', error);
      books = [];
    } finally {
      loading = false;
    }
  }

  onMount(async () => {
    try {
      const storedUser = typeof localStorage !== 'undefined' ? localStorage.getItem('user') : null;
      if (storedUser) {
        try {
          user = JSON.parse(storedUser);
          isAuthenticated = true;
        } catch (e) {
          // ignore parse errors
        }
      }

      // Perform initial search if query exists
      if (queryParam) {
        await performSearch(queryParam);
      }
    } catch (error) {
      console.error('Error:', error);
    }
  });

  // React to query parameter changes
  $: if (queryParam) {
    performSearch(queryParam);
  }
</script>

<Navbar
  isAuthenticated={isAuthenticated}
  user={user}
  onLogin={toggleLoginModal}
  onLogout={logout}
/>

<main class="bg-[#D3DDDE] pt-24 pb-16">
  <div class="mx-auto flex max-w-6xl flex-col gap-8 px-4 sm:px-6">
    <!-- Search Header -->
    <div class="space-y-4">
      <h1 class="text-2xl font-bold text-slate-900">Kết quả tìm kiếm</h1>

      {#if queryParam}
        <p class="text-sm text-slate-600">
          {#if loading}
            Đang tìm kiếm...
          {:else if books.length > 0}
            Tìm thấy <span class="font-semibold">{books.length}</span> kết quả cho "<span class="font-semibold">{queryParam}</span>"
          {:else}
            Không tìm thấy kết quả nào cho "<span class="font-semibold">{queryParam}</span>"
          {/if}
        </p>
      {/if}
    </div>

    <!-- Results -->
    {#if loading}
      <div class="flex items-center justify-center py-12">
        <div class="text-slate-500">Đang tìm kiếm...</div>
      </div>
    {:else if books.length > 0}
      <Section title="" items={books} />
    {:else if queryParam}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <p class="text-lg text-slate-600">Không tìm thấy sách nào</p>
        <p class="mt-2 text-sm text-slate-500">Thử tìm kiếm với từ khóa khác</p>
      </div>
    {:else}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <p class="text-lg text-slate-600">Nhập từ khóa để tìm kiếm sách</p>
      </div>
    {/if}
  </div>
</main>

{#if showLoginModal}
  <LoginModal
    on:loginSuccess={(e) => handleLoginSuccess(e.detail)}
    on:close={() => {
      showLoginModal = false;
    }}
  />
{/if}

