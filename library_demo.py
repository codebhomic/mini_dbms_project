"""
=====================================================================
PPF WEEK 9: DBMS MINI PROJECT - LIBRARY MANAGEMENT SYSTEM
Demonstration & Output Generation Script
Database: LibraryDB (Executed via Python SQLite Engine)
Author: Bhoumic Garg
=====================================================================
"""

import sqlite3
import os
import sys

def create_table_str(headers, rows):
    """Formats headers and rows into a clean MySQL-style CLI ASCII table."""
    if not rows:
        col_widths = [len(str(h)) for h in headers]
        border = "+" + "+".join("-" * (w + 2) for w in col_widths) + "+"
        header_row = "|" + "|".join(f" {str(h).ljust(w)} " for h, w in zip(headers, col_widths)) + "|"
        return f"{border}\n{header_row}\n{border}\n| (0 rows returned) |\n{border}"

    # Calculate column widths
    col_widths = [len(str(h)) for h in headers]
    for row in rows:
        for idx, val in enumerate(row):
            col_widths[idx] = max(col_widths[idx], len(str(val) if val is not None else "NULL"))

    border = "+" + "+".join("-" * (w + 2) for w in col_widths) + "+"
    header_row = "|" + "|".join(f" {str(h).ljust(w)} " for h, w in zip(headers, col_widths)) + "|"
    
    data_rows = []
    for row in rows:
        formatted_cols = []
        for val, w in zip(row, col_widths):
            text = "NULL" if val is None else str(val)
            # Right align numbers, left align text
            if isinstance(val, (int, float)):
                formatted_cols.append(f" {text.rjust(w)} ")
            else:
                formatted_cols.append(f" {text.ljust(w)} ")
        data_rows.append("|" + "|".join(formatted_cols) + "|")

    table_lines = [border, header_row, border] + data_rows + [border]
    return "\n".join(table_lines)


def setup_database():
    """Initializes SQLite database and registers custom functions for MySQL compatibility."""
    conn = sqlite3.connect(":memory:") # In-memory DB for pure reproducible demo
    
    # Custom CONCAT function to mimic MySQL CONCAT()
    conn.create_function("CONCAT", -1, lambda *args: "".join(str(a) if a is not None else "" for a in args))
    
    cursor = conn.cursor()
    
    # Enable foreign keys
    cursor.execute("PRAGMA foreign_keys = ON;")

    # 1. Create Students Table
    cursor.execute("""
    CREATE TABLE Students (
        student_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL UNIQUE,
        department TEXT NOT NULL,
        enrollment_year INTEGER NOT NULL CHECK (enrollment_year >= 2000),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """)

    # 2. Create Books Table
    cursor.execute("""
    CREATE TABLE Books (
        book_id INTEGER PRIMARY KEY AUTOINCREMENT,
        isbn TEXT NOT NULL UNIQUE,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        category TEXT NOT NULL,
        publisher TEXT,
        publish_year INTEGER CHECK (publish_year >= 1900),
        total_copies INTEGER NOT NULL CHECK (total_copies >= 0),
        available_copies INTEGER NOT NULL CHECK (available_copies >= 0 AND available_copies <= total_copies)
    );
    """)

    # 3. Create Book_Issue Table
    cursor.execute("""
    CREATE TABLE Book_Issue (
        issue_id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        book_id INTEGER NOT NULL,
        issue_date TEXT NOT NULL,
        due_date TEXT NOT NULL,
        return_date TEXT NULL,
        status TEXT NOT NULL DEFAULT 'Issued' CHECK (status IN ('Issued', 'Returned', 'Overdue')),
        fine_amount REAL NOT NULL DEFAULT 0.00 CHECK (fine_amount >= 0.00),
        FOREIGN KEY (student_id) REFERENCES Students(student_id) ON DELETE CASCADE,
        FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT
    );
    """)

    # Populate Students (6 records)
    students_data = [
        ('Aarav', 'Sharma', 'aarav.sharma@example.edu', '9876543210', 'Computer Science', 2023),
        ('Priya', 'Patel', 'priya.patel@example.edu', '9876543211', 'Information Technology', 2022),
        ('Rohan', 'Verma', 'rohan.verma@example.edu', '9876543212', 'Electronics & Comm', 2023),
        ('Ananya', 'Gupta', 'ananya.gupta@example.edu', '9876543213', 'Computer Science', 2021),
        ('Vikram', 'Singh', 'vikram.singh@example.edu', '9876543214', 'Mechanical Eng', 2024),
        ('Sneha', 'Reddy', 'sneha.reddy@example.edu', '9876543215', 'Information Technology', 2022)
    ]
    cursor.executemany("""
    INSERT INTO Students (first_name, last_name, email, phone, department, enrollment_year)
    VALUES (?, ?, ?, ?, ?, ?);
    """, students_data)

    # Populate Books (12 records)
    books_data = [
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
        ('978-0128000564', 'Digital Design and Computer Architecture', 'David Harris', 'Architecture', 'Morgan Kaufmann', 2012, 3, 3)
    ]
    cursor.executemany("""
    INSERT INTO Books (isbn, title, author, category, publisher, publish_year, total_copies, available_copies)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?);
    """, books_data)

    # Populate Book_Issue (8 records)
    issues_data = [
        (1, 1, '2026-09-01', '2026-09-15', '2026-09-14', 'Returned', 0.00),
        (2, 5, '2026-09-05', '2026-09-19', '2026-09-22', 'Returned', 30.00),
        (3, 3, '2026-09-10', '2026-09-24', '2026-09-23', 'Returned', 0.00),
        (4, 9, '2026-09-12', '2026-09-26', '2026-09-25', 'Returned', 0.00),
        (1, 1, '2026-10-10', '2026-10-24', None, 'Issued', 0.00),
        (1, 6, '2026-10-12', '2026-10-26', None, 'Issued', 0.00),
        (2, 5, '2026-10-08', '2026-10-22', None, 'Issued', 0.00),
        (4, 10, '2026-09-20', '2026-10-04', None, 'Overdue', 90.00)
    ]
    cursor.executemany("""
    INSERT INTO Book_Issue (student_id, book_id, issue_date, due_date, return_date, status, fine_amount)
    VALUES (?, ?, ?, ?, ?, ?, ?);
    """, issues_data)

    conn.commit()
    return conn


def run_all_queries():
    """Runs all mini project queries, formats output, and logs to console & file."""
    conn = setup_database()
    cursor = conn.cursor()

    queries = [
        (
            "TASK QUERY 1: Display all student details",
            """
SELECT 
    student_id,
    CONCAT(first_name, ' ', last_name) AS full_name,
    email,
    phone,
    department,
    enrollment_year
FROM Students
ORDER BY student_id ASC;
            """
        ),
        (
            "TASK QUERY 2: Display available books (available_copies > 0)",
            """
SELECT 
    book_id,
    isbn,
    title,
    author,
    category,
    total_copies,
    available_copies
FROM Books
WHERE available_copies > 0
ORDER BY category, title;
            """
        ),
        (
            "TASK QUERY 3: Display books issued to a particular student (Student ID = 1: Aarav Sharma)",
            """
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department,
    b.title AS book_title,
    b.author,
    bi.issue_date,
    bi.due_date,
    bi.return_date,
    bi.status AS loan_status,
    bi.fine_amount
FROM Book_Issue bi
INNER JOIN Students s ON bi.student_id = s.student_id
INNER JOIN Books b ON bi.book_id = b.book_id
WHERE s.student_id = 1
ORDER BY bi.issue_date DESC;
            """
        ),
        (
            "TASK QUERY 4: Display all students and books borrowed (LEFT JOIN including unborrowed)",
            """
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department,
    COALESCE(b.title, 'No Books Issued') AS issued_book,
    COALESCE(bi.status, 'None') AS status,
    bi.due_date
FROM Students s
LEFT JOIN Book_Issue bi ON s.student_id = bi.student_id
LEFT JOIN Books b ON bi.book_id = b.book_id
ORDER BY s.student_id;
            """
        ),
        (
            "TASK QUERY 5: Aggregate Query - Inventory breakdown by category",
            """
SELECT 
    category,
    COUNT(book_id) AS unique_titles,
    SUM(total_copies) AS total_inventory,
    SUM(available_copies) AS available_copies,
    (SUM(total_copies) - SUM(available_copies)) AS currently_loaned
FROM Books
GROUP BY category
ORDER BY total_inventory DESC;
            """
        ),
        (
            "TASK QUERY 6: Aggregate Query - Overall Library Executive Summary",
            """
SELECT 
    (SELECT COUNT(*) FROM Students) AS total_students,
    (SELECT COUNT(*) FROM Books) AS total_book_titles,
    (SELECT SUM(total_copies) FROM Books) AS total_volume_copies,
    (SELECT SUM(available_copies) FROM Books) AS available_on_shelves,
    (SELECT COUNT(*) FROM Book_Issue WHERE status IN ('Issued', 'Overdue')) AS active_loans,
    (SELECT SUM(fine_amount) FROM Book_Issue) AS total_fines_collected;
            """
        ),
        (
            "TASK QUERY 7: Aggregate Query with HAVING - Most active borrowers (>= 2 issues)",
            """
SELECT 
    s.student_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.department,
    COUNT(bi.issue_id) AS total_borrow_transactions
FROM Students s
INNER JOIN Book_Issue bi ON s.student_id = bi.student_id
GROUP BY s.student_id, s.first_name, s.last_name, s.department
HAVING COUNT(bi.issue_id) >= 2
ORDER BY total_borrow_transactions DESC;
            """
        ),
        (
            "TASK QUERY 8: Overdue Books and Fine Summary",
            """
SELECT 
    bi.issue_id,
    CONCAT(s.first_name, ' ', s.last_name) AS student_name,
    s.phone,
    b.title AS book_title,
    bi.issue_date,
    bi.due_date,
    bi.status,
    bi.fine_amount
FROM Book_Issue bi
INNER JOIN Students s ON bi.student_id = s.student_id
INNER JOIN Books b ON bi.book_id = b.book_id
WHERE bi.status = 'Overdue' OR bi.fine_amount > 0
ORDER BY bi.fine_amount DESC;
            """
        ),
        (
            "DATA MANIPULATION DEMO: Return book (Student 1 returns Book 6: Computer Networks)",
            """
SELECT 'Before Return' AS state, book_id, title, available_copies FROM Books WHERE book_id = 6;
            """
        )
    ]

    output_lines = []
    header_banner = "=" * 80 + "\n" + " " * 18 + "LIBRARY MANAGEMENT SYSTEM - QUERY EXECUTION OUTPUT\n" + "=" * 80
    print(header_banner)
    output_lines.append(header_banner)

    for title, sql in queries:
        section = f"\n\n{'#' * 80}\n>>> {title}\n{'#' * 80}\nSQL:\n{sql.strip()}\n\nOUTPUT:"
        print(section)
        output_lines.append(section)

        cursor.execute(sql.strip())
        rows = cursor.fetchall()
        headers = [desc[0] for desc in cursor.description]
        table_output = create_table_str(headers, rows)
        row_count_str = f"({len(rows)} row(s) returned)\n"

        print(table_output)
        print(row_count_str)
        output_lines.append(table_output)
        output_lines.append(row_count_str)

    # Perform DML update to complete the DML test
    dml_section = f"\n\n{'#' * 80}\n>>> EXECUTING DML OPERATION: UPDATE Books (Increment available copies upon return)\n{'#' * 80}\n"
    cursor.execute("UPDATE Books SET available_copies = available_copies + 1 WHERE book_id = 6;")
    cursor.execute("UPDATE Book_Issue SET status = 'Returned', return_date = '2026-10-22' WHERE student_id = 1 AND book_id = 6 AND status = 'Issued';")
    conn.commit()
    
    cursor.execute("SELECT 'After Return' AS state, book_id, title, available_copies FROM Books WHERE book_id = 6;")
    rows = cursor.fetchall()
    headers = [desc[0] for desc in cursor.description]
    after_table = create_table_str(headers, rows)
    print(dml_section + after_table)
    output_lines.append(dml_section + after_table)

    # Write output to query_output.txt
    output_file = os.path.join(os.path.dirname(__file__), "query_output.txt")
    with open(output_file, "w", encoding="utf-8") as f:
        f.write("\n".join(output_lines))
    print(f"\n[SUCCESS] All queries executed successfully! Output logged to: {output_file}")


if __name__ == "__main__":
    run_all_queries()
