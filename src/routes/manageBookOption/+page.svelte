<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  let books = [];
  let filteredBooks = [];
  let currentPage = 1;
  let totalPages = 1;
  let deleteMode = false;
  let searchQuery = "";
  let sortOption = "title"; // Default sorting by book title

  async function fetchBooks() {
    try {
      const response = await fetch('http://localhost:3000/getAllbooks');
      const data = await response.json();

      if (data.success) {
        books = data.books;
        applyFiltersAndSorting(); // Initial sorting and filtering
      } else {
        console.error('Failed to fetch books');
      }
    } catch (error) {
      console.error('Error fetching books:', error);
    }
  }

  function updateTotalPages() {
    totalPages = Math.ceil(filteredBooks.length / 10); // Assuming 10 books per page
  }

  function applyFiltersAndSorting() {
    // Apply search
    const query = searchQuery.trim().toLowerCase();
    filteredBooks = books.filter(
      book =>
        book.title.toLowerCase().includes(query) ||
        String(book.book_id).toLowerCase().includes(query) ||
        book.author.toLowerCase().includes(query)
    );

    // Apply sorting
    filteredBooks.sort((a, b) => {
      if (sortOption === "title") {
        return a.title.localeCompare(b.title);
      } else if (sortOption === "author") {
        return a.author.localeCompare(b.author);
      } else if (sortOption === "book_id") {
        return parseInt(b.book_id.slice(1)) - parseInt(a.book_id.slice(1));
      }
    });

    currentPage = 1; // Reset to the first page
    updateTotalPages();
  }

  function goToPage(page) {
    if (page >= 1 && page <= totalPages) {
      currentPage = page;
    }
  }

  function editBook(bookId) {
    goto(`/editBook?bookId=${bookId}`);
  }

  function toggleDeleteMode() {
    deleteMode = !deleteMode;
  }

  async function deleteBook(bookId) {
    try {
      const response = await fetch(`http://localhost:3000/deleteBook?bookId=${bookId}`, {
        method: 'DELETE',
      });

      const data = await response.json();
      if (data.success) {
        // Remove the book locally only if the deletion is successful on the server
        books = books.filter(book => book.book_id !== bookId);
        applyFiltersAndSorting(); // Reapply sorting and filtering after deleting a book
      } else {
        console.error('Failed to delete book:', data.message);
      }
    } catch (error) {
      console.error('Error deleting book:', error);
    }
  }

  onMount(fetchBooks);
</script>

<div class="bg-blue-50 min-h-screen">
  <!-- Top Bar -->
  <header class="sticky top-0 z-10 bg-blue-600 text-white p-4 flex justify-between items-center shadow-md">
    <h1 class="text-xl font-bold">BKBOOKS</h1>
    <button class="bg-white text-blue-700 rounded py-2 px-4" on:click={() => goto("/" )}>Quay lại</button>
  </header>

  <div class="flex">
    <!-- Sidebar -->
    <nav class="sticky top-16 z-10 w-1/5 bg-blue-700 text-white h-[calc(100vh-4rem)] overflow-y-auto p-4">
      <ul class="space-y-4">
        <li><a href="#" class="block hover:bg-blue-600 p-2 rounded bg-blue-800">Quản Lý Sách</a></li>
        <li><a href="#" class="block hover:bg-blue-600 p-2 rounded">Quản Lý Tài Khoản</a></li>
        <li><a href="#" class="block hover:bg-blue-600 p-2 rounded">Thống kê lượt xem</a></li>
      </ul>
    </nav>

    <!-- Main Content -->
    <main class="w-4/5 bg-white rounded-md p-6 ml-4 mt-4">
      <h2 class="text-2xl font-bold text-gray-700">Tủ Sách Hiện Tại</h2>

      <!-- Search, Sort, and Buttons -->
      <div class="mt-4 flex flex-col md:flex-row items-center gap-4">
        <input
          type="text"
          placeholder="Tìm kiếm theo tên, id hoặc tác giả"
          class="border border-gray-300 rounded-md p-2 flex-1"
          bind:value={searchQuery}
          on:input={applyFiltersAndSorting}
        />
        <select
          bind:value={sortOption}
          on:change={applyFiltersAndSorting}
          class="border border-gray-300 rounded-md p-2">
          <option value="title">Sắp xếp theo Tên Sách</option>
          <option value="author">Sắp xếp theo Tác Giả</option>
          <option value="book_id">Sắp xếp theo ID Sách</option>
        </select>
        <button class="px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600" on:click={() => goto("/addBook")}>Thêm Sách</button>
        <button class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600" on:click={toggleDeleteMode}>
          {deleteMode ? 'Xong' : 'Xóa sách'}
        </button>
      </div>

      <!-- Book List -->
      <div class="grid grid-cols-4 gap-6 mt-6">
        {#each filteredBooks.slice((currentPage - 1) * 10, currentPage * 10) as book}
          <div 
            class="border rounded-md shadow-md p-4 text-center hover:shadow-lg transition cursor-pointer" 
            class:bg-red-100={deleteMode}
            on:click={() => deleteMode ? deleteBook(book.book_id) : editBook(book.book_id)}>
            <img src={"covers/" + book.cover_path} alt={book.title} class="w-full h-40 object-cover rounded-md" />
            <h3 class="mt-2 text-gray-700 font-semibold">{book.title}</h3>
            <p class="text-gray-500">ID: {book.book_id}</p>
            <p class="text-gray-500">Tác giả: {book.author}</p>
          </div>
        {/each}
      </div>

      <!-- Pagination -->
      <div class="mt-6 flex justify-center items-center gap-2">
        {#each Array(totalPages) as _, i}
          <button
            class="px-4 py-2 border rounded-md text-gray-700 hover:bg-gray-100"
            class:bg-blue-600={currentPage === i + 1}
            class:text-white={currentPage === i + 1}
            on:click={() => goToPage(i + 1)}
          >
            {i + 1}
          </button>
        {/each}
      </div>
    </main>
  </div>
</div>
