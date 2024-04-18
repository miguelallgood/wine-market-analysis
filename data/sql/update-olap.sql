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
-------------------------------------------------------
-- Create Dim Winery Name table
DROP TABLE IF EXISTS Dim_Winery_Name;
CREATE TABLE Dim_Winery_Name (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);
-- copy winery names to dim_winery names
INSERT INTO Dim_Winery_Name (id, name)
SELECT id, name
FROM wineries;

-- First, drop the Fact Wineries table if it exists
DROP TABLE IF EXISTS Fact_Wineries;
CREATE TABLE Fact_Wineries (
    winery INT,               -- FK
    avg_price FLOAT,          -- Average price
    avg_rating FLOAT,         -- Average rating
    total_ratings INT,        -- Total number of ratings
    overal_score INT,
    num_of_wines INT,
    FOREIGN KEY (winery) REFERENCES Dim_Winery_Name(id)
);

-- Insert data into Fact_Wineries by aggregating information from vintages and wines tables
INSERT INTO Fact_Wineries (winery, avg_price, avg_rating, total_ratings, overal_score, num_of_wines)
SELECT
    wines.winery_id,
    ROUND(AVG(vintages.price_euros)) AS avg_price,         -- Average price rounded
    AVG(vintages.ratings_average) AS avg_rating,           -- Average rating
    SUM(vintages.ratings_count) AS total_ratings,          -- Sum of all ratings
    ROUND(AVG(vintages.price_euros) *                      -- Calculated overall score
          AVG(vintages.ratings_average) *
          SUM(vintages.ratings_count)) AS overal_score,
    COUNT(DISTINCT vintages.wine_id) AS num_of_wines       -- Count of distinct wines
FROM vintages
LEFT JOIN wines ON vintages.wine_id = wines.id
GROUP BY wines.winery_id;