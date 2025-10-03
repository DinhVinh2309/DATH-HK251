INSERT INTO Users VALUES ('U0000001', 'Nguyen Van A', '2024-01-15',  10, 'nguyena', '123456', NULL);
INSERT INTO Users VALUES ('U0000002', 'Le Thi B', '2024-02-20',  5, 'lethib', 'abcdef', NULL);
INSERT INTO Users VALUES ('U0000003', 'Tran Van C', '2024-03-10',  2, NULL, NULL, 'Reading Books');
INSERT INTO Users VALUES ('U0000004', 'Tran Quang Thien', '2024-05-23',  2, NULL, NULL, 'Buy Books');
INSERT INTO Users VALUES ('U0000005', 'Pham Minh D', '2024-04-01',  8, 'phamminhd', 'password123', NULL);
INSERT INTO Users VALUES ('U0000006', 'Vo Thi E', '2024-03-15',  4, 'vothie', 'password456', NULL);
INSERT INTO Users VALUES ('U0000007', 'Hoang Van F', '2024-04-20',  6, NULL, NULL, 'Borrow Books');
INSERT INTO Users VALUES ('U0000008', 'Le Quang G', '2024-05-10',  10, 'lequangg', 'securepass', NULL);
INSERT INTO Users VALUES ('U0000009', 'Nguyen Thi H', '2024-02-25',  3, NULL, NULL, 'Study Materials');
INSERT INTO Users VALUES ('U0000010', 'Tran Van I', '2024-04-18',  7, 'tranvani', 'mypassword', NULL);
INSERT INTO Users VALUES ('U0000011', 'Nguyen Anh J', '2024-03-10',  2, NULL, NULL, 'Explore Books');
INSERT INTO Users VALUES ('U0000012', 'Pham Thi K', '2024-05-05',  9, 'phamthik', 'abc12345', NULL);


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
