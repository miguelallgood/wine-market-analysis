import argparse
import shutil
import sqlite3

from config import Config
from utils.db import transfer_data_to_olap


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
    # Dim Wineries
    transfer_data_to_olap(
        message="Creating Dim_wineries in OLAP data warehouse...",
        oltp_select_query="SELECT id, name FROM wineries",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_wineries;
        CREATE TABLE Dim_wineries (
            winery_id INT AUTO_INCREMENT PRIMARY KEY,
            winery_name VARCHAR(255)
        );
        """,
        olap_insert_query="INSERT INTO Dim_wineries (winery_id, winery_name) VALUES (?, ?)"
    )
    # Fact Wineries
    transfer_data_to_olap(
        message="Creating Fact_wineries in OLAP data warehouse...",
        oltp_select_query="""
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
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_wineries;
        CREATE TABLE Fact_wineries (
            fk_winery_id INT,               -- FK
            avg_price FLOAT,          -- Average price
            avg_rating FLOAT,         -- Average rating
            total_ratings INT,        -- Total number of ratings
            overal_score INT,
            num_of_wines INT,
            FOREIGN KEY (fk_winery_id) REFERENCES Dim_wineries(winery_id)
        );
        """,
        olap_insert_query="""
        INSERT INTO Fact_wineries (fk_winery_id, avg_price, avg_rating, total_ratings, overal_score, num_of_wines) 
        VALUES (?, ?, ?, ?, ?, ?)
        """
    )

    # Dim Wines
    transfer_data_to_olap(
        message="Creating Dim_wines in OLAP data warehouse...",
        oltp_select_query="SELECT id, name FROM wines",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_wines;
        CREATE TABLE Dim_wines (
            wine_id INTEGER PRIMARY KEY,
            wine_name VARCHAR(255)
        );
        """,
        olap_insert_query="INSERT INTO Dim_wines (wine_id, wine_name) VALUES (?, ?)"
    )

    # Fact Wines
    transfer_data_to_olap(
        message="Creating Fact_wines in OLAP data warehouse...",
        oltp_select_query="""WITH avg_prices AS(  
            SELECT vintages.wine_id, avg(vintages.price_euros) AS price_avg
            FROM vintages
            GROUP BY vintages.wine_id
            )
            SELECT
                w.id,
                w.region_id,
                r.country_code,
                w.ratings_average,
                w.ratings_count, 
                a.price_avg AS calc_avg_price,
                w.ratings_count * w.ratings_average AS calc_weighted_rating 
            FROM
                wines w
            JOIN
                regions r ON w.region_id = r.id,
                avg_prices a ON w.id = a.wine_id;
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_wines;
        CREATE TABLE Fact_wines (
            fk_wine_id INTEGER,
            fk_region_id INTEGER,
            fk_country_code INTEGER,
            ratings_avg INTEGER,
            ratings_count INTEGER,
            calc_avg_price INTEGER,
            calc_weighted_rating INTEGER,
            PRIMARY KEY (fk_wine_id),
            FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
            FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
            FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code)
            );
        """,
        olap_insert_query="INSERT INTO Fact_wines (fk_wine_id, fk_region_id, fk_country_code, ratings_avg, ratings_count, calc_avg_price, calc_weighted_rating) VALUES (?, ?, ?, ?, ?, ?, ?)"
    )

    # Dim Regions
    transfer_data_to_olap(
        message="Creating Dim_regions in OLAP data warehouse...",
        oltp_select_query="SELECT DISTINCT id, country_code, name FROM regions",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_regions;
        CREATE TABLE Dim_regions (
            region_id INTEGER PRIMARY KEY,
            fk_country_code INTEGER,
            region_name VARCHAR,
            FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code)
        );
        """,
        olap_insert_query="INSERT INTO Dim_regions (region_id, fk_country_code, region_name) VALUES (?, ?, ?)"
    )

    # Dim Countries
    transfer_data_to_olap(
        message="Creating Dim_countries in OLAP data warehouse...",
        oltp_select_query="SELECT DISTINCT code, name FROM countries",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_countries;
        CREATE TABLE Dim_countries (
            country_code VARCHAR PRIMARY KEY,
            country_name VARCHAR
        );
        """,
        olap_insert_query="INSERT INTO Dim_countries (country_code, country_name) VALUES (?, ?)"
    )

    # Dim Vintages
    transfer_data_to_olap(
        message="Creating Dim_vintages in OLAP data warehouse...",
        oltp_select_query="SELECT id, name FROM vintages",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_vintages;
        CREATE TABLE Dim_vintages (
            vintages_id INTEGER PRIMARY KEY,
            vintages_name VARCHAR
        );
        """,
        olap_insert_query="INSERT INTO Dim_vintages (vintages_id, vintages_name) VALUES (?, ?)"
    )

    # Dim Grapes
    transfer_data_to_olap(
        message="Creating Dim_grapes in OLAP data warehouse...",
        oltp_select_query="SELECT id, name FROM grapes",
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_grapes;
        CREATE TABLE Dim_grapes (
            grape_id INTEGER PRIMARY KEY,
            grape_name VARCHAR  
        );
        """,
        olap_insert_query="INSERT INTO Dim_grapes (grape_id, grape_name) VALUES (?, ?)"
    )

    # Fact Vintages
    transfer_data_to_olap(
        message="Creating Fact_vintages in OLAP data warehouse...",
        oltp_select_query="""SELECT
            v.id,
            v.wine_id,
            w.region_id,
            r.country_code,
            v.ratings_average,
            v.ratings_count,
            v.year
        
        FROM
            vintages v
        JOIN
            wines w ON w.id = v.wine_id,
            regions r ON w.region_id = r.id;
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_vintages;
        CREATE TABLE Fact_vintages (
            fk_vintages_id INTEGER,
            fk_wine_id INTEGER,
            fk_region_id INTEGER,
            fk_country_code INTEGER,
            ratings_avg INTEGER,
            ratings_count INTEGER,
            year INTEGER,
            PRIMARY KEY (fk_vintages_id),
            FOREIGN KEY (fk_vintages_id) REFERENCES Dim_vintages(vintages_id),
            FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
            FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
            FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code)
        );
        """,
        olap_insert_query="INSERT INTO Fact_vintages (fk_vintages_id, fk_wine_id, fk_region_id, fk_country_code, ratings_avg, ratings_count, year) VALUES (?, ?, ?, ?, ?, ?, ?)"
    )

    # Fact Grapes
    transfer_data_to_olap(
        message="Creating Fact_grapes in OLAP data warehouse...",
        oltp_select_query="SELECT grape_id, wines_count FROM most_used_grapes_per_country GROUP BY grape_id",
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_grapes;
        CREATE TABLE Fact_grapes (
            fk_grape_id INTEGER,
            wines_count INTEGER,
            PRIMARY KEY (fk_grape_id),
            FOREIGN KEY (fk_grape_id) REFERENCES Dim_grapes(grape_id)  
        );
        """,
        olap_insert_query="INSERT INTO Fact_grapes (fk_grape_id, wines_count) VALUES (?, ?)"
    )





    





    print("Updating OLAP data warehouse...")


if __name__ == "__main__":
    main()
    # from config import Config
    # print(Config.BASE_DIR)