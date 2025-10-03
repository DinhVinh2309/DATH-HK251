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
    CONSTRAINT chk_total_read_days CHECK (total_read_days >= 0)
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

