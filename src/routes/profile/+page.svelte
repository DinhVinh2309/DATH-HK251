<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';

  export let user = null; // passed from the parent

  let username = user ? user.username : '';
  let usernameError = '';
  let successMessage = '';
  let userId = '';

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
              usernameError = errorData.message || 'Failed to update username';
              return;
          }

          const data = await response.json();
          successMessage = 'Username updated successfully!';
          // Update the user locally
          user.username = username;
          localStorage.setItem("user", JSON.stringify(user))

          // Optionally update localStorage
          localStorage.setItem('user', JSON.stringify(user));
      } catch (error) {
          usernameError = 'An error occurred while updating the username. Please try again.';
      }
  }

  onMount(() => {
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
          user = JSON.parse(storedUser);
          username = user.username;
      }
  });
</script>

<div class="max-w-fit mx-auto p-6">
  <h2 class="text-2xl font-semibold mb-4">Thông tin cá nhân</h2>

  {#if successMessage}
      <div class="bg-green-100 text-green-700 p-4 rounded mb-4">
          {successMessage}
      </div>
  {/if}

  <div class="bg-white shadow-md p-6 rounded-lg mb-6">
      <div class="flex gap-24">
        <h3 class="text-xl font-semibold mb-4">Thay đổi tên tài khoản</h3>
        <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600" on:click={() => goto('/')}>Quay Lại</button>
      </div>
      <div class="mb-4">
          <label for="username" class="block text-sm">Tên tài khoản:</label>
          <input
              type="text"
              id="username"
              bind:value={username}
              class="w-full border rounded px-2 py-1"
          />
          {#if usernameError}
              <p class="text-red-500 text-sm">{usernameError}</p>
          {/if}
      </div>
      <button
          on:click={handleUsernameChange}
          class="bg-blue-500 text-white px-4 py-2 rounded"
      >
          Lưu tên tài khoản
      </button>
  </div>
</div>
