<script>
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher();

  let username = '';
  let password = '';

  async function handleLogin() {
      try {
          // Make an API call to the /login endpoint
          const response = await fetch(`http://localhost:3000/login?username=${username}&password=${password}`);

          if (response.ok) {
              const data = await response.json();

              if (data.success) {
                  // Dispatch loginSuccess event with the user data
                  dispatch('loginSuccess', { ...data, profilePic:"defaultProfilePic.png"});
              } else {
                  // Handle login failure
                  alert(data.error || 'Invalid username or password');
              }
          } else {
              alert('Failed to log in. Please try again.');
          }
      } catch (error) {
          console.error('Error during login:', error);
          alert('An error occurred. Please try again.');
      }
  }
</script>

<div class="fixed inset-0 bg-gray-800 bg-opacity-50 flex justify-center items-center z-20">
  <div class="bg-white rounded shadow-md p-8 w-96 relative">
      <h2 class="text-lg font-bold text-blue-600 mb-4">ĐĂNG NHẬP</h2>
      <form on:submit|preventDefault={handleLogin} class="space-y-4">
          <div>
              <label class="block text-gray-700">Tên tài khoản</label>
              <input type="text" bind:value={username} class="border rounded w-full px-3 py-2" />
          </div>
          <div>
              <label class="block text-gray-700">Mật khẩu</label>
              <input type="password" bind:value={password} class="border rounded w-full px-3 py-2" />
          </div>
          <div class="flex justify-between">
              <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">Xác Nhận</button>
              <button type="button" class="bg-gray-300 px-4 py-2 rounded" on:click={() => dispatch('close')}>
                  Hoàn tác
              </button>
          </div>
      </form>
      <div class="flex justify-between mt-4 text-blue-600">
          <a href="#" class="hover:underline">Đăng kí</a>
          <a href="#" class="hover:underline">Quên mật khẩu</a>
      </div>
  </div>
</div>
