DROP database bkbooks;
CREATE database bkbooks;
USE bkbooks;

-- Users table
CREATE TABLE Users (
    user_id VARCHAR(8) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    join_date DATE,
    total_read_days INT DEFAULT 0,
    account VARCHAR(50),
    password VARCHAR(50),
    purpose VARCHAR(100),
    CONSTRAINT chk_total_read_days CHECK (total_read_days >= 0),
    is_admin INT DEFAULT 0
);
-- Admins table
CREATE TABLE Admins (
    admin_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    email VARCHAR(100) UNIQUE NOT NULL,
    base_salary DECIMAL(10, 2) CHECK (base_salary > 0),
    book_count INT DEFAULT 0,
    category_count INT DEFAULT 0,
    notification_count INT DEFAULT 0
);

-- Publishers table
CREATE TABLE Publishers (
    publisher_id VARCHAR(5) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Books table
CREATE TABLE Books (
    book_id VARCHAR(8) PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(100) NOT NULL,
    page_count INT CHECK (page_count > 0),
    file_path VARCHAR(200),
    cover_path VARCHAR(200),
    series_name VARCHAR(200),
    series_order INT,
    publication_type VARCHAR(50),
    publisher_id VARCHAR(5) NOT NULL,
    FOREIGN KEY (publisher_id) REFERENCES Publishers(publisher_id)
);


-- Categories table
CREATE TABLE Categories (
    category_id VARCHAR(5) PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- FavoriteLists table
CREATE TABLE FavoriteLists (
    favorite_id VARCHAR(8) PRIMARY KEY,
    user_id VARCHAR(8) NOT NULL,
    FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- FavoriteListBooks table
CREATE TABLE FavoriteListBooks (
    favorite_id VARCHAR(8),
    book_id VARCHAR(8),
    PRIMARY KEY (favorite_id, book_id),
    FOREIGN KEY (favorite_id) REFERENCES FavoriteLists(favorite_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- BookCategories table
CREATE TABLE BookCategories (
    book_id VARCHAR(8),
    category_id VARCHAR(5),
    PRIMARY KEY (book_id, category_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- Notifications table
CREATE TABLE Notifications (
    notification_id BIGINT PRIMARY KEY,
    content VARCHAR(1000) NOT NULL,
    send_date DATE,
    is_limited CHAR(1) CHECK (is_limited IN ('Y', 'N')),
    admin_id INT NOT NULL,
    FOREIGN KEY (admin_id) REFERENCES Admins(admin_id)
);

-- BookStatistics table
CREATE TABLE BookStatistics (
    stats_id VARCHAR(10) PRIMARY KEY,
    book_id VARCHAR(8) UNIQUE NOT NULL,
    total_readers INT DEFAULT 0,
    total_favorites INT DEFAULT 0,
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- ReadHistory table
CREATE TABLE ReadHistory (
    user_id VARCHAR(8),
    book_id VARCHAR(8),
    read_date DATE,
    total_time_spent INT CHECK (total_time_spent >= 0),
    last_read_page INT CHECK (last_read_page >= 0),
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- AdminManages table
CREATE TABLE AdminManages (
    admin_id INT,
    book_id VARCHAR(8),
    PRIMARY KEY (admin_id, book_id),
    FOREIGN KEY (admin_id) REFERENCES Admins(admin_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id)
);

-- AdminCategories table
CREATE TABLE AdminCategories (
    admin_id INT,
    category_id VARCHAR(5),
    PRIMARY KEY (admin_id, category_id),
    FOREIGN KEY (admin_id) REFERENCES Admins(admin_id),
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- Insert initial data
-- INSERT INTO Users (user_id, name, join_date, total_read_days, account, password) VALUES 
-- ('U0000001', 'Nguyen Van A', '2024-01-15', 10, 'nguyena', '123456'),
-- ('U0000002', 'Le Thi B', '2024-02-20', 5, 'lethib', 'abcdef'),
-- ('U0000003', 'Tran Van C', '2024-03-10', 2, NULL, NULL);

-- INSERT INTO Admins (admin_id, name, start_date, email, base_salary, book_count, category_count, notification_count) VALUES 
-- (1001, 'Admin 1', '2023-12-01', 'admin1@example.com', 1500, 5, 2, 10),
-- (1002, 'Admin 2', '2024-01-10', 'admin2@example.com', 1600, 3, 1, 5);

-- INSERT INTO Publishers VALUES 
-- ('P0001', 'NXB Tre', 'nxbtre@example.com'),
-- ('P0002', 'NXB Kim Dong', 'kimdong@example.com');

-- INSERT INTO Books VALUES 
-- ('B0000001', 'Cuon sach 1', 'Tac Gia A', 300, '/files/book1.pdf', NULL, NULL, NULL, 'P0001'),
-- ('B0000002', 'Cuon sach 2', 'Tac Gia B', 250, '/files/book2.pdf', 'Bo 1', 1, NULL, 'P0002');

-- INSERT INTO Categories VALUES 
-- ('C0001', 'Khoa hoc'),
-- ('C0002', 'Kinh di');

-- INSERT INTO Notifications VALUES 
-- (100000000000000001, 'Chao mung nguoi dung moi', '2024-01-01', 'Y', 1001),
-- (100000000000000002, 'Thong bao cap nhat sach', '2024-01-02', 'N', 1002);

-- INSERT INTO BookStatistics VALUES 
-- ('S0001', 'B0000001', 100, 50),
-- ('S0002', 'B0000002', 80, 30);

-- INSERT INTO ReadHistory VALUES 
-- ('U0000001', 'B0000001', '2024-01-01', 120, 50),
-- ('U0000002', 'B0000002', '2024-01-02', 90, 25);

-- -- @block
-- SELECT * FROM books

INSERT INTO Users VALUES ('U0000001', 'Nguyen Van A', '2024-01-15',  10, 'nguyena', '123456', NULL, 1);
INSERT INTO Users VALUES ('U0000002', 'Le Thi B', '2024-02-20',  5, 'lethib', 'abcdef', NULL, 0);
INSERT INTO Users VALUES ('U0000003', 'Tran Van C', '2024-03-10',  2, NULL, NULL, 'Reading Books', 0);
INSERT INTO Users VALUES ('U0000004', 'Tran Quang Thien', '2024-05-23',  2, NULL, NULL, 'Buy Books', 0);
INSERT INTO Users VALUES ('U0000005', 'Pham Minh D', '2024-04-01',  8, 'phamminhd', 'password123', NULL, 0);
INSERT INTO Users VALUES ('U0000006', 'Vo Thi E', '2024-03-15',  4, 'vothie', 'password456', NULL, 0);
INSERT INTO Users VALUES ('U0000007', 'Hoang Van F', '2024-04-20',  6, NULL, NULL, 'Borrow Books', 0);
INSERT INTO Users VALUES ('U0000008', 'Le Quang G', '2024-05-10',  10, 'lequangg', 'securepass', NULL, 0);
INSERT INTO Users VALUES ('U0000009', 'Nguyen Thi H', '2024-02-25',  3, NULL, NULL, 'Study Materials', 0);
INSERT INTO Users VALUES ('U0000010', 'Tran Van I', '2024-04-18',  7, 'tranvani', 'mypassword', NULL, 0);
INSERT INTO Users VALUES ('U0000011', 'Nguyen Anh J', '2024-03-10',  2, NULL, NULL, 'Explore Books', 0);
INSERT INTO Users VALUES ('U0000012', 'Pham Thi K', '2024-05-05',  9, 'phamthik', 'abc12345', NULL, 0);


INSERT INTO Admins VALUES (1001, 'Admin 1', '2023-12-01',  'admin1@example.com', 1500, 5, 2, 10);
INSERT INTO Admins VALUES (1002, 'Admin 2', '2024-01-10',  'admin2@example.com', 1600, 3, 1, 5);
INSERT INTO Admins VALUES (1003, 'Admin 3', '2024-02-01',  'admin3@example.com', 1700, 7, 3, 12);
INSERT INTO Admins VALUES (1004, 'Admin 4', '2024-03-15',  'admin4@example.com', 1800, 10, 4, 20);
INSERT INTO Admins VALUES (1005, 'Admin 5', '2024-04-01',  'admin5@example.com', 2000, 15, 6, 25);


INSERT INTO Publishers VALUES ('P0001', 'NXB Tre', 'nxbtre@example.com');
INSERT INTO Publishers VALUES ('P0002', 'NXB Kim Dong', 'kimdong@example.com');
INSERT INTO Publishers VALUES ('P0003', 'NXB Giao Duc', 'giaoduc@example.com');
INSERT INTO Publishers VALUES ('P0004', 'NXB Thanh Nien', 'thanhnien@example.com');
INSERT INTO Publishers VALUES ('P0005', 'NXB Y Hoc', 'yhoc@example.com');
INSERT INTO Publishers VALUES ('P0006', 'NXB Cong Nghe', 'congnghe@example.com');
INSERT INTO Publishers VALUES ('P0007', 'NXB Nong Nghiep', 'nongnghiep@example.com');
INSERT INTO Publishers VALUES ('P0008', 'NXB Tam Ly', 'tamly@example.com');
-- INSERT INTO Publishers VALUES ('P0009', 'NXB Giao Duc', 'giaoduc@example.com');



INSERT INTO Books VALUES ('B0000001', 'Cuon sach 1', 'Tac Gia A', 300, '/files/book1.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, NULL, 'P0001');
INSERT INTO Books VALUES ('B0000002', 'Cuon sach 2', 'Tac Gia B', 250, '/files/book2.pdf','cover-1734099546474-646294659.jpg', 'Bo 1', 1, NULL, 'P0002');
INSERT INTO Books VALUES ('B0000003', 'Cuon sach 3', 'Tac Gia C', 320, '/files/book3.pdf','cover-1734099546474-646294659.jpg', 'Bo 2', 1, NULL, 'P0003');
INSERT INTO Books VALUES ('B0000004', 'Cuon sach 4', 'Tac Gia D', 200, '/files/book4.pdf','cover-1734099546474-646294659.jpg', 'Bo 2', 2, NULL, 'P0004');
INSERT INTO Books VALUES ('B0000005', 'Cuon sach 5', 'Tac Gia E', 280, '/files/book5.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, NULL, 'P0001');
INSERT INTO Books VALUES ('B0000006', 'Cuon sach 6', 'Tac Gia F', 310, '/files/book6.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, 'Ebook', 'P0002');
INSERT INTO Books VALUES ('B0000007', 'Cuon sach 7', 'Tac Gia G', 250, '/files/book7.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, 'Ebook', 'P0003');
INSERT INTO Books VALUES ('B0000008', 'Cuon sach 8', 'Tac Gia H', 300, '/files/book8.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, NULL, 'P0001');
INSERT INTO Books VALUES ('B0000009', 'Cuon sach 9', 'Tac Gia I', 280, '/files/book9.pdf','cover-1734099546474-646294659.jpg', 'Bo 3', 1, NULL, 'P0002');
INSERT INTO Books VALUES ('B0000010', 'Cuon sach 10', 'Tac Gia J', 350, '/files/book10.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, 'Ebook', 'P0003');
INSERT INTO Books VALUES ('B0000011', 'Cuon sach 11', 'Tac Gia K', 400, '/files/book11.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, NULL, 'P0004');
INSERT INTO Books VALUES ('B0000012', 'Cuon sach 12', 'Tac Gia L', 220, '/files/book12.pdf','cover-1734099546474-646294659.jpg', NULL, NULL, 'Ebook', 'P0001');



INSERT INTO Categories VALUES ('C0001', 'Khoa hoc');
INSERT INTO Categories VALUES ('C0002', 'Kinh di');
INSERT INTO Categories VALUES ('C0003', 'Van hoc');
INSERT INTO Categories VALUES ('C0004', 'Lich su');
INSERT INTO Categories VALUES ('C0005', 'Thieu nhi');
INSERT INTO Categories VALUES ('C0006', 'Cong nghe');
INSERT INTO Categories VALUES ('C0007', 'Tam ly');
INSERT INTO Categories VALUES ('C0008', 'Giao duc');
INSERT INTO Categories VALUES ('C0009', 'Trinh tham');
INSERT INTO Categories VALUES ('C0010', 'Y hoc');


INSERT INTO Notifications VALUES (100000000000000001, 'Chao mung nguoi dung moi', '2024-1-1', 'Y', 1001);
INSERT INTO Notifications VALUES (100000000000000002, 'Thong bao cap nhat sach', '2024-1-1', 'N', 1002);
INSERT INTO Notifications VALUES (100000000000000003, 'Thong bao mo khoa hoc moi', '2024-1-1', 'Y', 1003);
INSERT INTO Notifications VALUES (100000000000000004, 'Cap nhat he thong doc sach', '2024-1-1', 'N', 1004);
INSERT INTO Notifications VALUES (100000000000000005, 'Thong bao giam gia thang 6', '2024-1-1', 'N', 1003);
INSERT INTO Notifications VALUES (100000000000000006, 'Cap nhat danh muc sach moi', '2024-1-1', 'Y', 1004);
INSERT INTO Notifications VALUES (100000000000000007, 'Su kien ra mat tac gia moi', '2024-1-1', 'N', 1005);
INSERT INTO Notifications VALUES (100000000000000008, 'Thong bao nghi le', '2024-1-1', 'Y', 1001);
INSERT INTO Notifications VALUES (100000000000000009, 'Su kien thang doc sach', '2024-1-1', 'Y', 1002);



INSERT INTO BookStatistics VALUES ('S0001', 'B0000001', 100, 50);
INSERT INTO BookStatistics VALUES ('S0002', 'B0000002', 80, 30);
INSERT INTO BookStatistics VALUES ('S0006', 'B0000008', 120, 60);
INSERT INTO BookStatistics VALUES ('S0007', 'B0000009', 150, 80);
INSERT INTO BookStatistics VALUES ('S0008', 'B0000010', 200, 100);
INSERT INTO BookStatistics VALUES ('S0009', 'B0000011', 180, 90);
INSERT INTO BookStatistics VALUES ('S0010', 'B0000012', 250, 120);


INSERT INTO ReadHistory VALUES ('U0000001', 'B0000001', '2024-01-01', 120, 50);
INSERT INTO ReadHistory VALUES ('U0000002', 'B0000002', '2024-01-01', 90, 25);
INSERT INTO ReadHistory VALUES ('U0000005', 'B0000003', '2024-01-01', 200, 100);
INSERT INTO ReadHistory VALUES ('U0000006', 'B0000004', '2024-01-01', 150, 80);
INSERT INTO ReadHistory VALUES ('U0000007', 'B0000005', '2024-01-01', 180, 90);
INSERT INTO ReadHistory VALUES ('U0000008', 'B0000006', '2024-01-01', 220, 110);
INSERT INTO ReadHistory VALUES ('U0000009', 'B0000008', '2024-01-01', 150, 75);
INSERT INTO ReadHistory VALUES ('U0000010', 'B0000009', '2024-01-01', 200, 120);
INSERT INTO ReadHistory VALUES ('U0000011', 'B0000010', '2024-01-01', 180, 90);
INSERT INTO ReadHistory VALUES ('U0000012', 'B0000011', '2024-01-01', 240, 160);
INSERT INTO ReadHistory VALUES ('U0000005', 'B0000012', '2024-01-01', 300, 150);

DELIMITER //

DROP PROCEDURE IF EXISTS GetAllBooks//
CREATE PROCEDURE GetAllBooks()
BEGIN
    SELECT book_id, title, author, cover_path FROM Books;
END//

DROP PROCEDURE IF EXISTS GetAllCategories//
CREATE PROCEDURE GetAllCategories()
BEGIN
    SELECT * FROM Categories;
END//

DROP PROCEDURE IF EXISTS AddBook//
CREATE PROCEDURE AddBook(
    IN p_bookId VARCHAR(8),
    IN p_title VARCHAR(200),
    IN p_author VARCHAR(100),
    IN p_publisherId VARCHAR(5),
    IN p_cover VARCHAR(200),
    IN p_path VARCHAR(200)
)
BEGIN
    INSERT INTO Books (book_id, title, author, publisher_id, cover_path, file_path)
    VALUES (p_bookId, p_title, p_author, p_publisherId, p_cover, p_path)
    ON DUPLICATE KEY UPDATE
        title = VALUES(title),
        author = VALUES(author),
        publisher_id = VALUES(publisher_id),
        cover_path = VALUES(cover_path),
        file_path = VALUES(file_path);
END//

DROP PROCEDURE IF EXISTS AddBookCategory//
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
END//

DROP PROCEDURE IF EXISTS GetBookDetails//
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
END//

DELIMITER ;

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

DELIMITER //

DROP PROCEDURE IF EXISTS DeleteBook//

CREATE PROCEDURE DeleteBook(IN bookID VARCHAR(8))
BEGIN
    -- Delete entries from ReadHistory table
    DELETE FROM ReadHistory WHERE book_id = bookID;

    -- Delete entries from BookStatistics table
    DELETE FROM BookStatistics WHERE book_id = bookID;

    -- Delete entries from BookCategories table
    DELETE FROM BookCategories WHERE book_id = bookID;

    -- Delete the book from the Books table
    DELETE FROM Books WHERE book_id = bookID;
END//

DELIMITER ;