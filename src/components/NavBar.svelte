<script>
  export let isAuthenticated = false;
  // include isAdmin to avoid undefined access in template
  export let user = { username: null, profilePic: null, isAdmin: false };
  export let onLogin;
  export let onLogout;

  import { goto } from '$app/navigation';
  import { onMount } from 'svelte';
  import { page } from '$app/stores';
  // Import icons từ lucide-svelte
  import { Search, BookOpen, Star, MessageCircle, User, LogOut, LogIn, UserPlus, Settings, History, X } from 'lucide-svelte';

  let showDropdown = false;
  let searchQuery = '';
  let previousQueryParam = '';
  let isClearing = false;

  // Sync search query with URL when on search page, only when URL actually changes
  $: {
    if (!isClearing && $page.url.pathname === '/search') {
      const queryParam = $page.url.searchParams.get('q') || '';
      // Only sync if the URL query param has changed (not if user is typing)
      if (queryParam !== previousQueryParam) {
        searchQuery = queryParam;
        previousQueryParam = queryParam;
      }
    } else if ($page.url.pathname !== '/search') {
      // Reset when not on search page
      previousQueryParam = '';
      isClearing = false;
    }
  }

  function navigateToProfile() {
    goto('/profile');
    showDropdown = false;
  }

  function navigateToHistory() {
    goto('/history');
    showDropdown = false;
  }

  function handleSearch(e) {
    if (e.key === 'Enter' || e.type === 'click') {
      const query = searchQuery.trim();
      if (query) {
        goto(`/search?q=${encodeURIComponent(query)}`);
      }
    }
  }

  function clearSearch(e) {
    if (e) {
      e.preventDefault();
      e.stopPropagation();
    }
    isClearing = true;
    searchQuery = '';
    previousQueryParam = '';
    // If on search page, redirect to home
    if ($page.url.pathname === '/search') {
      goto('/');
    }
    // Reset flag after a short delay to allow redirect
    setTimeout(() => {
      isClearing = false;
    }, 100);
  }

  onMount(() => {
    const stored = typeof localStorage !== 'undefined' ? localStorage.getItem('user') : null;
    if (stored) {
      try {
        user = JSON.parse(stored);
      } catch (e) {
        // ignore parse errors
      }
    }
  });
</script>

<nav class="fixed inset-x-0 top-0 z-20 bg-[#D3DDDE] border-b border-solid border-b-gray-400/30 backdrop-blur">
  <div class="mx-auto flex max-w-6xl items-center gap-4 px-4 py-3 sm:px-6">
    <!-- Logo + brand -->
    <button
      type="button"
      class="flex items-center gap-3"
      on:click={() => goto('/')}
    >
      <BookOpen
        class="flex h-9 w-9 items-center justify-center rounded-md text-sm font-semibold text-slate-900"
        size={16}
      />
      <div class="flex flex-col text-left">
        <span class="text-sm font-semibold tracking-tight text-slate-900 sm:text-base">
          BKBookBox
        </span>
        <span class="hidden text-xs text-slate-500 sm:block">
          Thư viện sách trực tuyến
        </span>
      </div>
    </button>

    <!-- Search -->
    <div class="hidden flex-1 md:block">
      <div class="relative">
        <Search
          class="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400"
          size={16}
        />
        <input
          type="text"
          placeholder="Tìm kiếm sách, tác giả..."
          class="w-full rounded-full border border-slate-200 bg-white px-10 py-2 text-sm text-slate-700 placeholder:text-slate-400 shadow-sm focus:border-teal-500 focus:outline-none focus:ring-2 focus:ring-teal-100"
          bind:value={searchQuery}
          on:keydown={handleSearch}
        />
        {#if searchQuery}
          <button
            type="button"
            class="absolute right-10 top-1/2 z-10 -translate-y-1/2 rounded-full p-1 text-slate-400 hover:bg-slate-100 hover:text-slate-600"
            on:click={clearSearch}
            title="Xóa"
          >
            <X size={16} />
          </button>
        {/if}
        <button
          type="button"
          class="absolute right-3 top-1/2 z-10 -translate-y-1/2 rounded-full p-1 text-teal-600 hover:bg-teal-50 hover:text-teal-700"
          on:click={handleSearch}
          title="Tìm kiếm"
        >
          <Search size={16} />
        </button>
      </div>
    </div>

    <!-- Nav links -->
    <div class="hidden items-center gap-6 text-sm font-medium text-slate-600 lg:flex">
      <button 
        type="button" 
        class="transition-colors hover:text-slate-900"
        on:click={() => goto('/categories')}
      >
        Thể loại
      </button>
      <button type="button" class="transition-colors hover:text-slate-900">
        Xếp hạng
      </button>
      <button type="button" class="transition-colors hover:text-slate-900">
        Thông tin
      </button>
    </div>

    <!-- Auth -->
    {#if isAuthenticated}
      <div class="relative ml-auto">
        <button
          type="button"
          class="flex items-center gap-3 rounded-full border border-slate-200 bg-white px-2 py-1 shadow-sm transition hover:border-teal-400 hover:shadow-md"
          on:click={() => (showDropdown = !showDropdown)}
        >
          <div class="flex flex-col text-right text-xs leading-tight">
            <span class="font-medium text-slate-700">
              {user.isAdmin ? 'Admin' : 'Người dùng'}
            </span>
            <span class="text-slate-500">{user.username}</span>
          </div>
          <img
            src="defaultProfilePic.png"
            alt="Ảnh đại diện"
            class="h-9 w-9 rounded-full object-cover"
          />
        </button>

        {#if showDropdown}
          <div
            class="absolute right-0 mt-2 w-52 rounded-xl border border-slate-200 bg-white py-2 text-sm text-slate-700 shadow-lg"
          >
            <button
              class="block w-full px-4 py-2 text-left hover:bg-slate-50"
              on:click={navigateToProfile}
            >
              Thông tin cá nhân
            </button>
            <button
              class="block w-full px-4 py-2 text-left hover:bg-slate-50"
              on:click={navigateToHistory}
            >
              Thư viện
            </button>
            {#if user.isAdmin}
              <button
                class="block w-full px-4 py-2 text-left hover:bg-slate-50"
                on:click={() => {
                  showDropdown = false;
                  goto('/manageBookOption');
                }}
              >
                Khu vực quản lý
              </button>
            {/if}
            <div class="my-1 border-t border-slate-100"></div>
            <button
              class="block w-full px-4 py-2 text-left font-medium text-rose-600 hover:bg-rose-50"
              on:click={() => {
                showDropdown = false;
                onLogout();
              }}
            >
              Đăng xuất
            </button>
          </div>
        {/if}
      </div>
    {:else}
      <div class="ml-auto flex items-center gap-3">
        <button
          type="button"
          class="inline-flex rounded-full bg-orange-500 px-4 py-1.5 text-sm font-semibold text-white shadow-sm transition hover:bg-orange-600"
          on:click={onLogin}
        >
          Đăng nhập
        </button>
        <button
          type="button"
          class="inline-flex rounded-full bg-white px-4 py-1.5 text-sm font-semibold text-slate-700 shadow-sm transition hover:bg-slate-50"
          on:click={() => goto('/register')}
        >
          Đăng ký
        </button>
      </div>
    {/if}
  </div>
</nav>
