<script>
    import { onMount } from 'svelte';
    import { goto } from '$app/navigation';

    let bookTitle = "";
    let author = "";
    let bookId = "";
    let selectedPublisher = "";
    let publishers = [];
    let categories = [];
    let selectedCategories = [];
    let coverImage = null;
    let coverPreview = "";
    let pdfFile = null;
    let pdfFileName = ""; // To store the name of the uploaded PDF file

    async function fetchInitialData() {
        try {
            const resPublishers = await fetch('http://localhost:3000/getPublishers');
            const resCategories = await fetch('http://localhost:3000/getCategories');

            if (resPublishers.ok) publishers = await resPublishers.json();
            if (resCategories.ok) categories = await resCategories.json();
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
            pdfFileName = file.name; // Set the filename when PDF is uploaded
        }
    }

    async function saveBook() {
        if (!bookTitle || !author || !selectedPublisher || !(pdfFile || pdfFileName) || !(coverImage)) {
            alert("Vui lòng điền đầy đủ thông tin sách.");
            return;
        }

        const formData = new FormData();
        formData.append("title", bookTitle);
        formData.append("author", author);
        formData.append("bookId", "NULL");
        formData.append("publisherId", selectedPublisher);
        formData.append("categories", JSON.stringify(selectedCategories));
        if (coverImage) {
            formData.append("cover", coverImage);
        }
        if (pdfFile) {
            formData.append("pdf", pdfFile);
        }

        try {
            const response = await fetch("http://localhost:3000/addBook", {
                method: "POST",
                body: formData,
            });

            if (response.ok) {
                alert("Sách đã được thêm thành công.");
                goto("/manageBookOption"); // Redirect to home
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

<div class="bg-blue-50 min-h-screen p-6">
    <header class="flex justify-between items-center mb-4">
        <h1 class="text-2xl font-bold text-blue-600">Thêm Sách Mới</h1>
        <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600" on:click={() => goto('/')}>Quay Lại</button>
    </header>

    <div class="bg-white p-6 rounded-md shadow-md">
        <div class="flex gap-6">
            <!-- Image Section -->
            <div class="w-1/3 space-y-4">
                <div class="w-full h-48 bg-gray-200 flex items-center justify-center rounded relative">
                    {#if coverPreview}
                        <img src={coverPreview} alt="Cover Preview" class="w-full h-full object-cover rounded" />
                    {:else}
                        <span class="text-gray-500">Thêm hình ảnh</span>
                    {/if}
                    <input type="file" accept="image/*" class="absolute inset-0 opacity-0 cursor-pointer" on:change={handleImageUpload} />
                </div>

                <div class="w-full h-32 bg-gray-100 flex items-center justify-center rounded relative">

                    <input type="file" accept="application/pdf" class="absolute inset-0 opacity-0 cursor-pointer" on:change={handlePdfUpload} />
                    {#if pdfFileName}
                        <div class="mt-2 text-gray-700">Tệp đã chọn: {pdfFileName}</div> <!-- Display filename -->
                    {:else}
                        <span class="text-gray-500">Thêm tệp PDF</span>
                    {/if}
                </div>
            </div>

            <!-- Input Fields -->
            <div class="flex-1 space-y-4">
                <div>
                    <label class="block text-gray-700 font-semibold">Tên Truyện - Sách:</label>
                    <input type="text" bind:value={bookTitle} class="border border-gray-300 rounded-md w-full p-2" />
                </div>
                <div>
                    <label class="block text-gray-700 font-semibold">Tác giả:</label>
                    <input type="text" bind:value={author} class="border border-gray-300 rounded-md w-full p-2" />
                </div>
                <!-- <div>
                    <label class="block text-gray-700 font-semibold">Mã Sách:</label>
                    <input type="text" bind:value={bookId} class="border border-gray-300 rounded-md w-full p-2" />
                </div> -->
                <div>
                    <label class="block text-gray-700 font-semibold">Nhà Xuất Bản:</label>
                    <select bind:value={selectedPublisher} class="border border-gray-300 rounded-md w-full p-2">
                        <option value="" disabled>Chọn nhà xuất bản</option>
                        {#each publishers as publisher}
                            <option value={publisher.publisher_id}>{publisher.name}</option>
                        {/each}
                    </select>
                </div>
                <div>
                    <label class="block text-gray-700 font-semibold">Thể Loại:</label>
                    <div class="flex flex-wrap gap-8 mt-2">
                        {#each categories as category}
                            <label class="flex items-center">
                                <input type="checkbox" value={category.category_id} on:change={(e) => {
                                    const value = e.target.value;
                                    if (e.target.checked) {
                                        selectedCategories = [...selectedCategories, value];
                                    } else {
                                        selectedCategories = selectedCategories.filter((id) => id !== value);
                                    }
                                }} />
                                <span class="ml-2">{category.name}</span>
                            </label>
                        {/each}
                    </div>
                </div>
            </div>
        </div>

        <!-- Save Button -->
        <div class="mt-6 flex justify-end">
            <button class="px-6 py-2 bg-blue-500 text-white rounded hover:bg-blue-600" on:click={saveBook}>Xác nhận</button>
        </div>
    </div>
</div>
