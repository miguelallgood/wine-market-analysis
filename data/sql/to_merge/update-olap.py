import sqlite3
import os

# Get the directory of the currently executing script
current_directory = os.path.dirname(os.path.abspath(__file__))

# Construct the absolute path to the database file
original_database_path = os.path.join(current_directory, '../db/raw.db')

# Check if the file exists
if not os.path.exists(original_database_path):
    print("Error: Database file does not exist at", original_database_path)
    exit()

# Connect to the existing SQLite database
existing_conn = sqlite3.connect(original_database_path)
existing_cursor = existing_conn.cursor()

# Retrieve data for dimensions and facts tables
existing_cursor.execute('SELECT DISTINCT code, name FROM countries')
dim_countries = existing_cursor.fetchall()

# Close the cursor and connection to the existing database
existing_cursor.close()
existing_conn.close()

# Create a new SQLite database
new_db_path = os.path.join(current_directory, '../db/dimfact.db')
new_conn = sqlite3.connect(new_db_path)
new_cursor = new_conn.cursor()

# Create tables for dimensions and facts
new_cursor.execute('''
    CREATE TABLE Dim_countries (
        country_code VARCHAR PRIMARY KEY,
        country_name VARCHAR
    )           
''')

# Insert fetched values into the Dim_countries table
for country_code, country_name in dim_countries:
    new_cursor.execute('''
        INSERT INTO Dim_countries (country_code, country_name)
        VALUES (?, ?)
    ''', (country_code, country_name))

# Commit changes and close connection to the new database
new_conn.commit()
new_cursor.close()
new_conn.close()

print("Data inserted into Dim_countries table.")
