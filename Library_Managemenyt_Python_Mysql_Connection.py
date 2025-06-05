import mysql.connector
from datetime import datetime

# Connect to MySQL database
conn = mysql.connector.connect(
    host="localhost",
    user="root",
    password="root",
    database="Library"
)
cursor = conn.cursor()

# Utility Functions
def add_author():
    name = input("Enter author name: ")
    country = input("Enter author country: ")
    cursor.execute("INSERT INTO Authors (A_Name, Country) VALUES (%s, %s)", (name, country))
    conn.commit()
    print("✅ Author added successfully.")

def add_book():
    title = input("Enter book title: ")
    author_id = int(input("Enter author ID: "))
    category = input("Enter category: ")
    price = float(input("Enter price: "))
    cursor.execute("INSERT INTO Books (Title, Author_ID, Category, Price) VALUES (%s, %s, %s, %s)",
                   (title, author_id, category, price))
    conn.commit()
    print("✅ Book added successfully.")

def add_member():
    name = input("Enter member name: ")
    join_date = input("Enter join date (YYYY-MM-DD): ")
    cursor.execute("INSERT INTO Members (M_Name, JoinDate) VALUES (%s, %s)", (name, join_date))
    conn.commit()
    print("✅ Member added successfully.")

def borrow_book():
    member_id = int(input("Enter member ID: "))
    book_id = int(input("Enter book ID: "))
    borrow_date = input("Enter borrow date (YYYY-MM-DD): ")
    return_date = input("Enter return date (YYYY-MM-DD): ")
    cursor.execute("""
        INSERT INTO Borrowing (Member_ID, Book_ID, Borrow_Date, Return_Date)
        VALUES (%s, %s, %s, %s)
    """, (member_id, book_id, borrow_date, return_date))
    conn.commit()
    print("✅ Book borrowed successfully.")

def show_table(table_name):
    try:
        cursor.execute(f"SELECT * FROM {table_name}")
        rows = cursor.fetchall()
        print(f"\n--- {table_name} ---")
        for row in rows:
            print(row)
    except mysql.connector.Error as err:
        print(f"⚠️ Error: {err}")

# Menu Loop
while True:
    print("\n=== Library Management System ===")
    print("1. Add Author")
    print("2. Add Book")
    print("3. Add Member")
    print("4. Borrow Book")
    print("5. Show Authors")
    print("6. Show Books")
    print("7. Show Members")
    print("8. Show Borrowing Records")
    print("9. Exit")

    choice = input("Enter your choice: ")

    if choice == "1":
        add_author()
    elif choice == "2":
        add_book()
    elif choice == "3":
        add_member()
    elif choice == "4":
        borrow_book()
    elif choice == "5":
        show_table("Authors")
    elif choice == "6":
        show_table("Books")
    elif choice == "7":
        show_table("Members")
    elif choice == "8":
        show_table("Borrowing")
    elif choice == "9":
        print("✅ Program terminated. Goodbye!")
        break
    else:
        print("❌ Invalid choice. Try again.")

# Close connection
cursor.close()
conn.close()