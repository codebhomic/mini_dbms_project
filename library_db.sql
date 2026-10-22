-- =====================================================================
-- PPF WEEK 9: DBMS MINI PROJECT - LIBRARY MANAGEMENT SYSTEM
-- Database: LibraryDB
-- Author: Bhoumic Garg
-- Target Engine: MySQL / MariaDB / ANSI SQL Compatible
-- =====================================================================

-- Step 1: Database Creation and Selection
CREATE DATABASE IF NOT EXISTS LibraryDB;
USE LibraryDB;

-- Step 2: Drop Tables if already existing (Reverse order of dependencies)
DROP TABLE IF EXISTS Book_Issue;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Students;

-- =====================================================================
-- Step 3: Table Definitions with Constraints
-- =====================================================================

-- 3.1 Students Table
-- Stores student demographic and contact information
CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL,
    enrollment_year INT NOT NULL CHECK (enrollment_year >= 2000),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.2 Books Table
-- Stores book inventory details, categories, and real-time availability
CREATE TABLE Books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    isbn VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    publisher VARCHAR(100),
    publish_year INT CHECK (publish_year >= 1900),
    total_copies INT NOT NULL CHECK (total_copies >= 0),
    available_copies INT NOT NULL CHECK (available_copies >= 0 AND available_copies <= total_copies)
);

-- 3.3 Book_Issue Table
-- Stores book transaction records including loans, due dates, returns, and fines
CREATE TABLE Book_Issue (
    issue_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    book_id INT NOT NULL,
    issue_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Issued',
    fine_amount DECIMAL(6, 2) NOT NULL DEFAULT 0.00 CHECK (fine_amount >= 0.00),
    
    -- Referential Integrity Constraints (Foreign Keys)
    CONSTRAINT fk_issue_student 
        FOREIGN KEY (student_id) REFERENCES Students(student_id)
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
        
    CONSTRAINT fk_issue_book 
        FOREIGN KEY (book_id) REFERENCES Books(book_id)
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
        
    -- Business Logic Validation Constraints
    CONSTRAINT chk_status_domain 
        CHECK (status IN ('Issued', 'Returned', 'Overdue')),
        
    CONSTRAINT chk_dates_valid 
        CHECK (return_date IS NULL OR return_date >= issue_date),
        
    CONSTRAINT chk_due_valid 
        CHECK (due_date >= issue_date)
);

-- Optimization: Indexes for frequent foreign key joins and search queries
CREATE INDEX idx_student_name ON Students(last_name, first_name);
CREATE INDEX idx_book_category ON Books(category);
CREATE INDEX idx_issue_status ON Book_Issue(status);

-- =====================================================================
-- Step 4: Sample Data Population
-- =====================================================================

-- 4.1 Insert Student Records (6 records > 5 required)
INSERT INTO Students (first_name, last_name, email, phone, department, enrollment_year) VALUES
('Aarav', 'Sharma', 'aarav.sharma@example.edu', '9876543210', 'Computer Science', 2023),
('Priya', 'Patel', 'priya.patel@example.edu', '9876543211', 'Information Technology', 2022),
('Rohan', 'Verma', 'rohan.verma@example.edu', '9876543212', 'Electronics & Comm', 2023),
('Ananya', 'Gupta', 'ananya.gupta@example.edu', '9876543213', 'Computer Science', 2021),
('Vikram', 'Singh', 'vikram.singh@example.edu', '9876543214', 'Mechanical Eng', 2024),
('Sneha', 'Reddy', 'sneha.reddy@example.edu', '9876543215', 'Information Technology', 2022);

-- 4.2 Insert Book Records (12 records > 10 required)
INSERT INTO Books (isbn, title, author, category, publisher, publish_year, total_copies, available_copies) VALUES
('978-0078022159', 'Database System Concepts', 'Abraham Silberschatz', 'Database', 'McGraw-Hill', 2019, 5, 3),
('978-0133970777', 'Fundamentals of Database Systems', 'Ramez Elmasri', 'Database', 'Pearson', 2015, 4, 3),
('978-0262033848', 'Introduction to Algorithms', 'Thomas H. Cormen', 'Algorithms', 'MIT Press', 2009, 6, 4),
('978-0132350884', 'Clean Code', 'Robert C. Martin', 'Software Engineering', 'Prentice Hall', 2008, 5, 5),
('978-1119800361', 'Operating System Concepts', 'Abraham Silberschatz', 'Operating Systems', 'Wiley', 2021, 4, 2),
('978-0130661029', 'Computer Networks', 'Andrew S. Tanenbaum', 'Networking', 'Prentice Hall', 2010, 3, 2),
('978-0136042594', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell', 'AI & ML', 'Pearson', 2020, 4, 3),
('978-0201616224', 'The Pragmatic Programmer', 'Andrew Hunt', 'Software Engineering', 'Addison-Wesley', 1999, 3, 3),
('978-0132847377', 'Data Structures and Algorithm Analysis in C++', 'Mark Allen Weiss', 'Data Structures', 'Pearson', 2013, 5, 4),
('978-0201633610', 'Design Patterns: Elements of Reusable OO Software', 'Erich Gamma', 'Software Engineering', 'Addison-Wesley', 1994, 3, 2),
('978-0321486813', 'Compilers: Principles, Techniques, and Tools', 'Alfred V. Aho', 'Compiler Design', 'Pearson', 2006, 2, 2),
('978-0128000564', 'Digital Design and Computer Architecture', 'David Harris', 'Architecture', 'Morgan Kaufmann', 2012, 3, 3);

-- 4.3 Insert Book Issue Transactions (8 historical and active records)
INSERT INTO Book_Issue (student_id, book_id, issue_date, due_date, return_date, status, fine_amount) VALUES
-- Returned on time (No fine)
(1, 1, '2026-09-01', '2026-09-15', '2026-09-14', 'Returned', 0.00),
-- Returned 3 days late (Rs. 10/day fine = Rs. 30.00)
(2, 5, '2026-09-05', '2026-09-19', '2026-09-22', 'Returned', 30.00),
-- Returned on time
(3, 3, '2026-09-10', '2026-09-24', '2026-09-23', 'Returned', 0.00),
-- Returned on time
(4, 9, '2026-09-12', '2026-09-26', '2026-09-25', 'Returned', 0.00),
-- Active Loan: Currently Issued (Student 1 - Aarav Sharma)
(1, 1, '2026-10-10', '2026-10-24', NULL, 'Issued', 0.00),
-- Active Loan: Currently Issued (Student 1 - Aarav Sharma)
(1, 6, '2026-10-12', '2026-10-26', NULL, 'Issued', 0.00),
-- Active Loan: Currently Issued (Student 2 - Priya Patel)
(2, 5, '2026-10-08', '2026-10-22', NULL, 'Issued', 0.00),
-- Overdue Loan: Due date passed (Student 4 - Ananya Gupta)
(4, 10, '2026-09-20', '2026-10-04', NULL, 'Overdue', 90.00);


-- =====================================================================
-- Step 5: Required Queries and Data Analysis
-- =====================================================================

-- ---------------------------------------------------------------------
-- Task Query 1: Display all student details
-- ---------------------------------------------------------------------
SELECT 
    student_id AS student_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email AS email_address,
    phone AS phone_number,
    department AS department,
    enrollment_year AS enrollment_year
FROM Students
ORDER BY student_id ASC;

-- ---------------------------------------------------------------------
-- Task Query 2: Display available books (copies > 0)
-- ---------------------------------------------------------------------
SELECT 
    book_id AS book_id,
    isbn AS isbn,
    title AS book_title,
    author AS author,
    category AS category,
    total_copies AS total_copies,
    available_copies AS available_copies
FROM Books
WHERE available_copies > 0
ORDER BY category, title;

-- ---------------------------------------------------------------------
-- Task Query 3: Display books issued to a particular student (e.g., student_id = 1)
-- Demonstrates INNER JOIN across Students, Book_Issue, and Books
-- ---------------------------------------------------------------------
SELECT 
    s.student_id AS student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department AS department,
    b.title AS book_title,
    b.author AS author,
    bi.issue_date AS issue_date,
    bi.due_date AS due_date,
    bi.return_date AS return_date,
    bi.status AS loan_status,
    bi.fine_amount AS fine_amount
FROM Book_Issue bi
INNER JOIN Students s ON bi.student_id = s.student_id
INNER JOIN Books b ON bi.book_id = b.book_id
WHERE s.student_id = 1
ORDER BY bi.issue_date DESC;

-- ---------------------------------------------------------------------
-- Task Query 4: Display all students and any books they borrowed (LEFT JOIN)
-- Demonstrates LEFT OUTER JOIN (includes students with 0 book issues)
-- ---------------------------------------------------------------------
SELECT 
    s.student_id AS student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department AS department,
    COALESCE(b.title, 'No Books Issued') AS issued_book_title,
    COALESCE(bi.status, 'None') AS issue_status,
    bi.due_date AS due_date
FROM Students s
LEFT JOIN Book_Issue bi ON s.student_id = bi.student_id
LEFT JOIN Books b ON bi.book_id = b.book_id
ORDER BY s.student_id;

-- ---------------------------------------------------------------------
-- Task Query 5: Aggregate Query - Inventory Breakdown by Category
-- Demonstrates COUNT(), SUM(), and GROUP BY
-- ---------------------------------------------------------------------
SELECT 
    category AS category,
    COUNT(book_id) AS unique_titles,
    SUM(total_copies) AS total_inventory_copies,
    SUM(available_copies) AS available_copies,
    (SUM(total_copies) - SUM(available_copies)) AS currently_loaned_copies
FROM Books
GROUP BY category
ORDER BY total_inventory_copies DESC;

-- ---------------------------------------------------------------------
-- Task Query 6: Aggregate Query - Overall Library Statistics
-- Demonstrates multiple aggregate functions in a single executive summary
-- ---------------------------------------------------------------------
SELECT 
    (SELECT COUNT(*) FROM Students) AS total_students_registered,
    (SELECT COUNT(*) FROM Books) AS total_book_titles,
    (SELECT SUM(total_copies) FROM Books) AS total_volume_of_books,
    (SELECT SUM(available_copies) FROM Books) AS available_on_shelves,
    (SELECT COUNT(*) FROM Book_Issue WHERE status = 'Issued' OR status = 'Overdue') AS active_loans,
    (SELECT SUM(fine_amount) FROM Book_Issue) AS total_fines_collected;

-- ---------------------------------------------------------------------
-- Task Query 7: Aggregate Query with HAVING - Most Active Borrowers
-- Identifies students who have borrowed 2 or more books
-- ---------------------------------------------------------------------
SELECT 
    s.student_id AS student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department AS department,
    COUNT(bi.issue_id) AS total_borrow_transactions
FROM Students s
INNER JOIN Book_Issue bi ON s.student_id = bi.student_id
GROUP BY s.student_id, s.first_name, s.last_name, s.department
HAVING COUNT(bi.issue_id) >= 2
ORDER BY total_borrow_transactions DESC;

-- ---------------------------------------------------------------------
-- Task Query 8: Overdue Books and Fine Summary
-- Displays all overdue books with calculated late fee
-- ---------------------------------------------------------------------
SELECT 
    bi.issue_id AS issue_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.phone AS contact_phone,
    b.title AS book_title,
    bi.issue_date AS issued_on,
    bi.due_date AS due_date,
    bi.status AS loan_status,
    bi.fine_amount AS accrued_fine
FROM Book_Issue bi
INNER JOIN Students s ON bi.student_id = s.student_id
INNER JOIN Books b ON bi.book_id = b.book_id
WHERE bi.status = 'Overdue' OR bi.fine_amount > 0
ORDER BY bi.fine_amount DESC;

-- =====================================================================
-- Step 6: Data Manipulation Operations (DML)
-- Demonstrates INSERT, UPDATE, and DELETE with transaction integrity
-- =====================================================================

-- 6.1 DML: Issue a new book to student 3 (Rohan Verma issues book 7: AI)
-- First decrement available_copies
UPDATE Books 
SET available_copies = available_copies - 1 
WHERE book_id = 7 AND available_copies > 0;

INSERT INTO Book_Issue (student_id, book_id, issue_date, due_date, return_date, status, fine_amount)
VALUES (3, 7, '2026-10-22', '2026-11-05', NULL, 'Issued', 0.00);

-- 6.2 DML: Return a book (Student 1 returns book 6)
-- Update Book_Issue status & return date, then increment available_copies
UPDATE Book_Issue
SET return_date = '2026-10-22',
    status = 'Returned',
    fine_amount = 0.00
WHERE student_id = 1 AND book_id = 6 AND status = 'Issued';

UPDATE Books
SET available_copies = available_copies + 1
WHERE book_id = 6;

-- =====================================================================
-- Step 7: Database Views for Modular Access
-- Creates a reusable view of all currently active book issues
-- =====================================================================
CREATE OR REPLACE VIEW ActiveBookLoansView AS
SELECT 
    bi.issue_id,
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.email,
    s.department,
    b.book_id,
    b.title AS book_title,
    b.author,
    bi.issue_date,
    bi.due_date,
    bi.status,
    bi.fine_amount
FROM Book_Issue bi
JOIN Students s ON bi.student_id = s.student_id
JOIN Books b ON bi.book_id = b.book_id
WHERE bi.status IN ('Issued', 'Overdue');

-- Querying the created view
SELECT * FROM ActiveBookLoansView;
