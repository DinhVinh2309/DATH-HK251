<script>
    export let isAuthenticated = false;
    export let user = {"username":null, "profilePic":null};
    export let onLogin;
    export let onLogout;
  
    import { goto } from '$app/navigation'; // For SvelteKit navigation
    import { onMount } from 'svelte';

  
    let showDropdown = false;
    function navigateToProfile() {
      goto('/profile');
    }
  
    function navigateToHistory() {
      goto('/history');
    }
    onMount(() => {
      user = JSON.parse(localStorage.getItem("user"));
    })
  </script>
  
  <nav class="bg-blue-600 text-white fixed top-0 w-full z-10 shadow-md">
    <div class="container mx-auto flex justify-between items-center py-4 px-6">
      <div class="text-xl font-bold">BKBOOKS</div>
      <ul class="flex space-x-6">
        <li><a href="#" class="hover:underline">Trang chủ</a></li>
        <li><a href="#" class="hover:underline">Xếp hạng</a></li>
        <li><a href="#" class="hover:underline">Thể loại</a></li>
      </ul>
      {#if isAuthenticated}
        <!-- User profile dropdown -->
        <div class="relative">
          <div class="flex gap-4 py-auto">
            <h1 class="my-auto">{user.isAdmin ? "Admin -"  : ""} {user.username}</h1>
            <img
              src="defaultProfilePic.png"
              alt="Profile Picture"
              class="w-10 h-10 rounded-full cursor-pointer"
              on:click={() => (showDropdown = !showDropdown)}
            />
          </div>
          {#if showDropdown}
            <div class="absolute right-0 bg-white text-black rounded shadow-lg w-48 rounded-md">
              <button class="block w-full text-left px-4 py-2 hover:bg-gray-100 rounded-md" on:click={navigateToProfile}>
                Thông tin cá nhân
              </button>
              <button class="block w-full text-left px-4 py-2 hover:bg-gray-100" on:click={navigateToHistory}>
                Lịch sử xem
              </button>
              {#if user.isAdmin}
              <button class="block w-full text-left px-4 py-2 hover:bg-gray-100" on:click={()=>goto("/manageBookOption")}>
                Quản lý
              </button>
              {/if}
              <button class="block w-full text-left px-4 py-2 text-red-500 hover:bg-gray-100 rounded-md" on:click={onLogout}>
                Đăng xuất
              </button>
            </div>
          {/if}
        </div>
      {:else}
        <!-- Login and register buttons -->
        <div class="space-x-4">
          <button class="bg-blue-700 px-4 py-2 rounded text-white" on:click={onLogin}>
            Đăng nhập
          </button>
          <button class="bg-blue-800 px-4 py-2 rounded text-white">Đăng kí</button>
        </div>
      {/if}
    </div>
  </nav>
  