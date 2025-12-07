<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let books = [];
  let filteredBooks = [];
  let currentPage = 1;
  let totalPages = 1;
  let searchQuery = "";
  let sortOption = "title"; // Default sorting by book title
  let isLoading = false;

  async function fetchBooks(query = "") {
    try {
      isLoading = true;
      const trimmed = query.trim();
      const endpoint = trimmed
        ? `http://localhost:3000/searchBooks?q=${encodeURIComponent(trimmed)}`
        : 'http://localhost:3000/getAllBooks';

      const response = await fetch(endpoint);
      const data = await response.json();

      if (data.success) {
        books = data.books;
        applyFiltersAndSorting(); // Initial sorting and filtering
      } else {
        console.error('Failed to fetch books');
      }
    } catch (error) {
      console.error('Error fetching books:', error);
    } finally {
      isLoading = false;
    }
  }

  function updateTotalPages() {
    totalPages = Math.ceil(filteredBooks.length / 10); // Assuming 10 books per page
  }

  function applyFiltersAndSorting() {
    let working = [...books];

    // Apply client-side search as a safeguard (in case backend search is not used)
    const query = searchQuery.trim().toLowerCase();
    if (query) {
      working = working.filter(
        (book) =>
          book.title.toLowerCase().includes(query) ||
          String(book.book_id).toLowerCase().includes(query) ||
          book.author.toLowerCase().includes(query)
      );
    }

    // Apply sorting
    working.sort((a, b) => {
      if (sortOption === "title") {
        return a.title.localeCompare(b.title);
      } else if (sortOption === "author") {
        return a.author.localeCompare(b.author);
      } else if (sortOption === "book_id") {
        return parseInt(b.book_id.slice(1)) - parseInt(a.book_id.slice(1));
      }
    });

    filteredBooks = working;
    currentPage = 1; // Reset to the first page
    updateTotalPages();
  }

  async function handleSearchInput(event) {
    searchQuery = event.target.value;
    await fetchBooks(searchQuery);
  }

  function goToPage(page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
    }
  }

  function editBook(bookId) {
    goto(`/editBook?bookId=${bookId}`);
  }

  async function deleteBook(bookId) {
    // Find book title for confirmation message
    const book = books.find(b => b.book_id === bookId);
    const bookTitle = book ? book.title : bookId;
    
    // Show confirmation dialog
    if (!confirm(`Bạn có chắc chắn muốn xóa sách "${bookTitle}"?\n\nHành động này không thể hoàn tác.`)) {
      return;
    }

    try {
      const response = await fetch(`http://localhost:3000/deleteBook?bookId=${bookId}`, {
        method: 'DELETE',
      });

      const data = await response.json();
      if (data.success) {
        // Remove the book locally only if the deletion is successful on the server
        books = books.filter(book => book.book_id !== bookId);
        applyFiltersAndSorting(); // Reapply sorting and filtering after deleting a book
        alert(`Đã xóa sách "${bookTitle}" thành công.`);
      } else {
        const errorMsg = data.error || data.message || 'Không thể xóa sách';
        alert(`Lỗi: ${errorMsg}`);
        console.error('Failed to delete book:', errorMsg);
      }
    } catch (error) {
      const errorMessage = (error instanceof Error) ? error.message : 'Lỗi không xác định';
      alert(`Đã xảy ra lỗi khi xóa sách: ${errorMessage}`);
      console.error('Error deleting book:', error);
    }
  }

  onMount(fetchBooks);
</script>

<div class="min-h-screen bg-[#D3DDDE] text-[#233038]">
  <div class="flex min-h-screen">
    <!-- Sidebar -->
    <aside class="hidden w-64 flex-col bg-[#233038] text-slate-100 md:flex">
      <div class="flex items-center gap-2 px-6 py-5 border-b border-slate-700/60">
        <div class="flex h-9 w-9 items-center justify-center rounded-md bg-[#FF5B04] text-sm font-semibold">
          BK
        </div>
        <div>
          <p class="text-sm font-semibold">BKBOOKBOX Admin</p>
          <p class="text-xs text-slate-400">Trang quản lý</p>
        </div>
      </div>

      <nav class="mt-4 flex-1 space-y-1 px-3 text-sm">
        <button
          type="button"
          class="flex w-full items-center gap-3 rounded-xl bg-[#075056] px-3 py-2 font-medium text-slate-50"
        >
          <span>Quản lý sách</span>
        </button>
        <button
          type="button"
          class="flex w-full items-center gap-3 rounded-xl px-3 py-2 text-slate-200 hover:bg-slate-700/60"
          on:click={() => goto("/")}
        >
          <span>Quay lại trang đọc</span>
        </button>
      </nav>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 px-4 py-5 sm:px-6 lg:px-8">
      <!-- Top bar -->
      <header class="mb-5 flex flex-wrap items-center justify-between gap-3">
        <h1 class="text-lg font-semibold text-[#233038]">Trang quản lý</h1>
        <div class="flex items-center gap-3">
          <div class="relative">
            <span class="pointer-events-none absolute inset-y-0 left-3 flex items-center text-xs text-slate-400">
              🔍
            </span>
            <input
              type="search"
              placeholder="Tìm kiếm sách, tác giả..."
              class="w-60 rounded-full border border-[#D3DDDE] bg-white px-9 py-2 text-sm text-[#233038] placeholder:text-slate-400 focus:border-[#075056] focus:outline-none focus:ring-2 focus:ring-[#075056]/20"
              bind:value={searchQuery}
              on:input={handleSearchInput}
            />
          </div>
        </div>
      </header>

      <!-- Card: quản lý sách -->
      <section class="rounded-3xl bg-white p-6 shadow-sm">
        <div class="mb-4 flex flex-wrap items-center justify-between gap-4">
          <div>
            <h2 class="text-xl font-semibold text-[#233038]">Quản lý sách</h2>
            <p class="mt-1 text-sm text-slate-500">
              Thêm, sửa và xóa sách khỏi hệ thống.
            </p>
          </div>
          <button
            class="inline-flex items-center gap-2 rounded-full bg-[#FF5B04] px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-[#FBAB32]"
            on:click={() => goto("/addBook")}
          >
            <span>＋</span>
            <span>Thêm sách mới</span>
          </button>
        </div>

        <!-- Sort -->
        <div class="mb-4 flex flex-wrap items-center gap-3">
          <div class="ml-auto flex items-center gap-2 text-xs">
            <span class="text-slate-500">Sắp xếp theo:</span>
            <select
              bind:value={sortOption}
              on:change={applyFiltersAndSorting}
              class="rounded-full border border-[#D3DDDE] bg-white px-3 py-1 text-xs text-[#233038] focus:border-[#075056] focus:outline-none focus:ring-1 focus:ring-[#075056]/30"
            >
              <option value="title">Tên sách</option>
              <option value="author">Tác giả</option>
              <option value="book_id">ID sách</option>
            </select>
          </div>
        </div>

        <!-- Table header -->
        <div class="hidden items-center gap-4 border-b border-slate-100 pb-2 text-xs font-medium text-slate-500 md:grid md:grid-cols-[0.6fr_2fr_1.2fr_1.2fr_0.8fr_0.6fr]">
          <span>COVER</span>
          <span>TITLE</span>
          <span>AUTHOR</span>
          <span>CATEGORY</span>
          <span>STATUS</span>
          <span class="text-right">ACTIONS</span>
        </div>

        <!-- Book list -->
        {#if isLoading}
          <div class="py-10 text-center text-sm text-slate-500">
            Đang tải dữ liệu sách...
          </div>
        {:else}
          <div class="divide-y divide-slate-100">
            {#each filteredBooks.slice((currentPage - 1) * 10, currentPage * 10) as book}
              <div
                class="grid items-center gap-4 py-3 text-sm md:grid-cols-[0.6fr_2fr_1.2fr_1.2fr_0.8fr_0.6fr]"
              >
                <!-- Cover -->
                <div class="flex items-center">
                  <img
                    src={"covers/" + book.cover_path}
                    alt={book.title}
                    class="h-14 w-10 rounded-md object-cover ring-1 ring-slate-200"
                  />
                </div>

                <!-- Title -->
                <div class="space-y-1">
                  <p class="font-medium text-[#233038]">{book.title}</p>
                  <p class="text-xs text-slate-500">ID: {book.book_id}</p>
                </div>

                <!-- Author -->
                <p class="text-sm text-slate-600">{book.author}</p>

                <!-- Category -->
                <p class="text-sm text-slate-600">
                  {book.categories || '—'}
                </p>

                <!-- Status badge -->
                <div>
                  <span class="inline-flex items-center rounded-full bg-[#FBAB32]/15 px-3 py-1 text-xs font-semibold text-[#FBAB32]">
                    Published
                  </span>
                </div>

                <!-- Actions -->
                <div class="flex items-center justify-end gap-3 text-xs">
                  <button
                    class="rounded-full border border-[#D3DDDE] px-2 py-1 text-[#075056] hover:bg-[#D3DDDE]/40"
                    on:click={() => editBook(book.book_id)}
                  >
                    ✏️
                  </button>
                  <button
                    class="rounded-full border border-rose-200 px-2 py-1 text-rose-600 hover:bg-rose-50"
                    on:click={() => deleteBook(book.book_id)}
                  >
                    🗑
                  </button>
                </div>
              </div>
            {/each}
          </div>
        {/if}

        <!-- Pagination -->
        <div class="mt-4 flex justify-end gap-2 text-xs">
          {#each Array(totalPages) as _, i}
            <button
              class="h-7 w-7 rounded-full border border-[#D3DDDE] text-center text-[#233038] hover:bg-[#D3DDDE]/60"
              class:bg-[#075056]={currentPage === i + 1}
              class:text-white={currentPage === i + 1}
              on:click={() => goToPage(i + 1)}
            >
              {i + 1}
            </button>
          {/each}
        </div>
      </section>
    </main>
  </div>
</div>
