<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';
    import { page } from '$app/stores';

    let bookTitle = "";
    let author = "";
    let bookId = $page.url.searchParams.get("bookId");
    let selectedPublisher = "";
    let publishers = [];
    let categories = [];
    let selectedCategories = [];
    let coverImage = null;
    let coverPreview = "";
    let pdfFile = null;
    let pdfFileName = "";

    async function fetchInitialData() {
        try {
            const resPublishers = await fetch('http://localhost:3000/getPublishers');
            const resCategories = await fetch('http://localhost:3000/getCategories');
            
            if (resPublishers.ok) publishers = await resPublishers.json();
            if (resCategories.ok) categories = await resCategories.json();
            
            if (bookId) {
                const resBook = await fetch(`http://localhost:3000/getBookDetails?bookId=${bookId}&userId=U0000001`);

                if (resBook.ok) {
                    const bookData = await resBook.json();
                    if (bookData.success && bookData.book) {
                        const book = bookData.book;
                        bookTitle = book.title || "";
                        author = book.author || "";
                        selectedPublisher = book.publisherId || "";
                        
                        // Convert category names to category IDs
                        // getBookDetails returns category names, but we need IDs for the form
                        const categoryNames = book.categories || [];
                        if (categoryNames.length > 0 && categories.length > 0) {
                            selectedCategories = categories
                                .filter(cat => categoryNames.includes(cat.name))
                                .map(cat => cat.category_id);
                        } else {
                            selectedCategories = [];
                        }
                        
                        if (book.coverPath) {
                            coverPreview = `covers/${book.coverPath}`;
                        }
                        if (book.filePath) {
                            pdfFileName = book.filePath.split('/').pop();
                        }
                    }
                }
            }

        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }

    function handleImageUpload(event) {
        const file = event.target.files[0];
        if (file) {
            coverImage = file;
            const reader = new FileReader();
            reader.onload = () => {
                coverPreview = reader.result;
            };
            reader.readAsDataURL(file);
        }
    }

    function handlePdfUpload(event) {
        const file = event.target.files[0];
        if (file) {
            pdfFile = file;
            pdfFileName = file.name;
        }
    }

    async function saveBook() {
        if (!bookTitle || !author || !bookId || !selectedPublisher) {
            alert("Vui lòng điền đầy đủ thông tin sách.");
            return;
        }

        const formData = new FormData();
        formData.append("title", bookTitle);
        formData.append("author", author);
        formData.append("bookId", bookId);
        formData.append("publisherId", selectedPublisher);
        formData.append("categories", JSON.stringify(selectedCategories));

        // Check if files are uploaded or use existing filenames
        if (coverImage) {
            formData.append("cover", coverImage);
        } else if (coverPreview) {
            formData.append("coverFilename", coverPreview.split('/').pop());
        }

        if (pdfFile) {
            formData.append("pdf", pdfFile);
        } else if (pdfFileName) {
            formData.append("pdfFilename", pdfFileName);
        }

        try {
            const response = await fetch("http://localhost:3000/addBook", {
                method: "POST",
                body: formData,
            });

            if (response.ok) {
                alert("Sách đã được chỉnh sửa thành công.");
                goto("/manageBookOption");
            } else {
                const errorData = await response.json();
                alert(errorData.error || "Đã xảy ra lỗi khi lưu sách.");
            }
        } catch (error) {
            console.error("Error saving book:", error);
            alert("Đã xảy ra lỗi khi lưu sách.");
        }
    }

    onMount(fetchInitialData);
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
          on:click={() => goto('/manageBookOption')}
        >
          <span>Quản lý sách</span>
        </button>
        <button
          type="button"
          class="flex w-full items-center gap-3 rounded-xl px-3 py-2 text-slate-200 hover:bg-slate-700/60"
        >
          <span>Quản lý người dùng</span>
        </button>
        <button
          type="button"
          class="flex w-full items-center gap-3 rounded-xl px-3 py-2 text-slate-200 hover:bg-slate-700/60"
        >
          <span>Thống kê</span>
        </button>
        <button
          type="button"
          class="flex w-full items-center gap-3 rounded-xl px-3 py-2 text-slate-200 hover:bg-slate-700/60"
          on:click={() => goto("/")}
        >
          <span>Quay lại trang đọc</span>
        </button>
      </nav>

      <div class="mt-auto border-t border-slate-700/60 px-6 py-4 text-xs text-slate-300">
        <p class="font-medium">Admin</p>
        <p class="truncate text-slate-400">admin@example.com</p>
      </div>
    </aside>

    <!-- Main Content -->
    <main class="flex-1 px-4 py-5 sm:px-6 lg:px-8">
      <!-- Top bar -->
      <header class="mb-5 flex flex-wrap items-center justify-between gap-3">
        <div>
          <h1 class="text-lg font-semibold text-[#233038]">Chỉnh sửa sách</h1>
          <p class="mt-1 text-sm text-slate-500">
            Cập nhật thông tin sách trong hệ thống
          </p>
        </div>
        <button
          class="rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
          on:click={() => goto('/manageBookOption')}
        >
          Quay lại
        </button>
      </header>

      <!-- Form Card -->
      <section class="rounded-3xl bg-white p-6 shadow-sm">
        <div class="flex gap-6">
          <!-- Image Section -->
          <div class="w-1/3 space-y-4">
            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                Bìa sách
              </label>
              <div class="w-full h-64 bg-slate-100 flex items-center justify-center rounded-xl relative overflow-hidden border-2 border-dashed border-slate-300 hover:border-[#075056] transition">
                {#if coverPreview}
                  <img src={coverPreview} alt="Cover Preview" class="w-full h-full object-cover" />
                {:else}
                  <div class="text-center p-4">
                    <svg class="mx-auto h-12 w-12 text-slate-400" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                      <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />
                    </svg>
                    <p class="mt-2 text-xs text-slate-500">Nhấp để tải ảnh bìa</p>
                  </div>
                {/if}
                <input type="file" accept="image/*" class="absolute inset-0 opacity-0 cursor-pointer" on:change={handleImageUpload} />
              </div>
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                File PDF
              </label>
              <div class="w-full h-32 bg-slate-50 flex items-center justify-center rounded-xl relative overflow-hidden border-2 border-dashed border-slate-300 hover:border-[#075056] transition">
                <input type="file" accept="application/pdf" class="absolute inset-0 opacity-0 cursor-pointer" on:change={handlePdfUpload} />
                {#if pdfFileName}
                  <div class="text-center p-4">
                    <svg class="mx-auto h-10 w-10 text-[#075056]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                    </svg>
                    <p class="mt-2 text-xs font-medium text-[#233038]">{pdfFileName}</p>
                  </div>
                {:else}
                  <div class="text-center p-4">
                    <svg class="mx-auto h-10 w-10 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
                    </svg>
                    <p class="mt-2 text-xs text-slate-500">Nhấp để tải file PDF</p>
                  </div>
                {/if}
              </div>
            </div>
          </div>

          <!-- Input Fields -->
          <div class="flex-1 space-y-4">
            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                Tên sách <span class="text-rose-500">*</span>
              </label>
              <input
                type="text"
                bind:value={bookTitle}
                class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-[#075056] focus:outline-none focus:ring-2 focus:ring-[#075056]/20"
                placeholder="Nhập tên sách"
              />
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                Tác giả <span class="text-rose-500">*</span>
              </label>
              <input
                type="text"
                bind:value={author}
                class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm placeholder:text-slate-400 focus:border-[#075056] focus:outline-none focus:ring-2 focus:ring-[#075056]/20"
                placeholder="Nhập tên tác giả"
              />
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                Nhà xuất bản <span class="text-rose-500">*</span>
              </label>
              <select
                bind:value={selectedPublisher}
                class="w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm text-slate-900 shadow-sm focus:border-[#075056] focus:outline-none focus:ring-2 focus:ring-[#075056]/20"
              >
                <option value="" disabled>Chọn nhà xuất bản</option>
                {#each publishers as publisher}
                  <option value={publisher.publisher_id}>{publisher.name}</option>
                {/each}
              </select>
            </div>

            <div>
              <label class="block text-xs font-medium uppercase tracking-wide text-slate-600 mb-2">
                Thể loại
              </label>
              <div class="flex flex-wrap gap-3 mt-2">
                {#each categories as category}
                  <label class="flex items-center cursor-pointer">
                    <input
                      type="checkbox"
                      value={category.category_id}
                      class="h-4 w-4 rounded border-slate-300 text-[#075056] focus:ring-[#075056]"
                      checked={selectedCategories.includes(category.category_id)}
                      on:change={(e) => {
                        const value = e.target.value;
                        if (e.target.checked) {
                          selectedCategories = [...selectedCategories, value];
                        } else {
                          selectedCategories = selectedCategories.filter((id) => id !== value);
                        }
                      }}
                    />
                    <span class="ml-2 text-sm text-slate-700">{category.name}</span>
                  </label>
                {/each}
              </div>
            </div>
          </div>
        </div>

        <!-- Save Button -->
        <div class="mt-6 flex justify-end gap-3 pt-4 border-t border-slate-100">
          <button
            class="rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50"
            on:click={() => goto('/manageBookOption')}
          >
            Hủy
          </button>
          <button
            class="inline-flex items-center gap-2 rounded-full bg-[#FF5B04] px-5 py-2 text-sm font-semibold text-white shadow-sm hover:bg-[#FBAB32]"
            on:click={saveBook}
          >
            <span>Lưu thay đổi</span>
          </button>
        </div>
      </section>
    </main>
  </div>
</div>
