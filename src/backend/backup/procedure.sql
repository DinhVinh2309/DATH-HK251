
DROP PROCEDURE IF EXISTS GetAllBooks;
CREATE PROCEDURE GetAllBooks()
BEGIN
    SELECT book_id, title, author, cover_path FROM Books;
END;


CREATE PROCEDURE GetAllCategories()
BEGIN
    SELECT * FROM Categories;
END;


DROP PROCEDURE IF EXISTS AddBook;
CREATE PROCEDURE AddBook(
    IN p_bookId VARCHAR(8),
    IN p_title VARCHAR(200),
    IN p_author VARCHAR(100),
    IN p_publisherId VARCHAR(5),
    IN p_cover VARCHAR(200),
    IN p_path VARCHAR(200)
)
BEGIN
    INSERT INTO books (book_id, title, author, publisher_id, cover_path, file_path)
    VALUES (p_bookId, p_title, p_author, p_publisherId, p_cover, p_path)
    ON DUPLICATE KEY UPDATE
        title = VALUES(title),
        author = VALUES(author),
        publisher_id = VALUES(publisher_id),
        cover_path = VALUES(cover_path),
        file_path = VALUES(file_path);
END;




DROP PROCEDURE IF EXISTS AddBookCategory;
CREATE PROCEDURE AddBookCategory(
    IN p_bookId VARCHAR(8),
    IN p_categoryId VARCHAR(5)
)
BEGIN
    -- Delete all existing categories associated with the given book_id
    DELETE FROM BookCategories
    WHERE book_id = p_bookId;

    -- Insert the new category
    INSERT INTO BookCategories (book_id, category_id)
    VALUES (p_bookId, p_categoryId);
END;


DROP PROCEDURE IF EXISTS GetBookDetails;
CREATE PROCEDURE GetBookDetails(
    IN p_book_id VARCHAR(8),
    IN p_user_id VARCHAR(8)
)
BEGIN
    -- Declare variables for the result
    DECLARE book_title VARCHAR(200);
    DECLARE book_author VARCHAR(100);
    DECLARE book_page_count INT;
    DECLARE book_file_path VARCHAR(200);
    DECLARE book_cover_path VARCHAR(200);
    DECLARE book_series_name VARCHAR(200);
    DECLARE book_series_order INT;
    DECLARE book_publication_type VARCHAR(50);
    DECLARE book_fav_count INT;
    DECLARE book_view_count INT;
    DECLARE book_follow_count INT;
    DECLARE book_desc TEXT;
    DECLARE total_time_spent INT DEFAULT 0;
    DECLARE last_read_page INT DEFAULT 0;
    DECLARE is_favorite INT DEFAULT 0;
    DECLARE categories TEXT;

    -- Get book details
    SELECT 
        b.title, 
        b.author, 
        b.page_count, 
        b.file_path, 
        b.cover_path, 
        b.series_name, 
        b.series_order, 
        b.publication_type
    INTO 
        book_title, 
        book_author, 
        book_page_count, 
        book_file_path, 
        book_cover_path, 
        book_series_name, 
        book_series_order, 
        book_publication_type
    FROM Books b
    WHERE b.book_id = p_book_id;

    -- Get book statistics
    SELECT 
        bs.total_readers, 
        bs.total_favorites
    INTO 
        book_fav_count, 
        book_view_count
    FROM BookStatistics bs
    WHERE bs.book_id = p_book_id;

    -- Get the count of followers (can be used as follows: total_followers)
    SELECT COUNT(DISTINCT u.user_id) INTO book_follow_count
    FROM ReadHistory rh
    JOIN Users u ON u.user_id = rh.user_id
    WHERE rh.book_id = p_book_id;

    -- Get categories
    SET categories = (SELECT GROUP_CONCAT(c.name) 
                       FROM Categories c
                       JOIN BookCategories bc ON bc.category_id = c.category_id
                       WHERE bc.book_id = p_book_id);
    
    -- Get user specific read history and favorite status
    SELECT 
        rh.total_time_spent, 
        rh.last_read_page
    INTO 
        total_time_spent, 
        last_read_page
    FROM ReadHistory rh
    WHERE rh.book_id = p_book_id AND rh.user_id = p_user_id;
    
    -- Check if the book is in the user's favorite list
    SELECT COUNT(*) 
    INTO is_favorite
    FROM FavoriteListBooks flb
    JOIN FavoriteLists fl ON fl.favorite_id = flb.favorite_id
    WHERE fl.user_id = p_user_id AND flb.book_id = p_book_id;

    -- Prepare the result
    SELECT 
        book_title AS title,
        book_author AS author,
        book_page_count AS page_count,
        book_file_path AS file_path,
        book_cover_path AS cover_path,
        book_series_name AS series_name,
        book_series_order AS series_order,
        book_publication_type AS publication_type,
        book_fav_count AS total_readers,
        book_fav_count AS total_favorites, 
        book_follow_count AS total_followers,
        categories AS categories,
        book_desc AS description,
        total_time_spent AS total_time_spent,
        last_read_page AS last_read_page,
        IF(is_favorite > 0, TRUE, FALSE) AS is_favorite;
END;



-- DROP TRIGGER IF EXISTS GenerateBookId;

-- CREATE TRIGGER GenerateBookId
-- BEFORE INSERT ON Books
-- FOR EACH ROW
-- BEGIN
--     DECLARE max_id INT;

--     -- Check for null or empty book_id
--     IF NEW.book_id="NULL" THEN
--         -- Get the current maximum numeric part of book_id
--         SELECT MAX(CAST(SUBSTRING(book_id, 2) AS UNSIGNED)) INTO max_id FROM Books;

--         -- Generate the new book_id
--         SET NEW.book_id = CONCAT('B', LPAD(IFNULL(max_id, 0) + 1, 7, '0'));
--     END IF;
-- END;


DROP PROCEDURE IF EXISTS deleteBook;

CREATE PROCEDURE deleteBook(IN bookID VARCHAR(8))
BEGIN
    -- Delete entries from ReadHistory table
    DELETE FROM readhistory WHERE book_id = bookID;

    -- Delete entries from BookStatistics table
    DELETE FROM bookstatistics WHERE book_id = bookID;

    -- Delete entries from BookCategories table
    DELETE FROM BookCategories WHERE book_id = bookID;

    -- Delete the book from the Books table
    DELETE FROM Books WHERE book_id = bookID;
END;


