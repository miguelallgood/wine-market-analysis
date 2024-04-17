import argparse
import shutil
import sqlite3

from config import Config
from utils.build_olap import transfer_data


def main():
    parser = argparse.ArgumentParser(description="Database Management Utility")
    parser.add_argument("--fix-db", action="store_true", help="Fix the database integrity issues")
    parser.add_argument("--update-olap", action="store_true", help="Update the OLAP data warehouse")

    args = parser.parse_args()

    if args.fix_db:
        fix_database()
    elif args.update_olap:
        update_olap()
    else:
        # If no arguments are provided, print help
        parser.print_help()


def fix_database():
    """Copy the raw database to a new location and fix the integrity issues by applying the SQL script."""
    # Fetch configuration paths
    path_raw_db = Config.PATH_RAW_DATABASE
    path_fixed_db = Config.PATH_FIXED_DATABASE
    sql_script_path = Config.PATH_FIX_DB_SQL

    # Copying the database file
    print("Copying database from", path_raw_db, "to", path_fixed_db)
    shutil.copy(path_raw_db, path_fixed_db)

    # Connecting to the new database
    conn = sqlite3.connect(path_fixed_db)
    cursor = conn.cursor()
    print("Database copied successfully. Fixing database integrity issues...")

    # Reading and executing the SQL script
    with open(sql_script_path, 'r') as sql_file:
        sql_script = sql_file.read()
    cursor.executescript(sql_script)
    conn.commit()

    # Closing the database connection
    cursor.close()
    conn.close()
    print("Database integrity issues fixed successfully.")


def update_olap():
    # Dim Winery Name
    transfer_data(
        message="Creating Dim_Winery_Name in OLAP data warehouse...",
        select_query="SELECT id, name FROM wineries",
        table_creation="""
        DROP TABLE IF EXISTS Dim_Winery_Name;
        CREATE TABLE Dim_Winery_Name (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(255)
        );
        """,
        insert_query="INSERT INTO Dim_Winery_Name (id, name) VALUES (?, ?)"
    )
    # Fact Wineries
    transfer_data(
        message="Creating Fact_Wineries in OLAP data warehouse...",
        select_query="""
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
        """,
        table_creation="""
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
        """,
        insert_query="""
        INSERT INTO Fact_Wineries (winery, avg_price, avg_rating, total_ratings, overal_score, num_of_wines) 
        VALUES (?, ?, ?, ?, ?, ?)
        """
    )
    print("Updating OLAP data warehouse...")


if __name__ == "__main__":
    main()
    # from config import Config
    # print(Config.BASE_DIR)