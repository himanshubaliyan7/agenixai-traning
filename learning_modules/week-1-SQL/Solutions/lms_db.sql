-- **Schema Creation Script**

CREATE TABLE Author (
    AUTHORID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Genre_Exp VARCHAR(50) NOT NULL
);

CREATE TABLE Books (
    BOOKID SERIAL PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Publication_Date DATE NOT NULL,
    AUTHORID INT NOT NULL,
    FOREIGN KEY (AUTHORID) REFERENCES Author(AUTHORID)
);

CREATE TABLE Customer (
    CUSTOMERID SERIAL PRIMARY KEY,
    Name VARCHAR(50) NOT NULL,
    Contact_No VARCHAR(15),
    Email VARCHAR(100)
);

CREATE TABLE Transactions (
    TRANSACTIONID SERIAL PRIMARY KEY,
    BOOKID INT NOT NULL,
    CUSTOMERID INT NOT NULL,
    IssueDate DATE NOT NULL,
    ReturnDate DATE,
    FOREIGN KEY (BOOKID) REFERENCES Books(BOOKID),
    FOREIGN KEY (CUSTOMERID) REFERENCES Customer(CUSTOMERID)
);



-- **Data Insertion Script**

-- Authors
INSERT INTO Author (Name, Genre_Exp) VALUES 
('J.K. Rowling', 'Fantasy'), 
('George R.R. Martin', 'Fantasy'), 
('Agatha Christie', 'Mystery'), 
('Dan Brown', 'Thriller'), 
('Jane Austen', 'Romance');


-- Books
INSERT INTO Books (Title, Genre, Publication_Date, AUTHORID) VALUES
('Harry Potter and the Sorcerer''s Stone', 'Fantasy', '1997-06-26', 1),
('A Game of Thrones', 'Fantasy', '1996-08-06', 2),
('Murder on the Orient Express', 'Mystery', '1934-01-01', 3),
('The Da Vinci Code', 'Thriller', '2003-03-18', 4),
('Pride and Prejudice', 'Romance', '1813-01-28', 5);

-- Customers
INSERT INTO Customer (Name, Contact_No, Email) VALUES
('Alice Johnson', '1234567890', 'alice@example.com'),
('Bob Smith', '9876543210', 'bob@example.com'),
('Charlie Brown', '5678901234', 'charlie@example.com');

-- Transactions
INSERT INTO Transactions (BOOKID, CUSTOMERID, IssueDate, ReturnDate) VALUES
(1, 1, '2024-01-01', '2024-01-15'),
(2, 2, '2024-01-10', NULL),
(3, 3, '2024-01-12', NULL),
(1, 2, '2024-01-15', NULL),
(5, 1, '2024-01-20', NULL);



-- **SQL Queries for Tasks**

-- 1. Retrieve the Top 5 Most-Issued Books with Their Issue Count
SELECT 
    b.Title, 
    COUNT(t.TRANSACTIONID) AS IssueCount
FROM 
    Books b
JOIN 
    Transactions t ON b.BOOKID = t.BOOKID
GROUP BY 
    b.Title
ORDER BY 
    IssueCount DESC
LIMIT 5;

-- 2. List Books Along with Their Authors in the "Fantasy" Genre, Sorted by Publication Year
SELECT 
    b.Title, 
    a.Name AS AuthorName, 
    b.Publication_Date
FROM 
    Books b
JOIN 
    Author a ON b.AUTHORID = a.AUTHORID
WHERE 
    b.Genre = 'Fantasy'
ORDER BY 
    b.Publication_Date DESC;

-- 3. Identify the Top 3 Customers Who Borrowed the Most Books
SELECT 
    c.Name, 
    COUNT(t.TRANSACTIONID) AS BorrowedBooks
FROM 
    Customer c
JOIN 
    Transactions t ON c.CUSTOMERID = t.CUSTOMERID
GROUP BY 
    c.Name
ORDER BY 
    BorrowedBooks DESC
LIMIT 3;

-- 4. List Customers with Overdue Books
SELECT 
    c.Name, 
    c.Contact_No, 
    c.Email
FROM 
    Customer c
JOIN 
    Transactions t ON c.CUSTOMERID = t.CUSTOMERID
WHERE 
    t.ReturnDate IS NULL 
    AND t.IssueDate < CURRENT_DATE - INTERVAL '30 days';

-- 5. Authors Who Have Written More Than 3 Books
SELECT 
    a.Name, 
    COUNT(b.BOOKID) AS BookCount
FROM 
    Author a
JOIN 
    Books b ON a.AUTHORID = b.AUTHORID
GROUP BY 
    a.Name
HAVING 
    COUNT(b.BOOKID) > 3;

-- 6. Authors with Books Issued in the Last 6 Months
SELECT DISTINCT 
    a.Name
FROM 
    Author a
JOIN 
    Books b ON a.AUTHORID = b.AUTHORID
JOIN 
    Transactions t ON b.BOOKID = t.BOOKID
WHERE 
    t.IssueDate >= CURRENT_DATE - INTERVAL '6 months';

-- 7. Total and Percentage of Books Currently Issued
SELECT 
    COUNT(*) AS CurrentlyIssuedBooks,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Books)) AS PercentageIssued
FROM 
    Transactions
WHERE 
    ReturnDate IS NULL;

-- 8. Monthly Report of Issued Books for the Past Year
SELECT 
    DATE_TRUNC('month', t.IssueDate) AS Month,
    COUNT(DISTINCT t.BOOKID) AS BookCount,
    COUNT(DISTINCT t.CUSTOMERID) AS UniqueCustomerCount
FROM 
    Transactions t
WHERE 
    t.IssueDate >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY 
    DATE_TRUNC('month', t.IssueDate)
ORDER BY 
    Month;

-- 9. Add Indexes
CREATE INDEX idx_books_genre ON Books (Genre);
CREATE INDEX idx_transactions_issue_date ON Transactions (IssueDate);
CREATE INDEX idx_transactions_book_customer ON Transactions (BOOKID, CUSTOMERID);

-- 10. Query Execution Plan Analysis (Use EXPLAIN)
-- Example: Analyze Query 1 Execution Plan
EXPLAIN ANALYZE
SELECT 
    b.Title, 
    COUNT(t.TRANSACTIONID) AS IssueCount
FROM 
    Books b
JOIN 
    Transactions t ON b.BOOKID = t.BOOKID
GROUP BY 
    b.Title
ORDER BY 
    IssueCount DESC
LIMIT 5;
