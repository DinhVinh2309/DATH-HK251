<script>
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import Navbar from '../../components/NavBar.svelte';
  import LoginModal from '../../components/LoginModal.svelte';
  import { AlertCircle, CheckCircle } from 'lucide-svelte';

  let showLoginModal = false;
  let isAuthenticated = false;
  const nullUser = { username: null, profilePic: null, isAdmin: false };
  let user = nullUser;

  let account = '';
  let password = '';
  let confirmPassword = '';
  let name = '';
  let errorMessage = '';
  let successMessage = '';
  let isLoading = false;

  // Clear errors when user starts typing
  function clearError() {
    if (errorMessage) {
      errorMessage = '';
    }
    if (successMessage) {
      successMessage = '';
    }
  }

  // Validate form
  function validateForm() {
    if (!account.trim()) {
      errorMessage = 'Vui lòng nhập tên đăng nhập';
      return false;
    }
    if (account.length < 3) {
      errorMessage = 'Tên đăng nhập phải có ít nhất 3 ký tự';
      return false;
    }
    if (!password) {
      errorMessage = 'Vui lòng nhập mật khẩu';
      return false;
    }
    if (password.length < 6) {
      errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự';
      return false;
    }
    if (password !== confirmPassword) {
      errorMessage = 'Mật khẩu xác nhận không khớp';
      return false;
    }
    if (!name.trim()) {
      errorMessage = 'Vui lòng nhập tên hiển thị';
      return false;
    }
    if (name.length < 2) {
      errorMessage = 'Tên hiển thị phải có ít nhất 2 ký tự';
      return false;
    }
    return true;
  }

  async function handleRegister() {
    clearError();
    successMessage = '';

    if (!validateForm()) {
      return;
    }

    isLoading = true;

    try {
      const response = await fetch('http://localhost:3000/register', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          account: account.trim(),
          password: password,
          name: name.trim()
        })
      });

      const data = await response.json();

      if (response.ok && data.success) {
        successMessage = 'Đăng ký thành công! Đang chuyển về trang chủ...';
        // Clear form
        account = '';
        password = '';
        confirmPassword = '';
        name = '';
        // Auto redirect to home after 1.5 seconds
        setTimeout(() => {
          goto('/');
        }, 1500);
      } else {
        errorMessage = data.error || `Đăng ký thất bại (${response.status}). Vui lòng thử lại.`;
      }
    } catch (error) {
      console.error('Error during registration:', error);
      if (error instanceof Error && error.name === 'TypeError' && error.message.includes('fetch')) {
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng và đảm bảo server backend đang chạy.';
      } else {
        errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }
    } finally {
      isLoading = false;
    }
  }

  function toggleLoginModal() {
    showLoginModal = !showLoginModal;
  }

  function handleLoginSuccess(loggedinUser) {
    isAuthenticated = true;
    user = loggedinUser;
    showLoginModal = false;
    localStorage.setItem('user', JSON.stringify(loggedinUser));
    goto('/');
  }

  function logout() {
    isAuthenticated = false;
    user = nullUser;
    localStorage.removeItem('user');
  }

  onMount(() => {
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      try {
        user = JSON.parse(storedUser);
        isAuthenticated = true;
      } catch (e) {
        // ignore parse errors
      }
    }
  });
</script>

<svelte:head>
  <title>Đăng ký - BKBookBox</title>
</svelte:head>

<div class="min-h-screen bg-slate-100 pt-24 pb-16">
  <div class="mx-auto flex max-w-md items-center justify-center px-4">
    <div class="w-full rounded-3xl bg-white p-8 shadow-lg">
      <div class="mb-6 text-center">
        <h1 class="text-2xl font-semibold tracking-tight text-slate-900">Đăng ký tài khoản</h1>
        <p class="mt-2 text-sm text-slate-500">
          Tạo tài khoản mới để bắt đầu hành trình đọc sách của bạn
        </p>
      </div>

      <!-- Success message -->
      {#if successMessage}
        <div
          class="mb-4 flex items-start gap-3 rounded-xl border border-emerald-200 bg-emerald-50 p-3 text-sm text-emerald-800"
          role="alert"
        >
          <CheckCircle class="mt-0.5 flex-shrink-0" size={18} />
          <div class="flex-1">
            <p class="font-medium">{successMessage}</p>
          </div>
        </div>
      {/if}

      <!-- Error message -->
      {#if errorMessage}
        <div
          class="mb-4 flex items-start gap-3 rounded-xl border border-rose-200 bg-rose-50 p-3 text-sm text-rose-800"
          role="alert"
        >
          <AlertCircle class="mt-0.5 flex-shrink-0" size={18} />
          <div class="flex-1">
            <p class="font-medium">{errorMessage}</p>
          </div>
          <button
            type="button"
            on:click={() => (errorMessage = '')}
            class="flex-shrink-0 text-rose-600 hover:text-rose-800"
            aria-label="Đóng thông báo"
          >
            ×
          </button>
        </div>
      {/if}

      <form on:submit|preventDefault={handleRegister} class="space-y-4">
        <div class="space-y-1.5 text-left">
          <label for="name" class="block text-xs font-medium uppercase tracking-wide text-slate-600">
            Tên hiển thị <span class="text-rose-500">*</span>
          </label>
          <input
            type="text"
            id="name"
            bind:value={name}
            on:input={clearError}
            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
            placeholder="Nhập tên hiển thị"
            required
          />
          <p class="mt-1 text-xs text-slate-500">Tên này sẽ hiển thị trong toàn bộ hệ thống</p>
        </div>

        <div class="space-y-1.5 text-left">
          <label for="account" class="block text-xs font-medium uppercase tracking-wide text-slate-600">
            Tên đăng nhập <span class="text-rose-500">*</span>
          </label>
          <input
            type="text"
            id="account"
            bind:value={account}
            on:input={clearError}
            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
            placeholder="Nhập tên đăng nhập (tối thiểu 3 ký tự)"
            required
          />
          <p class="mt-1 text-xs text-slate-500">Tên đăng nhập dùng để đăng nhập vào hệ thống</p>
        </div>

        <div class="space-y-1.5 text-left">
          <label for="password" class="block text-xs font-medium uppercase tracking-wide text-slate-600">
            Mật khẩu <span class="text-rose-500">*</span>
          </label>
          <input
            type="password"
            id="password"
            bind:value={password}
            on:input={clearError}
            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
            placeholder="Nhập mật khẩu (tối thiểu 6 ký tự)"
            required
          />
        </div>

        <div class="space-y-1.5 text-left">
          <label for="confirmPassword" class="block text-xs font-medium uppercase tracking-wide text-slate-600">
            Xác nhận mật khẩu <span class="text-rose-500">*</span>
          </label>
          <input
            type="password"
            id="confirmPassword"
            bind:value={confirmPassword}
            on:input={clearError}
            class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
            placeholder="Nhập lại mật khẩu"
            required
          />
        </div>

        <button
          type="submit"
          disabled={isLoading}
          class="mt-4 w-full rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-orange-600 disabled:cursor-not-allowed disabled:opacity-50"
        >
          {isLoading ? 'Đang đăng ký...' : 'Đăng ký'}
        </button>
      </form>

      <div class="mt-6 text-center text-sm text-slate-500">
        <span>Đã có tài khoản?</span>
        <button
          type="button"
          class="ml-1 font-medium text-orange-600 hover:text-orange-700"
          on:click={toggleLoginModal}
        >
          Đăng nhập ngay
        </button>
      </div>

      <button
        type="button"
        class="mt-4 w-full rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
        on:click={() => goto('/')}
      >
        Quay lại trang chủ
      </button>
    </div>
  </div>
</div>

{#if showLoginModal}
  <LoginModal on:loginSuccess={handleLoginSuccess} on:close={() => (showLoginModal = false)} />
{/if}

