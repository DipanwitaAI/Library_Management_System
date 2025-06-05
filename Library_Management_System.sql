show databases;

-- 1. Create a Database

create Database Library;

use Library;

-- 2.  Authors: 

create table Authors (
Author_ID int auto_increment primary Key,
A_Name varchar(100),
Country varchar(20)
);

create table Books (
Book_ID int auto_increment primary key,
Title varchar(60),
Author_ID int,
Category varchar(20),
Price decimal(2),
foreign key (Author_ID) references Authors(Author_ID)
);

CREATE TABLE Members (
    Member_ID int auto_increment primary key,
    M_Name varchar(100),
    JoinDate date
);

CREATE TABLE Borrowing (
    Borrow_ID int auto_increment primary key,
    Member_ID int,
    Book_ID int,
    Borrow_Date date,
    Return_Date date,
    foreign key (Member_ID) references Members(Member_ID),
    foreign key (Book_ID) references Books(Book_ID)
);

-- 3. Insert Data

insert into Authors (A_Name, Country) values
('Rabindranath', 'Birbhum'),
('Saratchandra', 'Kolkata'),
('Bankimchandra', 'Bankura'),
('Vidyasagar', 'Medinipur');

select *from Authors;

insert into Books (Title, Author_ID, Category, Price) values
('Jogajog', 1, 'Fantasy', 29.99),
('Pother dabi', 2, 'Mystery', 18.50),
('Kamala kanter daptar', 3, 'Fantasy', 30.00),
('Barna porichoy', 4, 'Literacy', 20.30);

select *from Books;

insert into Members (M_Name, JoinDate) values
('Alice', '2024-01-15'),
('Bob', '2024-06-22'),
('Charlie', '2025-02-10'),
('Diana', '2025-02-18');

select *from Members;

insert into Borrowing (Member_ID, Book_ID, Borrow_Date, Return_Date) values 
(1, 1, '2025-02-01', '2025-02-10'),
(2, 2, '2025-01-20', '2025-01-25'),
(3, 3, '2025-02-12', '2025-02-18'),
(4, 4, '2025-01-30', '2025-02-05');

select *from Borrowing;

-- 1. Joins 
-- a. List all books with their authors 
select books.title as book_title, authors.A_name as author_name 
from books
join authors on books.author_ID=authors.author_ID;

-- b. Show all books borrowed along with the member’s name
select books.Title, Members.M_Name as Member_Name
from borrowing
join books on borrowing.Book_Id = books.Book_Id
join Members on borrowing.Member_Id = Members.Member_Id;

-- c. Find members who have borrowed Fantasy books
select distinct Members.M_Name as Member_Name
from borrowing
join books on borrowing.Book_Id = books.Book_Id
join Members on borrowing.member_Id = Members.Member_Id
where books.category = 'Fantasy';

-- 2. Indexing for Optimization
-- a. Create an index on AuthorID in the Books table to speed up searches
create index Author_index on books(Author_ID);

-- b. Create an index on BookID in Borrowing for faster lookup
create index book_index on borrowing(Book_Id);

-- 3. Views
-- a. Create a view to display borrowed books and their members
create view BorrowedBooks as
select books.Title, Members.M_Name as Member, borrowing.Borrow_Date, Borrowing.Return_Date
from Borrowing
join books on borrowing.Book_Id = books.Book_Id
join Members on Borrowing.Member_Id = Members.Member_Id;

-- b. Query the view
select * from BorrowedBooks;

-- 4. Stored Procedure
-- a. Create a stored procedure to list books by category. Call the procedure.

DELIMITER $$
CREATE PROCEDURE ListBooksByCategory(IN category_name VARCHAR(20))
BEGIN
    SELECT 
        b.Book_ID,
        b.Title,
        a.A_Name AS Author,
        b.Category,
        b.Price
    FROM Books b
    JOIN Authors a ON b.Author_ID = a.Author_ID
    WHERE b.Category = category_name;
END$$

DELIMITER ;

-- Call the procedure.
CALL ListBooksByCategory('Fantasy');

-- 5. User-defined functions
-- a. Create a function to calculate late fine (₹5 per day after 7 days)
Delimiter $$
create function CalculateFine(return_date Date, borrow_date date) RETURNS INT DETERMINISTIC
begin
	declare days_late int;
    declare fine int;
    set days_late = datediff(return_date, borrow_date) -7;
    set fine = If(days_late > 0, days_late * 5, 0);
    return fine;
end $$
delimiter ;

-- 6. Triggers
-- a. Create a trigger to update fine when a book is returned late.
CREATE TABLE Fines (
    Fine_ID INT PRIMARY KEY AUTO_INCREMENT,
    Member_ID INT,
    Book_ID INT,
    FineAmount INT,
    FOREIGN KEY(Member_ID) REFERENCES Members(Member_ID),
    FOREIGN KEY(Book_ID) REFERENCES Books(Book_ID)
);

DELIMITER $$
CREATE TRIGGER UpdateFineOnReturn
AFTER UPDATE ON Borrowing
FOR EACH ROW
BEGIN
    DECLARE days_late INT;
    DECLARE fine INT;

    IF NEW.Return_Date IS NOT NULL THEN
        SET days_late = DATEDIFF(NEW.Return_Date, NEW.Borrow_Date) - 7;

        IF days_late > 0 THEN
            SET fine = days_late * 5;  -- ₹5 per day late

            INSERT INTO Fines(Member_ID, Book_ID, FineAmount)
            VALUES (NEW.Member_ID, NEW.Book_ID, fine);
        END IF;
    END IF;
END$$
DELIMITER ;


-- Test the trigger
UPDATE Borrowing
SET Return_Date = '2025-02-15'
WHERE Borrow_ID = 1;