<script>
    import { onMount } from 'svelte';
    import Navbar from '../components/NavBar.svelte';
    import Section from '../components/Section.svelte';
    import LoginModal from '../components/LoginModal.svelte';
  
    let showLoginModal = false;
    let isAuthenticated = false;
    const nullUser = { username: null, profilePic: null };
    let user = nullUser;
    let books = []; // Store books fetched from the API
  
    function toggleLoginModal() {
        showLoginModal = !showLoginModal;
    }
  
    /**
     * Handle successful login by storing user info and updating state
     * @param {any} loggedinUser
     */
    function handleLoginSuccess(loggedinUser) {
        isAuthenticated = true;
        user = loggedinUser;
        showLoginModal = false;
  
        // Store user info in localStorage
        localStorage.setItem('user', JSON.stringify(loggedinUser));
    }
  
    /**
     * Handle logout by resetting user info and removing it from storage
     */
    function logout() {
        isAuthenticated = false;
        user = nullUser;
  
        // Remove user info from localStorage
        localStorage.removeItem('user');
    }
  
    // Fetch books from API
    onMount(async () => {
        try {
            // Load user info from localStorage if available
            const storedUser = localStorage.getItem('user');
            if (storedUser) {
                user = JSON.parse(storedUser);
                isAuthenticated = true;
            }
  
            const response = await fetch('http://localhost:3000/getAllbooks');
            const data = await response.json();
            if (data.success) {
                books = data.books.map(book => ({
                    bookId: book.book_id,
                    title: book.title,
                    image: "covers/" + book.cover_path, // Assuming file_path contains the thumbnail or placeholder
                    author: book.author,
                }));
                books.sort((a, b) => parseInt(b.bookId.slice(1)) - parseInt(a.bookId.slice(1)))
            }
        } catch (error) {
            console.error('Failed to fetch books:', error);
        }
    });
  </script>
  
  <Navbar
    isAuthenticated={isAuthenticated}
    user={user}
    onLogin={toggleLoginModal}
    onLogout={logout}
  />
  
  <main class="bg-blue-100 py-32 max-w-full">
    <Section title="Truyện mới nhất" items={books} />
    <!-- <Section title="Lượt xem nhiều nhất" items={books} /> -->
  </main>
  
  {#if showLoginModal}
    <LoginModal 
      on:loginSuccess={(e) => handleLoginSuccess(e.detail)} 
      on:close={() => { showLoginModal = false }} 
    />
  {/if}
  