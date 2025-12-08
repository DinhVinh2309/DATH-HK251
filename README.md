# BKBookBox - Digital Library Management System

A modern web application for managing and reading digital books. Users can browse books, read PDFs, manage favorites, track reading history, and administrators can manage the book catalog.

## Features

- **Book Reading**: Read PDF books with an integrated PDF viewer
- **Book Management**: Browse books by categories, search, and view details
- **User Accounts**: Register, login, and manage user profiles
- **Favorites**: Save favorite books for quick access
- **Reading History**: Track reading progress and history
- **Admin Panel**: Add, edit, and delete books (admin only)
- **Statistics**: View reading statistics and book popularity

## Technologies

### Frontend
- **SvelteKit** - Web framework
- **Tailwind CSS** - Styling
- **PDF.js** - PDF rendering
- **Lucide Svelte** - Icons
- **Vite** - Build tool

### Backend
- **Node.js** - Runtime environment
- **Express.js** - Web server
- **MySQL** - Database
- **Multer** - File upload handling

## Prerequisites

- Node.js (v18 or higher)
- MySQL Server (v8.0 or higher)
- npm or yarn

## Setup Instructions

### 1. Install Dependencies

```bash
npm install
```

### 2. Database Setup

1. Create a MySQL database named `bkbooks`
2. Update database credentials in `src/backend/server.js`:
   ```javascript
   host: "localhost",
   port: 3306,
   user: "root",
   password: "root",  // Change to your MySQL password
   database: "bkbooks",
   ```
3. Run the SQL script to create tables and initial data:
   ```bash
   mysql -u root -p bkbooks < src/backend/all.sql
   ```

### 3. Configure File Directories

Ensure the following directories exist:
- `static/covers/` - For book cover images
- `static/pdfs/` - For PDF book files

### 4. Start Backend Server

```bash
cd src/backend
node server.js
```

The backend server will run on `http://localhost:3000`

### 5. Start Frontend Development Server

In a new terminal:

```bash
npm run dev
```

The frontend will be available at `http://localhost:5173`

## Project Structure

```
├── src/
│   ├── backend/
│   │   ├── server.js          # Express API server
│   │   └── all.sql            # Database schema and initial data
│   ├── components/            # Reusable Svelte components
│   ├── routes/                # Application pages
│   │   ├── +page.svelte       # Home page
│   │   ├── info/              # Book details and reading
│   │   ├── history/           # Reading history
│   │   ├── favorites/         # Favorite books
│   │   ├── categories/        # Book categories
│   │   ├── search/            # Search results
│   │   ├── profile/           # User profile
│   │   ├── manageBookOption/  # Admin book management
│   │   ├── addBook/           # Add new book
│   │   └── editBook/          # Edit book
│   └── stores/                # State management
├── static/
│   ├── covers/                # Book cover images
│   └── pdfs/                  # PDF book files
└── package.json
```

## Available Scripts

- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run check` - Type checking
- `npm run lint` - Lint code

## Default Admin Account

After running `all.sql`, you can use the default admin account (if configured in the database).

## API Endpoints

The backend provides RESTful APIs including:
- `/getBooks` - Get all books
- `/getBookDetails` - Get book details
- `/searchBooks` - Search books
- `/getCategories` - Get all categories
- `/toggleFavorite` - Add/remove favorite
- `/addBook` - Add new book (admin)
- `/deleteBook` - Delete book (admin)
- And more...

## License

This project is part of an academic course assignment.
