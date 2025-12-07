<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  export let user = null; // passed from the parent

  let username = user ? user.username : '';
  let usernameError = '';
  let successMessage = '';
  let userId = '';
  let booksRead = 0;
  let favoritesCount = 0;
  let loading = false;

  // Fetch user statistics
  async function fetchUserStats() {
    const storedUser = localStorage.getItem('user');
    if (!storedUser) {
      console.log('No user found in localStorage');
      return;
    }

    try {
      const userData = JSON.parse(storedUser);
      userId = userData.userId || userData.user_id;
      
      if (!userId) {
        console.error('No userId found in user data:', userData);
        return;
      }

      console.log('Fetching user stats for userId:', userId);
      loading = true;
      
      const response = await fetch(`http://localhost:3000/getUserStats?userId=${userId}`);
      
      if (!response.ok) {
        console.error('Failed to fetch user stats:', response.status, response.statusText);
        return;
      }
      
      const data = await response.json();
      console.log('User stats data:', data);

      if (data.success && data.stats) {
        booksRead = data.stats.booksRead || 0;
        favoritesCount = data.stats.favoritesCount || 0;
        console.log(`Books read: ${booksRead}, Favorites: ${favoritesCount}`);
      } else {
        console.error('Invalid response format:', data);
      }
    } catch (error) {
      console.error('Failed to fetch user stats:', error);
    } finally {
      loading = false;
    }
  }

  // Function to handle username change with API call
  async function handleUsernameChange() {
      if (username.length < 3) {
          usernameError = 'Username must be at least 3 characters long';
          return;
      }

      usernameError = '';
      successMessage = '';

      try {
          const response = await fetch(`http://localhost:3000/updateUsername?userId=${user.userId}&newName=${username}`);

          if (!response.ok) {
              const errorData = await response.json();
              usernameError = errorData.message || 'Đã xảy ra lỗi khi cập nhật tên hiển thị. Vui lòng thử lại.';
              return;
          }

          const data = await response.json();
          successMessage = 'Cập nhật thành công!';
          // Update the user locally
          user.username = username;
          localStorage.setItem("user", JSON.stringify(user))

          // Optionally update localStorage
          localStorage.setItem('user', JSON.stringify(user));
      } catch (error) {
          usernameError = 'Đã xảy ra lỗi khi cập nhật tên hiển thị. Vui lòng thử lại.';
      }
  }

  onMount(async () => {
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
          user = JSON.parse(storedUser);
          username = user.username;
          userId = user.userId;
      }
      await fetchUserStats();
  });
</script>

<div class="min-h-screen bg-slate-100 pt-24 pb-16">
  <div class="mx-auto flex max-w-6xl flex-col gap-8 px-4 sm:px-6 md:flex-row">
    <!-- Sidebar -->
    <aside
      class="w-full rounded-3xl bg-white p-6 shadow-sm md:w-72 md:shrink-0 md:self-start md:sticky md:top-24"
    >
      <div class="flex flex-col items-center text-center">
        <div class="relative mb-4">
          <img
            src="defaultProfilePic.png"
            alt="Ảnh đại diện"
            class="h-24 w-24 rounded-full object-cover shadow"
          />
        </div>
        <h2 class="text-lg font-semibold text-slate-900">{username || 'Người dùng'}</h2>
        <p class="mt-1 text-xs text-slate-500">@{user?.userId}</p>
      </div>

      <div class="mt-6 grid grid-cols-2 gap-3 text-center text-xs">
        <div class="rounded-2xl bg-slate-50 px-3 py-2">
          {#if loading}
            <p class="font-semibold text-slate-900">...</p>
          {:else}
            <p class="font-semibold text-slate-900">{booksRead}</p>
          {/if}
          <p class="text-slate-500">Sách đã đọc</p>
        </div>
        <div class="rounded-2xl bg-slate-50 px-3 py-2">
          {#if loading}
            <p class="font-semibold text-slate-900">...</p>
          {:else}
            <p class="font-semibold text-slate-900">{favoritesCount}</p>
          {/if}
          <p class="text-slate-500">Yêu thích</p>
        </div>
      </div>

      <button
        class="mt-6 w-full rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
        on:click={() => goto('/')}
      >
        Quay lại trang chủ
      </button>
    </aside>

    <!-- Main content -->
    <section class="flex-1 space-y-6">
      <header>
        <h1 class="text-xl font-semibold text-slate-900">Thông tin cá nhân</h1>
        <p class="mt-1 text-sm text-slate-500">
          Quản lý thông tin tài khoản và cập nhật tên hiển thị của bạn trong ứng dụng.
        </p>
      </header>

      {#if successMessage}
        <div class="rounded-2xl border border-emerald-100 bg-emerald-50 px-4 py-3 text-sm text-emerald-800">
          {successMessage}
        </div>
      {/if}

      <div class="rounded-3xl bg-white p-6 shadow-sm">
        <div class="mb-6 flex items-center justify-between gap-4">
          <div>
            <h2 class="text-base font-semibold text-slate-900">Tên tài khoản</h2>
            <p class="mt-1 text-xs text-slate-500">
              Tên này sẽ hiển thị trong toàn bộ hệ thống.
            </p>
          </div>
        </div>

        <div class="space-y-3">
          <div>
            <label for="username" class="block text-xs font-medium text-slate-700">
              Tên hiển thị
            </label>
            <input
              type="text"
              id="username"
              bind:value={username}
              class="mt-1 w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm focus:border-teal-500 focus:outline-none focus:ring-2 focus:ring-teal-100"
            />
            {#if usernameError}
              <p class="mt-1 text-xs text-rose-600">{usernameError}</p>
            {/if}
          </div>

          <div class="flex justify-end gap-3 pt-2">
            <button
              type="button"
              class="rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50"
              on:click={() => goto('/')}
            >
              Hủy
            </button>
            <button
              on:click={handleUsernameChange}
              class="rounded-full bg-orange-500 px-5 py-2 text-sm font-semibold text-white shadow-sm hover:bg-orange-600"
            >
              Lưu thay đổi
            </button>
          </div>
        </div>
      </div>
    </section>
  </div>
</div>
