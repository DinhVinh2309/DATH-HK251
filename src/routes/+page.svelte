<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Navbar from '../components/NavBar.svelte';
  import Section from '../components/Section.svelte';
  import LoginModal from '../components/LoginModal.svelte';

  let showLoginModal = false;
  let isAuthenticated = false;
  const nullUser = { username: null, profilePic: null };
  let user = nullUser;
  let books = [];

  // derived data for sections
  $: featuredBook = books[0];
  $: highlightedBooks = [...books]
    .sort((a, b) => (b.totalFavorites || 0) - (a.totalFavorites || 0))
    .slice(0, 5);
  $: latestBooks = [...books]
    .slice()
    .sort((a, b) => parseInt(b.bookId.slice(1)) - parseInt(a.bookId.slice(1)))
    .slice(0, 5);

  function toggleLoginModal() {
    showLoginModal = !showLoginModal;
  }

  /**
   * Handle successful login by storing user info and updating state
   * @param {any} loggedinUser
   */
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

  // Fetch books from API
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

      const response = await fetch('http://localhost:3000/getAllBooks');
      const data = await response.json();
      if (data.success) {
        books = data.books.map((book) => ({
          bookId: book.book_id,
          title: book.title,
          image: 'covers/' + book.cover_path,
          author: book.author,
          totalFavorites: book.total_favorites || 0
        }));
      }
    } catch (error) {
      console.error('Failed to fetch books:', error);
    }
  });
</script>

<Navbar
  isAuthenticated={isAuthenticated}
  user={user}
  onLogin={toggleLoginModal}
  onLogout={logout}
/>

<main class="bg-[#D3DDDE] pt-24 pb-16">
  <div class="mx-auto flex max-w-6xl flex-col gap-12 px-4 sm:px-6">
    {#if featuredBook}
      <!-- Hero: sách mới -->
      <section
        class="grid gap-8 rounded-3xl bg-white/40 p-6 shadow-xl md:grid-cols-[minmax(0,2fr)_minmax(0,3fr)] md:p-10"
      >
        <!-- Cover -->
        <div
          class="flex items-center justify-center rounded-2xl bg-[#FBAB32]/40 p-4 shadow-lg backdrop-blur-sm"
        >
          <div
            class="overflow-hidden rounded-2xl bg-slate-900/80 shadow-2xl ring-4 ring-white/10"
          >
            <img
              src={latestBooks[0].image}
              alt={latestBooks[0].title}
              class="h-72 w-48 object-cover sm:h-80 sm:w-56"
            />
          </div>
        </div>

        <!-- Text content -->
        <div class="flex flex-col justify-normal">
          <div class="space-y-3 py-4 pt-20">
            <p class="text-xs font-extrabold uppercase tracking-[0.2em] text-[#FF5B04]">
              Sách mới nhất
            </p>
            <h1 class="text-2xl font-extrabold leading-snug text-[#233038] sm:text-3xl lg:text-4xl">
              {latestBooks[0].title}
            </h1>
            <p class="text-sm font-medium text-[#233038]">
              {latestBooks[0].author}
            </p>
            <p class="max-w-xl text-sm text-[#233038]">
              Khám phá cuốn sách mới nhất, nơi mở ra những góc nhìn sâu sắc và đầy cảm hứng dành cho mọi độc giả yêu tri thức.
            </p>
          </div>

          <button
            type="button"
            class="w-36 rounded-full bg-orange-500 px-5 py-2 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600"
            on:click={() => openBook(latestBooks[0].bookId)}
          >
            Đọc ngay
          </button>

          <!-- <div class="mt-6 flex flex-wrap items-center gap-3">
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-full bg-orange-500 px-5 py-2 text-sm font-semibold text-white shadow-md transition hover:bg-orange-600"
              on:click={() => openBook(featuredBook.bookId)}
            >
              Đọc ngay
            </button>
            <button
              type="button"
              class="inline-flex items-center justify-center rounded-full border border-teal-100/70 bg-white/10 px-4 py-2 text-sm font-medium text-white backdrop-blur-sm transition hover:bg-white/15"
            >
              Thêm vào danh sách đọc
            </button>
          </div> -->
        </div>
      </section>
    {/if}

    <!-- Sections -->
    <Section title="Mới cập nhật" items={latestBooks} />
    <Section title="Sách nổi bật" items={highlightedBooks} />
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
