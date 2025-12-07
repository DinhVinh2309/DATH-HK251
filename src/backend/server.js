import express from "express";
import mysql from "mysql2/promise";
import bodyParser from "body-parser";
import multer from "multer";
import cors from "cors";
import path from "path"; // Required for handling file paths
import { fileURLToPath } from 'url';
import { dirname } from 'path';
import fs from 'fs';

// Get __dirname equivalent for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();

// Enable CORS for all origins
app.use(cors());

// Parse incoming requests
app.use(bodyParser.json());


// MySQL connection pool
const pool = mysql.createPool({
  host: "localhost",      // MySQL server address
  port: 3306,             // MySQL server port
  user: "root",           // MySQL username
  password: "root",       // MySQL password
  database: "bkbooks",    // MySQL database
  waitForConnections: true,
  connectionLimit: 10,    // Maximum number of connections
  queueLimit: 0,
});

// Get Publishers
app.get('/getPublishers', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM publishers');
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Error fetching publishers' });
    }
});

// Get Categories
app.get('/getCategories', async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM Categories ORDER BY name ASC');
        console.log('Fetched categories:', rows);
        res.json(rows);
    } catch (error) {
        console.error('Error fetching categories:', error);
        res.status(500).json({ error: 'Error fetching categories' });
    }
});

// Get Books by Category
app.get('/getBooksByCategory', async (req, res) => {
    const { categoryId } = req.query;
    
    if (!categoryId) {
        return res.status(400).json({ success: false, error: 'Category ID is required' });
    }

    try {
        console.log(`Fetching books for category: ${categoryId}`);
        
        const [rows] = await pool.query(
            `SELECT 
                b.book_id,
                b.title,
                b.author,
                b.cover_path,
                COALESCE(bs.total_favorites, 0) as total_favorites
            FROM Books b
            INNER JOIN BookCategories bc ON b.book_id = bc.book_id
            LEFT JOIN BookStatistics bs ON b.book_id = bs.book_id
            WHERE bc.category_id = ?
            ORDER BY b.title ASC`,
            [categoryId]
        );

        console.log(`Found ${rows.length} books for category ${categoryId}`);
        res.json({ success: true, books: rows });
    } catch (error) {
        console.error('Error fetching books by category:', error);
        res.status(500).json({ success: false, error: 'Error fetching books by category' });
    }
});


// Define absolute paths for upload directories
const staticDir = path.join(__dirname, '../../static');
const coversDir = path.join(staticDir, 'covers');
const pdfsDir = path.join(staticDir, 'pdfs');

// Log the paths for debugging
console.log('Upload directories configured:');
console.log('  Static dir:', staticDir);
console.log('  Covers dir:', coversDir);
console.log('  PDFs dir:', pdfsDir);

// Ensure directories exist
if (!fs.existsSync(coversDir)) {
    fs.mkdirSync(coversDir, { recursive: true });
    console.log('Created covers directory:', coversDir);
}
if (!fs.existsSync(pdfsDir)) {
    fs.mkdirSync(pdfsDir, { recursive: true });
    console.log('Created pdfs directory:', pdfsDir);
}

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        // Specify the directory where the uploaded files should be stored
        let uploadDir;
        if (file.fieldname === 'cover') {
            uploadDir = coversDir;
        } else if (file.fieldname === 'pdf') {
            uploadDir = pdfsDir;
        } else {
            uploadDir = staticDir;
        }
        console.log(`File upload destination for ${file.fieldname}: ${uploadDir}`);
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        // Extract file extension from the original filename
        const fileExtension = path.extname(file.originalname); 
        // Give a unique name to each file to avoid conflicts, and append the file extension
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const filename = file.fieldname + '-' + uniqueSuffix + fileExtension;
        console.log(`Generated filename for ${file.fieldname}: ${filename}`);
        cb(null, filename); // Appends the file extension
    }
});
// Delete Book
app.delete("/deleteBook", async (req, res) => {
  const { bookId } = req.query;

  if (!bookId) {
    return res.status(400).json({ success: false, error: "Book ID is required" });
  }

  let connection = null;
  try {
    connection = await pool.getConnection();
    await connection.beginTransaction();

    // Get book file paths before deletion for cleanup
    const [bookRows] = await connection.query(
      'SELECT cover_path, file_path FROM Books WHERE book_id = ?',
      [bookId]
    );

    // Delete from all related tables
    // Delete from FavoriteListBooks first
    await connection.query('DELETE FROM FavoriteListBooks WHERE book_id = ?', [bookId]);
    
    // Delete from AdminManages
    await connection.query('DELETE FROM AdminManages WHERE book_id = ?', [bookId]);
    
    // Delete from ReadHistory
    await connection.query('DELETE FROM ReadHistory WHERE book_id = ?', [bookId]);
    
    // Delete from BookStatistics
    await connection.query('DELETE FROM BookStatistics WHERE book_id = ?', [bookId]);
    
    // Delete from BookCategories
    await connection.query('DELETE FROM BookCategories WHERE book_id = ?', [bookId]);
    
    // Finally delete from Books table
    await connection.query('DELETE FROM Books WHERE book_id = ?', [bookId]);

    await connection.commit();
    connection.release();

    // Delete files after successful database deletion
    if (bookRows.length > 0) {
      const book = bookRows[0];
      
      // Delete cover image
      if (book.cover_path) {
        const coverPath = path.join(coversDir, book.cover_path);
        if (fs.existsSync(coverPath)) {
          try {
            fs.unlinkSync(coverPath);
            console.log('Deleted cover file:', coverPath);
          } catch (fileError) {
            console.error('Error deleting cover file:', fileError);
          }
        }
      }
      
      // Delete PDF file
      if (book.file_path) {
        const pdfPath = path.join(pdfsDir, book.file_path);
        if (fs.existsSync(pdfPath)) {
          try {
            fs.unlinkSync(pdfPath);
            console.log('Deleted PDF file:', pdfPath);
          } catch (fileError) {
            console.error('Error deleting PDF file:', fileError);
          }
        }
      }
    }

    res.json({ success: true, message: "Book deleted successfully" });
  } catch (err) {
    // Rollback transaction on error
    if (connection) {
      try {
        await connection.rollback();
      } catch (rollbackError) {
        console.error('Error during rollback:', rollbackError);
      }
      connection.release();
    }
    console.error('Error deleting book:', err);
    res.status(500).json({ success: false, error: err.message || "Error deleting book" });
  }
});

const upload = multer({ storage: storage });


// Handle the form submission with multiple files or just filenames
app.post(
  '/addBook',
  upload.fields([{ name: 'cover', maxCount: 1 }, { name: 'pdf', maxCount: 1 }]),
  async (req, res) => {
      const {
          bookId,
          title,
          author,
          publisherId,
          categories,
          coverFilename,
          pdfFilename
      } = req.body;

      // Determine cover and PDF filenames
      const cover = coverFilename || (req.files && req.files.cover ? req.files.cover[0].filename : null);
      const pdf = pdfFilename || (req.files && req.files.pdf ? req.files.pdf[0].filename : null);
      
      // Log file information for debugging
      if (req.files) {
          if (req.files.cover && req.files.cover[0]) {
              console.log('Cover file uploaded:');
              console.log('  Original name:', req.files.cover[0].originalname);
              console.log('  Saved as:', req.files.cover[0].filename);
              console.log('  Saved to:', path.join(coversDir, req.files.cover[0].filename));
          }
          if (req.files.pdf && req.files.pdf[0]) {
              console.log('PDF file uploaded:');
              console.log('  Original name:', req.files.pdf[0].originalname);
              console.log('  Saved as:', req.files.pdf[0].filename);
              console.log('  Saved to:', path.join(pdfsDir, req.files.pdf[0].filename));
          }
      }

      let connection = null;
      let oldCoverPath = null;
      let oldPdfPath = null;
      
      try {
          connection = await pool.getConnection();
          await connection.beginTransaction();

          // Determine whether to use the provided bookId or generate a new one
          let generatedBookId;
          if (bookId && bookId !== 'NULL') {
              generatedBookId = bookId;
              
              // Get old file paths if updating existing book
              const [existingBook] = await connection.query(
                  'SELECT cover_path, file_path FROM Books WHERE book_id = ?',
                  [generatedBookId]
              );
              
              if (existingBook.length > 0) {
                  oldCoverPath = existingBook[0].cover_path;
                  oldPdfPath = existingBook[0].file_path;
              }
          } else {
              // Generate a new book_id
              const [maxResult] = await connection.query(
                  "SELECT MAX(CAST(SUBSTRING(book_id, 2) AS UNSIGNED)) AS maxId FROM Books"
              );
              const nextId = maxResult[0].maxId ? maxResult[0].maxId + 1 : 1;
              generatedBookId = `B${String(nextId).padStart(7, '0')}`;
          }

          // Insert or update the book information
          await connection.query(
              'CALL AddBook(?, ?, ?, ?, ?, ?)',
              [generatedBookId, title, author, publisherId, cover, pdf]
          );

          // Parse and update categories
          const categoryInput = JSON.parse(categories || '[]');
          
          // Convert category names to category IDs if needed
          // category_id is VARCHAR(5), so if we receive longer strings, they're likely category names
          let categoryIds = [];
          if (categoryInput.length > 0) {
              // Get all categories from database for name-to-ID mapping
              const [allCategories] = await connection.query('SELECT category_id, name FROM Categories');
              const categoryMap = new Map();
              allCategories.forEach(cat => {
                  categoryMap.set(cat.name, cat.category_id);
              });
              
              // Process each category input
              for (const item of categoryInput) {
                  if (typeof item === 'string') {
                      // Check if it looks like a category ID (VARCHAR(5) format like 'C0001')
                      if (item.length <= 5 && /^[A-Z0-9]+$/.test(item)) {
                          categoryIds.push(item);
                      } else {
                          // It's likely a category name, convert to ID using the map
                          const categoryId = categoryMap.get(item);
                          if (categoryId) {
                              categoryIds.push(categoryId);
                          } else {
                              console.warn(`Category name "${item}" not found, skipping...`);
                          }
                      }
                  }
              }
              
              // Remove duplicates
              categoryIds = [...new Set(categoryIds)];
          }
          
          // Delete all existing categories for this book first (only once)
          // This prevents lock timeout by doing the delete only once instead of in a loop
          await connection.query(
              'DELETE FROM BookCategories WHERE book_id = ?',
              [generatedBookId]
          );
          
          // Insert all new categories at once using bulk insert
          if (categoryIds.length > 0) {
              const categoryValues = categoryIds.map(catId => [generatedBookId, catId]);
              await connection.query(
                  'INSERT INTO BookCategories (book_id, category_id) VALUES ?',
                  [categoryValues]
              );
          }

          await connection.commit();
          connection.release();
          
          // Delete old files after successful commit (only if new files were uploaded)
          if (req.files) {
              if (req.files.cover && req.files.cover[0] && oldCoverPath) {
                  // Delete old cover file
                  const oldCoverFullPath = path.join(coversDir, oldCoverPath);
                  if (fs.existsSync(oldCoverFullPath)) {
                      try {
                          fs.unlinkSync(oldCoverFullPath);
                          console.log('Deleted old cover file:', oldCoverFullPath);
                      } catch (deleteError) {
                          console.error('Error deleting old cover file:', deleteError);
                      }
                  }
              }
              
              if (req.files.pdf && req.files.pdf[0] && oldPdfPath) {
                  // Delete old PDF file
                  const oldPdfFullPath = path.join(pdfsDir, oldPdfPath);
                  if (fs.existsSync(oldPdfFullPath)) {
                      try {
                          fs.unlinkSync(oldPdfFullPath);
                          console.log('Deleted old PDF file:', oldPdfFullPath);
                      } catch (deleteError) {
                          console.error('Error deleting old PDF file:', deleteError);
                      }
                  }
              }
          }
          
          res.status(200).json({ message: 'Book added or updated successfully', bookId: generatedBookId });
      } catch (error) {
          // Rollback transaction on error
          if (connection) {
              try {
                  await connection.rollback();
              } catch (rollbackError) {
                  console.error('Error during rollback:', rollbackError);
              }
              connection.release();
          }
          console.error('Error adding or updating book:', error);
          res.status(500).json({ error: 'Error adding or updating book: ' + error.message });
      }
  }
);

// Get Book Details
app.get("/getBookDetails", async (req, res) => {
    const { bookId, userId } = req.query;
  
    try {
      // Call the GetBookDetails stored procedure
      const [rows] = await pool.execute("CALL GetBookDetails(?, ?)", [bookId, userId]);
  
      // If no results, return an error
      if (rows.length === 0) {
        return res.status(404).json({ success: false, error: "Book not found" });
      }
  
      // Extract book details from the result
      const book = rows[0][0];
      
      // Get publisher_id separately since stored procedure doesn't return it
      const [publisherRows] = await pool.query(
        "SELECT publisher_id FROM Books WHERE book_id = ?",
        [bookId]
      );
      const publisherId = publisherRows.length > 0 ? publisherRows[0].publisher_id : null;
  
      // Format the response to match the expected structure for Svelte
      res.json({
        success: true,
        book: {
          title: book.title,
          author: book.author,
          pageCount: book.page_count,
          filePath: book.file_path,
          coverPath: book.cover_path,
          seriesName: book.series_name,
          seriesOrder: book.series_order,
          publicationType: book.publication_type,
          publisherId: publisherId,
          totalReaders: book.total_readers,
          totalFavorites: book.total_favorites,
          totalFollowers: book.total_followers,
          categories: book.categories ? book.categories.split(",") : [],
          description: book.description || "",
          totalTimeSpent: book.total_time_spent,
          lastReadPage: book.last_read_page,
          isFavorite: book.is_favorite,
        },
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: err.message });
    }
  });
  

// Get All Books
app.get("/getAllBooks", async (req, res) => {
  try {
    const [rows] = await pool.query(
      `SELECT 
        b.book_id,
        b.title,
        b.author,
        b.cover_path,
        GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') as categories,
        MIN(rh.read_date) as date_added
      FROM Books b
      LEFT JOIN BookCategories bc ON b.book_id = bc.book_id
      LEFT JOIN Categories c ON bc.category_id = c.category_id
      LEFT JOIN ReadHistory rh ON b.book_id = rh.book_id
      GROUP BY b.book_id, b.title, b.author, b.cover_path
      ORDER BY b.title ASC`
    );
    res.json({ success: true, books: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Search Books by title, author or id
app.get("/searchBooks", async (req, res) => {
  const { q } = req.query;
  const term = (q || "").trim();

  try {
    if (!term) {
      const [rows] = await pool.query(
        `SELECT 
          b.book_id,
          b.title,
          b.author,
          b.cover_path,
          GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') as categories,
          MIN(rh.read_date) as date_added
        FROM Books b
        LEFT JOIN BookCategories bc ON b.book_id = bc.book_id
        LEFT JOIN Categories c ON bc.category_id = c.category_id
        LEFT JOIN ReadHistory rh ON b.book_id = rh.book_id
        GROUP BY b.book_id, b.title, b.author, b.cover_path
        ORDER BY b.title ASC`
      );
      return res.json({ success: true, books: rows });
    }

    const like = `%${term}%`;
    const [rows] = await pool.query(
      `SELECT 
        b.book_id,
        b.title,
        b.author,
        b.cover_path,
        GROUP_CONCAT(DISTINCT c.name ORDER BY c.name SEPARATOR ', ') as categories,
        MIN(rh.read_date) as date_added
      FROM Books b
      LEFT JOIN BookCategories bc ON b.book_id = bc.book_id
      LEFT JOIN Categories c ON bc.category_id = c.category_id
      LEFT JOIN ReadHistory rh ON b.book_id = rh.book_id
      WHERE b.title LIKE ? OR b.author LIKE ? OR b.book_id LIKE ?
      GROUP BY b.book_id, b.title, b.author, b.cover_path
      ORDER BY b.title ASC`,
      [like, like, like]
    );

    res.json({ success: true, books: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: err.message });
  }
});

// Get User History
app.get("/user/history", async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    // Query to fetch user history from ReadHistory table, ordered by read_date DESC (newest first)
    const [rows] = await pool.query(
      `SELECT RH.user_id, RH.book_id, RH.read_date, RH.total_time_spent, RH.last_read_page, B.title, B.author, B.cover_path
       FROM ReadHistory RH 
       JOIN Books B ON RH.book_id = B.book_id
       WHERE RH.user_id = ?
       ORDER BY RH.read_date DESC, RH.last_read_page DESC`, 
      [userId]
    );

    res.json({ success: true, history: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Error fetching user history" });
  }
});

// Delete User History
app.delete("/user/history", async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    // Query to delete user history from ReadHistory table
    const [result] = await pool.query(
      "DELETE FROM ReadHistory WHERE user_id = ?", 
      [userId]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: "No history found for the given User ID" });
    }

    res.json({ success: true, message: "User history deleted successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Error deleting user history" });
  }
});
// Login endpoint
app.get("/login", async (req, res) => {
  const { username, password } = req.query;

  // Validate input
  if (!username || !password) {
      return res.status(400).json({ success: false, error: "Username and password are required" });
  }

  try {
      // Query the database to verify credentials
      const [rows] = await pool.query(
          "SELECT user_id, name, is_admin FROM Users WHERE account = ? AND password = ?",
          [username, password]
      );

      // If no matching user is found
      if (rows.length === 0) {
          return res.status(401).json({ success: false, error: "Invalid username or password" });
      }

      // Return username and user_id
      const user = rows[0];
      res.json({ success: true, username: user.name, userId: user.user_id, isAdmin: user.is_admin > 0 });
  } catch (err) {
      console.error(err);
      res.status(500).json({ success: false, error: "An error occurred during login" });
  }
});
// Update or Add Read History and Increment Book View Count
app.post('/updateReadHistory', async (req, res) => {
  const { userId, bookId, readDate, totalTimeSpent, lastReadPage } = req.query;

  // Validate input
  if (!userId || !bookId) {
    return res.status(400).json({ success: false, error: "User ID and Book ID are required" });
  }

  try {
    const connection = await pool.getConnection();
    await connection.beginTransaction();

    // Check if a read history entry already exists
    const [existingHistory] = await connection.query(
      "SELECT * FROM ReadHistory WHERE user_id = ? AND book_id = ?",
      [userId, bookId]
    );

    if (existingHistory.length > 0) {
      // Update the existing read history entry
      await connection.query(
        `UPDATE ReadHistory 
         SET read_date = ?, total_time_spent = ?, last_read_page = ?
         WHERE user_id = ? AND book_id = ?`,
        [readDate || new Date(), totalTimeSpent || 0, lastReadPage || 0, userId, bookId]
      );
    } else {
      // Insert a new read history entry
      await connection.query(
        `INSERT INTO ReadHistory (user_id, book_id, read_date, total_time_spent, last_read_page)
         VALUES (?, ?, ?, ?, ?)`,
        [userId, bookId, readDate || new Date(), totalTimeSpent || 0, lastReadPage || 0]
      );
    }

    // Increment the book's total readers count in BookStatistics
    await connection.query(
      `UPDATE BookStatistics 
       SET total_readers = total_readers + 1
       WHERE book_id = ?`,
      [bookId]
    );

    await connection.commit();
    connection.release();

    res.status(200).json({ success: true, message: "Read history updated and book view count incremented" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Error updating read history and book view count" });
  }
});
// Toggle Favorite (Add/Remove book from favorites)
app.post("/toggleFavorite", async (req, res) => {
  const { userId, bookId } = req.body;

  console.log('toggleFavorite called with:', { userId, bookId });

  if (!userId || !bookId) {
    console.log('Missing userId or bookId');
    return res.status(400).json({ success: false, error: "User ID and Book ID are required" });
  }

  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    // Get or create user's favorite list
    let [favoriteLists] = await connection.query(
      "SELECT favorite_id FROM FavoriteLists WHERE user_id = ?",
      [userId]
    );

    console.log('Found favorite lists:', favoriteLists);

    let favoriteId;
    if (favoriteLists.length === 0) {
      // Create favorite list for the user if it doesn't exist
      // Get the maximum favorite_id to generate a new one
      const [maxFavoriteIdRows] = await connection.query(
        "SELECT COALESCE(MAX(CAST(SUBSTRING(favorite_id, 2) AS UNSIGNED)), 0) as max_id FROM FavoriteLists WHERE favorite_id LIKE 'F%'"
      );

      const maxFavoriteId = maxFavoriteIdRows && maxFavoriteIdRows[0] ? (maxFavoriteIdRows[0].max_id || 0) : 0;
      const nextId = maxFavoriteId + 1;
      favoriteId = `F${String(nextId).padStart(7, '0')}`;

      console.log(`Creating new favorite list: ${favoriteId} for user: ${userId}`);
      
      await connection.query(
        "INSERT INTO FavoriteLists (favorite_id, user_id) VALUES (?, ?)",
        [favoriteId, userId]
      );
      
      console.log(`Successfully created favorite list: ${favoriteId}`);
    } else {
      favoriteId = favoriteLists[0].favorite_id;
      console.log(`Using existing favorite list: ${favoriteId}`);
    }

    // Check if book is already in favorites
    const [existingFavorites] = await connection.query(
      "SELECT * FROM FavoriteListBooks WHERE favorite_id = ? AND book_id = ?",
      [favoriteId, bookId]
    );

    console.log('Existing favorites check:', existingFavorites);

    let isFavorite = false;

    if (existingFavorites.length > 0) {
      // Remove from favorites
      console.log(`Removing book ${bookId} from favorites`);
      await connection.query(
        "DELETE FROM FavoriteListBooks WHERE favorite_id = ? AND book_id = ?",
        [favoriteId, bookId]
      );
      
      // Decrement total_favorites in BookStatistics
      await connection.query(
        `UPDATE BookStatistics 
         SET total_favorites = GREATEST(total_favorites - 1, 0)
         WHERE book_id = ?`,
        [bookId]
      );
      
      isFavorite = false;
      console.log(`Book ${bookId} removed from favorites`);
    } else {
      // Add to favorites
      console.log(`Adding book ${bookId} to favorites`);
      await connection.query(
        "INSERT INTO FavoriteListBooks (favorite_id, book_id) VALUES (?, ?)",
        [favoriteId, bookId]
      );
      
      // Check if BookStatistics record exists for this book
      const [existingStats] = await connection.query(
        "SELECT stats_id FROM BookStatistics WHERE book_id = ?",
        [bookId]
      );

      if (existingStats.length === 0) {
        // Generate new stats_id if record doesn't exist
        const [maxStatsIdRows] = await connection.query(
          "SELECT COALESCE(MAX(CAST(SUBSTRING(stats_id, 2) AS UNSIGNED)), 0) as max_id FROM BookStatistics WHERE stats_id LIKE 'S%'"
        );

        const maxStatsId = maxStatsIdRows && maxStatsIdRows[0] ? (maxStatsIdRows[0].max_id || 0) : 0;
        const nextStatsId = maxStatsId + 1;
        const statsId = `S${String(nextStatsId).padStart(4, '0')}`;

        await connection.query(
          "INSERT INTO BookStatistics (stats_id, book_id, total_readers, total_favorites) VALUES (?, ?, 0, 1)",
          [statsId, bookId]
        );
        console.log(`Created new BookStatistics record: ${statsId} for book: ${bookId}`);
      } else {
        // Update existing record
        await connection.query(
          "UPDATE BookStatistics SET total_favorites = total_favorites + 1 WHERE book_id = ?",
          [bookId]
        );
        console.log(`Updated existing BookStatistics for book: ${bookId}`);
      }
      
      isFavorite = true;
      console.log(`Book ${bookId} added to favorites`);
    }

    await connection.commit();
    connection.release();

    console.log('Successfully toggled favorite, returning:', { success: true, isFavorite });
    res.json({ success: true, isFavorite: isFavorite });
  } catch (err) {
    await connection.rollback();
    connection.release();
    console.error('Error in toggleFavorite:', err);
    res.status(500).json({ success: false, error: err.message || "Error toggling favorite" });
  }
});

// Get User Favorites
app.get("/getUserFavorites", async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    const [rows] = await pool.query(
      `SELECT 
        b.book_id, 
        b.title, 
        b.author, 
        b.cover_path,
        COALESCE(bs.total_favorites, 0) as total_favorites
       FROM Books b
       JOIN FavoriteListBooks flb ON b.book_id = flb.book_id
       JOIN FavoriteLists fl ON flb.favorite_id = fl.favorite_id
       LEFT JOIN BookStatistics bs ON b.book_id = bs.book_id
       WHERE fl.user_id = ?
       ORDER BY bs.total_favorites DESC, b.title ASC`,
      [userId]
    );

    res.json({ success: true, books: rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Error fetching user favorites" });
  }
});

// Get User Statistics
app.get("/getUserStats", async (req, res) => {
  const { userId } = req.query;

  if (!userId) {
    return res.status(400).json({ success: false, error: "User ID is required" });
  }

  try {
    // Count distinct books read from ReadHistory
    const [readBooksRows] = await pool.query(
      `SELECT COUNT(DISTINCT book_id) as booksRead
       FROM ReadHistory
       WHERE user_id = ?`,
      [userId]
    );

    // Count distinct books in favorites from FavoriteListBooks
    const [favoritesRows] = await pool.query(
      `SELECT COUNT(DISTINCT flb.book_id) as favoritesCount
       FROM FavoriteListBooks flb
       JOIN FavoriteLists fl ON flb.favorite_id = fl.favorite_id
       WHERE fl.user_id = ?`,
      [userId]
    );

    const booksRead = readBooksRows[0]?.booksRead || 0;
    const favoritesCount = favoritesRows[0]?.favoritesCount || 0;

    res.json({
      success: true,
      stats: {
        booksRead,
        favoritesCount
      }
    });
  } catch (err) {
    console.error("Error fetching user stats:", err);
    res.status(500).json({ success: false, error: "Error fetching user statistics" });
  }
});

// Register endpoint
app.post("/register", async (req, res) => {
  const { account, password, name } = req.body;

  console.log('Register called with:', { account, name });

  // Validate input
  if (!account || !password || !name) {
    return res.status(400).json({ success: false, error: "Tên đăng nhập, mật khẩu và tên hiển thị là bắt buộc" });
  }

  if (account.trim().length < 3) {
    return res.status(400).json({ success: false, error: "Tên đăng nhập phải có ít nhất 3 ký tự" });
  }

  if (password.length < 6) {
    return res.status(400).json({ success: false, error: "Mật khẩu phải có ít nhất 6 ký tự" });
  }

  if (name.trim().length < 2) {
    return res.status(400).json({ success: false, error: "Tên hiển thị phải có ít nhất 2 ký tự" });
  }

  const connection = await pool.getConnection();
  
  try {
    await connection.beginTransaction();

    // Check if account already exists
    const [existingUsers] = await connection.query(
      "SELECT user_id FROM Users WHERE account = ?",
      [account.trim()]
    );

    if (existingUsers.length > 0) {
      await connection.rollback();
      connection.release();
      return res.status(400).json({ success: false, error: "Tên đăng nhập đã tồn tại" });
    }

    // Generate new user_id
    const [maxUserIdRows] = await connection.query(
      "SELECT COALESCE(MAX(CAST(SUBSTRING(user_id, 2) AS UNSIGNED)), 0) as max_id FROM Users WHERE user_id LIKE 'U%'"
    );

    const maxUserId = maxUserIdRows && maxUserIdRows[0] ? (maxUserIdRows[0].max_id || 0) : 0;
    const nextUserId = maxUserId + 1;
    const userId = `U${String(nextUserId).padStart(7, '0')}`;

    // Generate new favorite_id
    const [maxFavoriteIdRows] = await connection.query(
      "SELECT COALESCE(MAX(CAST(SUBSTRING(favorite_id, 2) AS UNSIGNED)), 0) as max_id FROM FavoriteLists WHERE favorite_id LIKE 'F%'"
    );

    const maxFavoriteId = maxFavoriteIdRows && maxFavoriteIdRows[0] ? (maxFavoriteIdRows[0].max_id || 0) : 0;
    const nextFavoriteId = maxFavoriteId + 1;
    const favoriteId = `F${String(nextFavoriteId).padStart(7, '0')}`;

    console.log(`Creating new user: ${userId} with favorite list: ${favoriteId}`);

    // Insert new user
    await connection.query(
      "INSERT INTO Users (user_id, name, join_date, account, password, is_admin) VALUES (?, ?, CURDATE(), ?, ?, 0)",
      [userId, name.trim(), account.trim(), password]
    );

    // Create favorite list for the new user
    await connection.query(
      "INSERT INTO FavoriteLists (favorite_id, user_id) VALUES (?, ?)",
      [favoriteId, userId]
    );

    await connection.commit();
    connection.release();

    console.log(`Successfully registered user: ${userId}`);
    res.json({ success: true, message: "Đăng ký thành công" });
  } catch (err) {
    await connection.rollback();
    connection.release();
    console.error("Error in register:", err);
    res.status(500).json({ success: false, error: "Đã xảy ra lỗi khi đăng ký. Vui lòng thử lại." });
  }
});

// Update Username
app.get("/updateUsername", async (req, res) => {
  const { userId, newName } = req.query;

  // Validate input
  if (!userId || !newName) {
    return res.status(400).json({ success: false, error: "User ID and new name are required" });
  }

  try {
    // Update the username in the database
    const [result] = await pool.query(
      "UPDATE Users SET name = ? WHERE user_id = ?",
      [newName, userId]
    );

    // Check if any rows were affected
    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, error: "User not found" });
    }

    res.json({ success: true, message: "Username updated successfully" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: "Error updating username" });
  }
});

/*
// Start the server
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
*/

const PORT = 3000;
async function start() {
  try {
    const conn = await pool.getConnection();
    await conn.ping();           // test kết nối
    conn.release();
    console.log("✅ Connected to MySQL");
    
    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (err) {
    console.error("❌ Cannot connect to MySQL:", err.message);
    process.exit(1);             // dừng server nếu không kết nối được
  }
}

start();