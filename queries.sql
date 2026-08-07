CREATE TABLE Books(
    book_id VARCHAR(50) PRIMARY KEY,
    book_name VARCHAR(50),
    category VARCHAR(50),
    author VARCHAR(50),
    copies INT
);
INSERT INTO Books(book_id,book_name,category,author,copies) VALUES('B101','SQL Basics','Technology','James Lee',10);
INSERT INTO Books(book_id,book_name,category,author,copies) VALUES('B102','Python Guide','Technology','David Miller',8);
INSERT INTO Books(book_id,book_name,category,author,copies) VALUES('B103','Data Science','Education','Sarah Green',5);
--- SELECT *FROM Books;

------------------- BORROW TABLE --------------------------------
CREATE TABLE Borrow(
    borrow_id VARCHAR(50) PRIMARY KEY,
    member_id VARCHAR(50),
    librarian_id VARCHAR(50),
    borrow_date DATE
);
INSERT INTO Borrow(borrow_id,member_id,librarian_id,borrow_date) VALUES('BR001','M101','L01',DATE '2025-01-10');
------ SELECT *FROM Borrow; 

------------------- BORROW_DETAILS TABLE ----------------------------
CREATE TABLE Borrow_details(
    borrow_detail_id NUMBER PRIMARY KEY,
    borrow_id VARCHAR(50),
    book_id VARCHAR(50),
    quantity NUMBER,
    return_date DATE
);
INSERT INTO Borrow_details(borrow_detail_id,borrow_id,book_id,quantity,return_date) VALUES(1,'BR001','B101',1,DATE '2025-01-20');
INSERT INTO Borrow_details(borrow_detail_id,borrow_id,book_id,quantity,return_date) VALUES(2,'BR001','B102',2,DATE	'2025-01-25');
INSERT INTO Borrow_details(borrow_detail_id,borrow_id,book_id,quantity,return_date) VALUES(3,'BR002','B103',1,NULL);
--- SELECT *FROM Borrow_details;

----------------------- Which Books are borrowed the most ???? --------------------
SELECT B.book_name,B_D.quantity AS Total_Times_Borrowed FROM Books B
JOIN Borrow_details B_D ON B.book_id=B_D.book_id
JOIN Borrow B_O ON B_D.borrow_id=B_O.borrow_id
GROUP BY B.book_name,Total_Times_Borrowed ORDER BY B_D.quantity DESC;

----------------------- Which members borrow the most books ?? --------------------
------------------------------------- Members Table -------------------------------
CREATE TABLE Members(
    member_id VARCHAR(50),
    member_name VARCHAR(50),
    city VARCHAR(50),
    email VARCHAR(50)
);
INSERT INTO Members(member_id,member_name,city,email) VALUES
('M101','John Smith','London','john@email.com'),
('M102','Emma Brown','Manchester','emma@email.com'),
('M103','David Lee','Birmingham','david@email.com');
---- SELECT *FROM Members;

SELECT M.member_name, NVL(SUM(B_D.quantity),0) AS Total_Times_Borrowed FROM Members M
LEFT JOIN Borrow B_O ON M.member_id = B_O.member_id
LEFT JOIN Borrow_Details B_D ON B_D.borrow_id = B_O.borrow_id
LEFT JOIN Books B ON B.book_id = B_D.book_id                      
GROUP BY M.member_name ORDER BY Total_Times_Borrowed DESC;

----------------------- Which book category are most popular ?? --------------------
SELECT B.category,SUM(B_D.quantity) AS Most_popular_books_count FROM Books B
JOIN Borrow_Details B_D ON B.book_id=B_D.book_id
GROUP BY B.category ORDER BY Most_popular_books_count DESC;

----------------------- Monthly borrowing Trends ?? --------------------
SELECT TO_CHAR(B_O.borrow_date,'Month') AS "Month", SUM(B_D.quantity) AS Total_Books_Borrowed_In_Month FROM Borrow_details B_D
JOIN Borrow B_O ON B_D.borrow_id=B_O.borrow_id
GROUP BY TO_CHAR(B_O.borrow_date,'Month'), TO_CHAR(B_O.borrow_date,'MM') ORDER BY TO_CHAR(B_O.borrow_date,'MM');

----------------------- Librarian Performance ?? --------------------
CREATE TABLE Librarians(
    librarian_id VARCHAR(50),
    Librarian_name VARCHAR(50),
    Branch VARCHAR(50)
);
INSERT INTO Librarians(librarian_id,Librarian_name,Branch) VALUES
('L01','Alice','Central'), 
('L02','Bob','North');

----------------------- Librarian Performance ?? --------------------
SELECT L.Librarian_name,SUM(B_D.quantity) AS Total_Books_Issued FROM Librarians L
JOIN Borrow B_O ON L.librarian_id=B_O.librarian_id
JOIN Borrow_Details B_D ON  B_O.borrow_id=B_D.borrow_id
GROUP BY L.Librarian_name ORDER BY Total_Books_Issued DESC;

----------------------- Available VS Issued Books ?? --------------------
SELECT B.book_name, B.copies AS Total_Copies, B_D.quantity AS Issued_Copies, (B.copies - B_D.quantity ) AS Available_Copies FROM Books B
JOIN Borrow_Details B_D ON B.book_id=B_D.book_id
GROUP BY B.book_name,B.copies,B_D.quantity,(B.copies - B_D.quantity ) ORDER BY Available_Copies DESC;

----------------------- Overdue Books ?? --------------------
SELECT B.book_name, B.book_id, B_O.borrow_date, B_D.return_date, 'Overdue' AS Status FROM Books B
JOIN Borrow_Details B_D ON B.book_id =B_D.book_id 
JOIN Borrow B_O ON B_O.borrow_id = B_D.borrow_id
WHERE B_D.return_date IS NULL
GROUP BY B.book_name, B.book_id, B_O.borrow_date, B_D.return_date ;

----------------------- Most Active Members ?? --------------------
SELECT M.member_name, NVL(SUM(B_D.quantity),0) AS Total_Books_Borrowed, RANK() OVER(ORDER BY NVL(SUM(B_D.quantity),0) DESC) AS Activity_Rank FROM Members M
LEFT JOIN Borrow B_O ON M.member_id=B_O.member_id
LEFT JOIN Borrow_Details B_D ON B_O.borrow_id=B_D.borrow_id
GROUP BY M.member_name ORDER BY Total_Books_Borrowed DESC;

----------------------- Book Return Statistics ?? --------------------
SELECT book_name, Borrowed_quantity, Returned_quantity, Not_Returned,
CASE WHEN  Borrowed_quantity = Returned_quantity
              THEN 'Returned'
              ELSE 'Not_Returned'
              END  AS Status 
FROM
(SELECT B.book_name, SUM(B_D.quantity) AS Borrowed_quantity, 
       SUM(
            CASE 
                 WHEN B_D.return_date IS NOT NULL
                 THEN B_D.quantity
                 ELSE 0
                 END ) AS Returned_quantity, 
       SUM(
            CASE 
                 WHEN B_D.return_date IS NULL
                 THEN B_D.quantity
                 ELSE 0
                 END ) AS Not_Returned
        FROM Books B
JOIN Borrow_Details B_D ON B.book_id=B_D.book_id
GROUP BY B.book_name) ORDER BY Borrowed_quantity ;

