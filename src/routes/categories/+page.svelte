<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Navbar from '../../components/NavBar.svelte';
  import Section from '../../components/Section.svelte';
  import LoginModal from '../../components/LoginModal.svelte';

  let showLoginModal = false;
  let isAuthenticated = false;
  const nullUser = { username: null, profilePic: null };
  let user = nullUser;
  let categories = [];
  let categoryBooks = {};
  let loading = false;

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

  async function fetchCategoriesAndBooks() {
    try {
      loading = true;
      console.log('Starting to fetch categories and books...');
      
      // Fetch all categories
      const categoriesResponse = await fetch('http://localhost:3000/getCategories');
      console.log('Categories response status:', categoriesResponse.status);
      
      if (!categoriesResponse.ok) {
        console.error('Failed to fetch categories:', categoriesResponse.status, categoriesResponse.statusText);
        categories = [];
        loading = false;
        return;
      }
      
      const categoriesData = await categoriesResponse.json();
      console.log('Categories data:', categoriesData);
      
      if (!Array.isArray(categoriesData)) {
        console.error('Invalid categories response - not an array:', categoriesData);
        categories = [];
        loading = false;
        return;
      }
      
      if (categoriesData.length === 0) {
        console.warn('No categories found in database');
        categories = [];
        loading = false;
        return;
      }

      console.log(`Found ${categoriesData.length} categories`);

      // Fetch books for all categories in parallel
      const categoriesWithBooks = await Promise.all(
        categoriesData.map(async (cat) => {
          try {
            console.log(`Fetching books for category: ${cat.name} (${cat.category_id})`);
            const booksResponse = await fetch(`http://localhost:3000/getBooksByCategory?categoryId=${cat.category_id}`);
            
            if (!booksResponse.ok) {
              console.error(`Failed to fetch books for category ${cat.category_id}:`, booksResponse.status);
              categoryBooks[cat.category_id] = [];
              return { ...cat, book_count: 0 };
            }
            
            const booksData = await booksResponse.json();
            console.log(`Books response for ${cat.name}:`, booksData);
            
            if (booksData.success && Array.isArray(booksData.books)) {
              const books = booksData.books.map((book) => ({
                bookId: book.book_id,
                title: book.title,
                image: 'covers/' + book.cover_path,
                author: book.author,
                totalFavorites: book.total_favorites || 0
              }));
              
              console.log(`Category ${cat.name} has ${books.length} books:`, books);
              categoryBooks[cat.category_id] = books;
              return { ...cat, book_count: books.length };
            } else {
              console.warn(`Category ${cat.name} - no books or invalid response:`, booksData);
              categoryBooks[cat.category_id] = [];
              return { ...cat, book_count: 0 };
            }
          } catch (e) {
            console.error(`Error fetching books for category ${cat.category_id} (${cat.name}):`, e);
            categoryBooks[cat.category_id] = [];
            return { ...cat, book_count: 0 };
          }
        })
      );

      console.log('Categories with books:', categoriesWithBooks);

      // Filter out categories with no books
      categories = categoriesWithBooks.filter(cat => cat.book_count > 0);
      
      console.log('Final categories (with books):', categories.length);
      console.log('Category books object:', categoryBooks);
      console.log('Category IDs with books:', Object.keys(categoryBooks));
    } catch (error) {
      console.error('Failed to fetch categories and books:', error);
      categories = [];
    } finally {
      loading = false;
      console.log('Finished fetching, loading = false');
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

      await fetchCategoriesAndBooks();
    } catch (error) {
      console.error('Error in onMount:', error);
      loading = false;
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
  <div class="mx-auto flex max-w-6xl flex-col gap-8 px-4 sm:px-6">
    <!-- Header -->
    <div>
      <h1 class="text-3xl font-bold text-slate-900">Thể loại sách</h1>
      <p class="mt-2 text-sm text-slate-600">
        Khám phá sách theo từng thể loại
      </p>
    </div>

    {#if loading}
      <div class="flex items-center justify-center py-12">
        <div class="text-slate-500">Đang tải...</div>
      </div>
    {:else if categories.length === 0}
      <div class="flex flex-col items-center justify-center py-12 text-center">
        <p class="text-lg text-slate-600">Không có thể loại nào</p>
      </div>
    {:else}
      <!-- Categories List - Display all categories as Sections -->
      <div class="space-y-12">
        {#each categories as category}
          {@const books = categoryBooks[category.category_id]}
          {#if books && Array.isArray(books) && books.length > 0}
            <Section 
              title="{category.name} ({category.book_count} {category.book_count === 1 ? 'quyển' : 'quyển'})" 
              items={books} 
            />
          {:else}
            <div class="rounded-xl bg-white p-6 shadow-sm">
              <h2 class="text-lg font-semibold text-slate-900">{category.name}</h2>
              <p class="mt-2 text-sm text-slate-500">Debug: books = {books ? JSON.stringify(books) : 'null/undefined'}, book_count = {category.book_count}</p>
            </div>
          {/if}
        {/each}
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

