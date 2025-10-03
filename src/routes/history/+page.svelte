<script>
    import { goto } from '$app/navigation';
    import { onMount } from 'svelte';


    let username = '';
    let books = [];
    let currentPage = 1;
    let totalPages = 1;
    let userId =''; // Replace with dynamic userId if needed
    
    // Fetch user history
    async function fetchHistory() {
        let user = JSON.parse(localStorage.getItem('user'));
        userId = user.userId;
        username = user.username;
        try {
            const response = await fetch(`http://localhost:3000/user/history?userId=${userId}`);
            const result = await response.json();
            if (result.success) {
                books = result.history.map(item => ({
                    id: item.book_id,
                    title: item.title,
                    chapter: `Last Read Page: ${item.last_read_page || "N/A"}`,
                    cover: `covers/${item.cover_path}` || "/path/to/default-cover.jpg",
                }));
                totalPages = Math.ceil(books.length / 12); // Assuming 12 books per page
            } else {
                console.error("Failed to fetch history:", result.error);
            }
        } catch (error) {
            console.error("Error fetching history:", error);
        }
    }

    // Clear user history
    async function clearHistory() {
        if (confirm("Bạn có chắc chắn muốn xóa toàn bộ lịch sử?")) {
            try {
                const response = await fetch(`http://localhost:3000/user/history?userId=${userId}`, {
                    method: 'DELETE',
                });
                const result = await response.json();
                if (result.success) {
                    books = [];
                    totalPages = 1;
                    currentPage = 1;
                } else {
                    console.error("Failed to clear history:", result.error);
                }
            } catch (error) {
                console.error("Error clearing history:", error);
            }
        }
    }

    // Handle pagination
    function goToPage(page) {
        if (page >= 1 && page <= totalPages) {
            currentPage = page;
        }
    }

    // Go back to the previous page
    function goBack() {
        goto("/");
    }

    // Fetch history on component mount
    onMount(fetchHistory);
</script>

<div class="bg-blue-50 min-h-screen p-6">
    <header class="flex justify-between items-center mb-4">
        <h1 class="text-xl font-bold text-gray-700">Lịch sử người dùng: <span class="text-blue-600">{username}</span></h1>
        <button class="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600" on:click={goBack}>
            Quay Lại
        </button>
    </header>

    <div class="bg-white p-4 rounded-md shadow-md">
        <button class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 mb-4" on:click={clearHistory}>
            Xóa Lịch Sử
        </button>

        <div class="grid grid-cols-4 gap-4">
            {#each books.slice((currentPage - 1) * 12, currentPage * 12) as book}
                <div class="border rounded-md shadow-md p-4 text-center hover:shadow-lg transition">
                    <img src={book.cover} alt={book.title} class="w-full h-40 object-cover rounded-md" />
                    <h3 class="mt-2 text-gray-700 font-semibold">{book.title}</h3>
                    <p class="text-gray-500">{book.chapter}</p>
                </div>
            {/each}
        </div>

        <!-- Pagination -->
        <div class="mt-6 flex justify-center items-center gap-2">
            {#each Array(totalPages) as _, i}
                <button
                    class="px-4 py-2 border rounded-md text-gray-700 hover:bg-gray-100"
                    class:bg-blue-600={currentPage === i + 1}
                    class:text-white={currentPage === i + 1}
                    on:click={() => goToPage(i + 1)}
                >
                    {i + 1}
                </button>
            {/each}
        </div>
    </div>
</div>

<style>
    /* Add custom styles if necessary */
</style>
