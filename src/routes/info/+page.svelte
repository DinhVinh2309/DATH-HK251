<script>
  import { onMount, tick } from 'svelte';
  import { page } from '$app/stores';
  import { goto } from '$app/navigation';
  import { browser } from '$app/environment';

  let book = null;
  let bookId = null;
  let userId = null; // Will be set from localStorage
  let isLiked = false;
  let showModal = false; // Modal state
  
  // PDF viewer states
  let pdfjsLib = null; // Will be loaded dynamically on client-side
  let pdfDoc = null;
  let currentPage = 1;
  let totalPages = 1;
  let loadingPdf = false;
  let pdfError = '';
  let pdfCanvas = null;
  let pdfContainer = null;
  let pdfScale = 1.5; // Default zoom scale
  const minScale = 0.5;
  const maxScale = 3.0;
  const scaleStep = 0.25; // Zoom step size

  // Load PDF.js only on client-side
  async function loadPdfjs() {
    if (browser && !pdfjsLib) {
      try {
        pdfjsLib = await import('pdfjs-dist');
        // Use local worker file from static folder
        pdfjsLib.GlobalWorkerOptions.workerSrc = '/pdf.worker.min.mjs';
      } catch (error) {
        console.error('Failed to load PDF.js:', error);
        pdfError = 'Không thể tải thư viện PDF. Vui lòng thử lại.';
      }
    }
  }

  // Dynamically extract the `bookId` from the URL query params
  $: bookId = $page.url.searchParams.get('bookId');

  // Fetch book details from the endpoint
  async function fetchBookDetails() {
    if (!bookId) return;
    
    const storedUser = localStorage.getItem('user');
    if (storedUser) {
      try {
        const user = JSON.parse(storedUser);
        if (user && user.userId) {
          userId = user.userId;
        }
      } catch (e) {
        console.error('Error parsing user:', e);
      }
    }

    try {
      const response = await fetch(`http://localhost:3000/getBookDetails?bookId=${bookId}&userId=${userId || ''}`);
      const data = await response.json();

      if (data.success) {
        book = data.book;
        isLiked = book.isFavorite === true || book.isFavorite === 1; // Map API response to `isLiked`
        console.log('Book details loaded:', {
          title: book.title,
          filePath: book.filePath,
          coverPath: book.coverPath
        });
      } else {
        console.error('Failed to fetch book details:', data.message);
      }
    } catch (error) {
      console.error('Error fetching book details:', error);
    }
  }

  async function updateReadHistory(pageNum = null) {
    if (!bookId || !userId) return;

    const pageToSave = pageNum !== null ? pageNum : currentPage;

    try {
      const response = await fetch(`http://localhost:3000/updateReadHistory?bookId=${bookId}&userId=${userId}&lastReadPage=${pageToSave}`, {
        method: 'POST',
      });
      const data = await response.json();

      if (!data.success) {
        console.error('Failed to update read history:', data.message);
      }
    } catch (error) {
      console.error('Error updating read history:', error);
    }
  }

  async function toggleLike() {
    // Ensure userId is loaded
    if (!userId) {
      const storedUser = localStorage.getItem('user');
      if (storedUser) {
        try {
          const user = JSON.parse(storedUser);
          if (user && user.userId) {
            userId = user.userId;
          } else {
            console.error('User ID not found in localStorage');
            alert('Vui lòng đăng nhập để sử dụng chức năng yêu thích.');
            return;
          }
        } catch (e) {
          console.error('Error parsing user:', e);
          alert('Vui lòng đăng nhập để sử dụng chức năng yêu thích.');
          return;
        }
      } else {
        alert('Vui lòng đăng nhập để sử dụng chức năng yêu thích.');
        return;
      }
    }

    if (!bookId || !userId) {
      console.error('Missing bookId or userId:', { bookId, userId });
      return;
    }

    try {
      const response = await fetch('http://localhost:3000/toggleFavorite', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          userId: userId,
          bookId: bookId
        })
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error('HTTP error:', response.status, errorText);
        alert(`Lỗi: ${response.status}. Vui lòng thử lại.`);
        return;
      }

      const data = await response.json();

      if (data.success) {
        isLiked = data.isFavorite;
        // Update total favorites count
        if (data.isFavorite) {
          book.totalFavorites = (book.totalFavorites || 0) + 1;
        } else {
          book.totalFavorites = Math.max(0, (book.totalFavorites || 0) - 1);
        }
      } else {
        console.error('Failed to toggle favorite:', data.error);
        alert(data.error || 'Không thể cập nhật yêu thích. Vui lòng thử lại.');
      }
    } catch (error) {
      console.error('Error toggling favorite:', error);
      alert('Đã xảy ra lỗi. Vui lòng thử lại.');
    }
  }

  async function loadPdf() {
    if (!book || !book.filePath) {
      pdfError = 'Không tìm thấy file PDF';
      console.error('Missing book or filePath:', { book, filePath: book?.filePath });
      return;
    }

    // Ensure PDF.js is loaded
    await loadPdfjs();
    
    if (!pdfjsLib) {
      pdfError = 'Không thể tải thư viện PDF. Vui lòng thử lại.';
      return;
    }

    loadingPdf = true;
    pdfError = '';

    try {
      const pdfPath = `/pdfs/${book.filePath}`;
      console.log('Loading PDF from path:', pdfPath);
      console.log('Full book object:', book);
      
      const loadingTask = pdfjsLib.getDocument({
        url: pdfPath,
        httpHeaders: {},
        withCredentials: false
      });
      
      pdfDoc = await loadingTask.promise;
      console.log('PDF loaded successfully. Total pages:', pdfDoc.numPages);
      
      totalPages = pdfDoc.numPages;
      
      // Load the page that user was reading last time (if available)
      const savedPage = book.lastReadPage ? Math.max(1, Math.min(Math.floor(book.lastReadPage), totalPages)) : 1;
      currentPage = savedPage;
      
      // Wait for canvas to be ready in DOM before rendering
      await tick();
      await new Promise(resolve => setTimeout(resolve, 100));
      
      if (!pdfCanvas) {
        // Wait a bit more and try again
        await tick();
        await new Promise(resolve => setTimeout(resolve, 100));
      }
      
      if (!pdfCanvas) {
        console.error('Canvas not found after waiting');
        pdfError = 'Không thể khởi tạo canvas để hiển thị PDF. Vui lòng thử lại.';
        loadingPdf = false;
        return;
      }
      
      await renderPage(currentPage);
    } catch (error) {
      console.error('Error loading PDF:', error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      const errorName = error instanceof Error ? error.name : 'Unknown';
      console.error('Error details:', {
        message: errorMessage,
        name: errorName,
        filePath: book?.filePath,
        pdfPath: `/pdfs/${book?.filePath}`
      });
      pdfError = `Không thể tải file PDF. ${errorMessage || 'Vui lòng thử lại.'}`;
    } finally {
      loadingPdf = false;
    }
  }

  async function renderPage(pageNum) {
    if (!pdfDoc || !pdfCanvas) return;

    try {
      const page = await pdfDoc.getPage(pageNum);
      const context = pdfCanvas.getContext('2d');
      const viewport = page.getViewport({ scale: pdfScale });
      
      // Set canvas dimensions
      pdfCanvas.height = viewport.height;
      pdfCanvas.width = viewport.width;

      // Render PDF page
      const renderContext = {
        canvasContext: context,
        viewport: viewport
      };

      await page.render(renderContext).promise;
      
      // Save the current page to read history
      await updateReadHistory(pageNum);
    } catch (error) {
      console.error('Error rendering PDF page:', error);
      pdfError = 'Không thể hiển thị trang PDF.';
    }
  }

  async function zoomIn() {
    if (pdfScale < maxScale) {
      pdfScale = Math.min(pdfScale + scaleStep, maxScale);
      await renderPage(currentPage);
      if (pdfContainer) {
        pdfContainer.scrollTop = pdfContainer.scrollTop;
      }
    }
  }

  async function zoomOut() {
    if (pdfScale > minScale) {
      pdfScale = Math.max(pdfScale - scaleStep, minScale);
      await renderPage(currentPage);
      if (pdfContainer) {
        pdfContainer.scrollTop = pdfContainer.scrollTop;
      }
    }
  }

  async function resetZoom() {
    pdfScale = 1.5;
    await renderPage(currentPage);
    if (pdfContainer) {
      pdfContainer.scrollTop = 0;
    }
  }

  async function setZoom(scale) {
    pdfScale = Math.max(minScale, Math.min(scale, maxScale));
    await renderPage(currentPage);
  }

  async function nextPage() {
    if (currentPage < totalPages) {
      currentPage++;
      await renderPage(currentPage);
      // Scroll to top of container
      if (pdfContainer) {
        pdfContainer.scrollTop = 0;
      }
    }
  }

  async function previousPage() {
    if (currentPage > 1) {
      currentPage--;
      await renderPage(currentPage);
      // Scroll to top of container
      if (pdfContainer) {
        pdfContainer.scrollTop = 0;
      }
    }
  }

  async function goToPage(pageNum) {
    const targetPage = Math.max(1, Math.min(pageNum, totalPages));
    if (targetPage !== currentPage) {
      currentPage = targetPage;
      await renderPage(currentPage);
      if (pdfContainer) {
        pdfContainer.scrollTop = 0;
      }
    }
  }

  async function openReaderModal() {
    showModal = true;
    // Wait for modal and canvas to be rendered in DOM
    await tick();
    // Additional wait to ensure canvas is fully mounted
    await new Promise(resolve => setTimeout(resolve, 50));
    await loadPdf();
  }

  function closeReaderModal() {
    showModal = false;
    pdfDoc = null;
    currentPage = 1;
    totalPages = 1;
    pdfError = '';
  }

  // Fetch book details when the component mounts
  onMount(async () => {
    await fetchBookDetails();
    // Pre-load PDF.js when component mounts (on client-side only)
    if (browser) {
      await loadPdfjs();
    }
  });
</script>

{#if book}
  <div class="min-h-screen bg-slate-100 pt-24 pb-16">
    <div class="mx-auto flex max-w-6xl flex-col gap-8 px-4 sm:px-6 lg:flex-row">
      <!-- Left: cover + meta -->
      <aside class="w-full rounded-3xl bg-white p-6 shadow-sm lg:w-80 lg:shrink-0">
        <div class="overflow-hidden rounded-2xl bg-slate-100">
          <img
            src={"covers/" + book.coverPath}
            alt={book.title}
            class="h-64 w-full object-cover"
          />
        </div>
        <div class="mt-4 space-y-2 text-sm text-slate-600">
          <p>
            <span class="font-medium text-slate-900">Tác giả:</span>
            <span class="ml-1">{book.author}</span>
          </p>
          <p>
            <span class="font-medium text-slate-900">Lượt đọc:</span>
            <span class="ml-1">{book.totalReaders || 0}</span>
          </p>
          <p>
            <span class="font-medium text-slate-900">Yêu thích:</span>
            <span class="ml-1">{book.totalFavorites || 0}</span>
          </p>
        </div>

        <div class="mt-4 flex flex-wrap gap-2">
          {#each book.categories as category}
            <span class="rounded-full bg-slate-100 px-3 py-1 text-xs font-medium text-slate-700">
              {category}
            </span>
          {/each}
        </div>

        <div class="mt-6 flex flex-col gap-2">
          <button
            class="w-full rounded-full bg-orange-500 px-4 py-2 text-sm font-semibold text-white shadow-sm hover:bg-orange-600"
            on:click={openReaderModal}
          >
            Bắt đầu đọc
          </button>
          <button
            class="w-full rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
            class:is-liked={isLiked}
            on:click={toggleLike}
          >
            {isLiked ? 'Đã thích' : 'Thêm vào yêu thích'}
          </button>
          <button
            class="w-full rounded-full border border-slate-200 px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
            on:click={() => goto('/')}
          >
            Quay lại trang chủ
          </button>
        </div>
      </aside>

      <!-- Right: reading area -->
      <section class="flex-1 rounded-3xl bg-white p-6 shadow-sm">
        <header class="mb-4 border-b border-slate-100 pb-4">
          <p class="text-xs font-semibold uppercase tracking-[0.16em] text-slate-400">
            Cuốn sách
          </p>
          <h1 class="mt-1 text-2xl font-semibold text-slate-900">{book.title}</h1>
          <p class="mt-1 text-sm text-slate-500">
            Trải nghiệm đọc toàn màn hình với chế độ nền sáng dễ chịu và thanh tiến độ đọc.
          </p>
        </header>

        <!-- Book Description -->
        <div class="space-y-6">
          {#if book.description}
            <div class="space-y-4">
              <h2 class="text-lg font-semibold text-slate-900">Giới thiệu</h2>
              <div class="prose prose-sm max-w-none text-slate-700">
                <p class="leading-relaxed whitespace-pre-wrap">{book.description}</p>
              </div>
            </div>
          {:else}
            <div class="space-y-4">
              <h2 class="text-lg font-semibold text-slate-900">Giới thiệu</h2>
              <p class="text-slate-700 leading-relaxed">
                Cuốn sách "<strong>{book.title}</strong>" của tác giả <strong>{book.author}</strong> là một tác phẩm 
                đáng đọc với {book.pageCount || 'nhiều'} trang nội dung hấp dẫn. Hãy bắt đầu đọc để khám phá những 
                câu chuyện thú vị trong cuốn sách này.
              </p>
            </div>
          {/if}

          <!-- Book Stats -->
          <div class="rounded-2xl bg-slate-50 p-6">
            <h3 class="mb-4 text-sm font-semibold text-slate-900">Thông tin sách</h3>
            <div class="grid grid-cols-2 gap-4 text-sm">
              <div>
                <p class="text-slate-500">Số trang</p>
                <p class="mt-1 font-semibold text-slate-900">{book.pageCount || 'N/A'} trang</p>
              </div>
              <div>
                <p class="text-slate-500">Thể loại</p>
                <p class="mt-1 font-semibold text-slate-900">{book.publicationType || 'Ebook'}</p>
              </div>
            </div>
          </div>
        </div>
      </section>
    </div>

    <!-- Full-screen reader modal -->
    {#if showModal}
      <div class="fixed inset-0 z-30 flex bg-slate-900/80">
        <div class="mx-auto flex w-full max-w-6xl flex-1 flex-col px-4 py-6 text-slate-50">
          <header class="mb-4 flex items-center justify-between">
            <div>
              <p class="text-xs uppercase tracking-[0.16em] text-slate-400">
                Đang đọc
              </p>
              <h2 class="text-lg font-semibold">{book.title}</h2>
            </div>
            <div class="flex items-center gap-3">
              <!-- Zoom Controls -->
              {#if pdfDoc && !loadingPdf}
                <div class="flex items-center gap-2 rounded-full border border-slate-500 bg-slate-800/50 px-2 py-1">
                  <button
                    class="rounded-full p-1.5 text-slate-300 hover:bg-slate-700 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    on:click={zoomOut}
                    disabled={pdfScale <= minScale}
                    title="Thu nhỏ"
                    aria-label="Thu nhỏ PDF"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="11" cy="11" r="8"></circle>
                      <path d="m21 21-4.35-4.35"></path>
                      <line x1="8" y1="11" x2="14" y2="11"></line>
                    </svg>
                  </button>
                  <span class="min-w-[3rem] text-center text-xs text-slate-300">
                    {Math.round(pdfScale * 100)}%
                  </span>
                  <button
                    class="rounded-full p-1.5 text-slate-300 hover:bg-slate-700 hover:text-white disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                    on:click={zoomIn}
                    disabled={pdfScale >= maxScale}
                    title="Phóng to"
                    aria-label="Phóng to PDF"
                  >
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                      <circle cx="11" cy="11" r="8"></circle>
                      <path d="m21 21-4.35-4.35"></path>
                      <line x1="11" y1="8" x2="11" y2="14"></line>
                      <line x1="8" y1="11" x2="14" y2="11"></line>
                    </svg>
                  </button>
                  <button
                    class="ml-1 rounded-full px-2 py-1 text-xs text-slate-300 hover:bg-slate-700 hover:text-white transition-colors"
                    on:click={resetZoom}
                    title="Đặt lại zoom"
                  >
                    Reset
                  </button>
                </div>
              {/if}
              <button
                class="rounded-full border border-slate-500 px-4 py-1.5 text-xs font-medium hover:bg-slate-800"
                on:click={closeReaderModal}
              >
                Thoát chế độ đọc
              </button>
            </div>
          </header>

          <div class="flex flex-1 overflow-hidden">
            <main
              bind:this={pdfContainer}
              class="w-full overflow-y-auto rounded-2xl bg-slate-900/60 p-5"
            >
              {#if pdfError}
                <div class="flex items-center justify-center py-20">
                  <p class="text-rose-400">{pdfError}</p>
                </div>
              {:else}
                <div class="flex flex-col items-center">
                  {#if loadingPdf}
                    <div class="mb-4 text-center">
                      <div class="mb-4 inline-block h-8 w-8 animate-spin rounded-full border-4 border-slate-400 border-t-transparent"></div>
                      <p class="text-slate-400">Đang tải PDF...</p>
                    </div>
                  {/if}
                  <canvas bind:this={pdfCanvas} class="shadow-2xl {loadingPdf ? 'hidden' : ''}"></canvas>
                </div>
              {/if}
            </main>
          </div>

          <footer class="mt-4 flex items-center justify-between text-xs text-slate-300">
            <button
              class="rounded-full border border-slate-500 px-3 py-1.5 hover:bg-slate-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              on:click={previousPage}
              disabled={currentPage <= 1 || loadingPdf || !pdfDoc}
            >
              ← Trước
            </button>
            <div class="flex items-center gap-2">
              <input
                type="number"
                min="1"
                max={totalPages}
                bind:value={currentPage}
                on:change={(e) => {
                  const target = e.target;
                  if (target && typeof target === 'object' && 'value' in target) {
                    const value = String(target.value);
                    const pageNum = parseInt(value);
                    if (!isNaN(pageNum)) {
                      goToPage(pageNum);
                    }
                  }
                }}
                class="w-16 rounded border border-slate-500 bg-slate-800 px-2 py-1 text-center text-white focus:border-orange-500 focus:outline-none"
                disabled={loadingPdf || !pdfDoc}
              />
              <span>/ {totalPages}</span>
            </div>
            <div class="mx-4 h-1 flex-1 rounded-full bg-slate-700">
              <div
                class="h-1 rounded-full bg-orange-500 transition-all"
                style="width: {totalPages > 0 ? (currentPage / totalPages) * 100 : 0}%"
              ></div>
            </div>
            <span class="mx-2">{totalPages > 0 ? Math.round((currentPage / totalPages) * 100) : 0}%</span>
            <button
              class="rounded-full border border-slate-500 px-3 py-1.5 hover:bg-slate-800 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              on:click={nextPage}
              disabled={currentPage >= totalPages || loadingPdf || !pdfDoc}
            >
              Sau →
            </button>
          </footer>
        </div>
      </div>
    {/if}
  </div>
{:else}
  <div class="flex min-h-screen items-center justify-center bg-slate-100">
    <p class="text-sm text-slate-500">Đang tải...</p>
  </div>
{/if}
