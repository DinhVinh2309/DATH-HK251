<script>
  import { createEventDispatcher } from 'svelte';
  import { AlertCircle, X } from 'lucide-svelte';
  const dispatch = createEventDispatcher();

  let username = '';
  let password = '';
  let errorMessage = '';
  let isLoading = false;

  // Xóa thông báo lỗi khi người dùng bắt đầu nhập
  function clearError() {
    if (errorMessage) {
      errorMessage = '';
    }
  }

  async function handleLogin() {
    // Xóa lỗi cũ và bắt đầu loading
    errorMessage = '';
    isLoading = true;

    try {
      // Make an API call to the /login endpoint
      const response = await fetch(`http://localhost:3000/login?username=${username}&password=${password}`);

      // Lấy dữ liệu từ response (nếu có)
      const data = await response.json().catch(() => ({}));

      if (response.ok) {
        // Response thành công (status 200-299)
        if (data.success) {
          // Đăng nhập thành công
          dispatch('loginSuccess', { ...data, profilePic: "defaultProfilePic.png" });
        } else {
          // Trường hợp hiếm: response.ok nhưng success = false
          errorMessage = data.error || 'Đăng nhập thất bại. Vui lòng thử lại.';
        }
      } else {
        // Response không thành công - phân biệt loại lỗi dựa trên status code
        const status = response.status;

        if (status === 401) {
          // 401 Unauthorized: Sai thông tin đăng nhập
          errorMessage = 'Tên đăng nhập hoặc mật khẩu không đúng';
        } else if (status === 400) {
          // 400 Bad Request: Thiếu thông tin hoặc dữ liệu không hợp lệ
          errorMessage = 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu';
        } else if (status >= 500) {
          // 500+ Server Error: Lỗi từ phía server
          errorMessage = 'Lỗi máy chủ. Vui lòng thử lại sau.';
        } else {
          // Các lỗi khác (403, 404, etc.)
          errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại.';
        }
      }
    } catch (error) {
      // Lỗi network hoặc lỗi khi parse JSON
      console.error('Error during login:', error);
      if (error instanceof Error && error.name === 'TypeError' && error.message.includes('fetch')) {
        // Lỗi kết nối mạng
        errorMessage = 'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else {
        // Lỗi khác
        errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      }
    } finally {
      isLoading = false;
    }
  }
</script>

<div class="fixed inset-0 z-20 flex items-center justify-center bg-slate-900/60 px-4">
  <div
    class="w-full max-w-md rounded-3xl bg-slate-50 p-6 shadow-2xl sm:p-8"
    role="dialog"
    aria-modal="true"
  >
    <div class="mb-6 text-center">
      <h2 class="text-xl font-semibold tracking-tight text-slate-900">Chào mừng quý Độc giả!</h2>
      <p class="mt-2 text-sm text-slate-500">
        Đăng nhập để tiếp tục hành trình đọc sách của bạn.
      </p>
    </div>

    <!-- Thông báo lỗi -->
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
          <X size={16} />
        </button>
      </div>
    {/if}

    <form on:submit|preventDefault={handleLogin} class="space-y-4">
      <div class="space-y-1.5 text-left">
        <label class="block text-xs font-medium uppercase tracking-wide text-slate-600">
          Tên đăng nhập
        </label>
        <input
          type="text"
          bind:value={username}
          on:input={clearError}
          class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
          placeholder="Nhập tên đăng nhập"
        />
      </div>

      <div class="space-y-1.5 text-left">
        <label class="block text-xs font-medium uppercase tracking-wide text-slate-600">
          Mật khẩu
        </label>
        <input
          type="password"
          bind:value={password}
          on:input={clearError}
          class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-orange-500 focus:outline-none focus:ring-2 focus:ring-orange-100"
          placeholder="Nhập mật khẩu của bạn"
        />
        <!-- <div class="mt-1 text-right">
          <button
            type="button"
            class="text-xs font-medium text-orange-600 hover:text-orange-700"
          >
            Quên mật khẩu?
          </button>
        </div> -->
      </div>

      <button
        type="submit"
        disabled={isLoading}
        class="mt-2 w-full rounded-xl bg-orange-500 px-4 py-2.5 text-sm font-semibold text-white shadow-sm transition hover:bg-orange-600 disabled:cursor-not-allowed disabled:opacity-50"
      >
        {isLoading ? 'Đang đăng nhập...' : 'Đăng nhập'}
      </button>
    </form>

    <div class="mt-6 flex items-center justify-between text-xs text-slate-500">
      <span>Chưa có tài khoản?</span>
      <button
        type="button"
        class="font-medium text-orange-600 hover:text-orange-700"
        on:click={() => dispatch('close')}
      >
        Đăng ký tài khoản mới
      </button>
    </div>

    <button
      type="button"
      class="mt-4 w-full rounded-xl border border-slate-200 bg-white px-4 py-2 text-sm font-medium text-slate-700 transition hover:bg-slate-50"
      on:click={() => dispatch('close')}
    >
      Đóng
    </button>
  </div>
</div>
