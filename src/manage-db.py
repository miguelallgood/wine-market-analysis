import argparse
import shutil
import sqlite3

from config import Config
from utils.db import transfer_data_to_olap, execute_sql


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

    # Dim Toplists
    transfer_data_to_olap(
        message="Creating Dim_toplists in OLAP data warehouse...",
        oltp_select_query="""
        SELECT 
            id,
            name,	
            SUBSTR(name, 10, 4),
            SUBSTR(name, INSTR(name, ':') + 1)
        FROM 
            toplists 
        WHERE country_code = 'global' AND name LIKE '%Vivino%';
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_toplists;
        CREATE TABLE Dim_toplists (
            toplists_id INTEGER PRIMARY KEY,
	        toplists_name VARCHAR,
	        toplists_year INTEGER,
	        toplists_type_wine VARCHAR	
        );
        """,
        olap_insert_query="INSERT INTO Dim_toplists (toplists_id, toplists_name, toplists_year, toplists_type_wine) VALUES (?, ?, ?,?)"
    )

    # Dim Flavor groups
    transfer_data_to_olap(
        message="Creating Dim_flavor_groups in OLAP data warehouse...",
        oltp_select_query="""
            SELECT DISTINCT group_name 
            FROM keywords_wine;
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Dim_flavor_groups;
        CREATE TABLE Dim_flavor_groups (
            flavor_groups_id INTEGER PRIMARY KEY,
            flavor_groups_name VARCHAR
        );
        """,
        olap_insert_query="INSERT INTO Dim_flavor_groups (flavor_groups_name) VALUES (?)"
    )

    # Dim keywords
    transfer_data_to_olap(
        message="Creating Dim_keywords in OLAP data warehouse...",
        oltp_select_query="""
        SELECT DISTINCT id, name
        FROM keywords;
    """,
        olap_table_creation="""
    DROP TABLE IF EXISTS Dim_keywords;
    CREATE TABLE Dim_keywords (
        keywords_id INTEGER PRIMARY KEY,
	    keywords_name VARCHAR
    );
    """,
        olap_insert_query="INSERT INTO Dim_keywords (keywords_id, keywords_name) VALUES (?,?)"
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
            fk_country_code VARCHAR,
            ratings_avg INTEGER,
            ratings_count INTEGER,
            calc_avg_price INTEGER,
            calc_weighted_rating INTEGER,
            PRIMARY KEY (fk_wine_id),
            FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
            FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code)
            );
        """,
        olap_insert_query="INSERT INTO Fact_wines (fk_wine_id, fk_country_code, ratings_avg, ratings_count, calc_avg_price, calc_weighted_rating) VALUES (?, ?, ?, ?, ?, ?)"
    )

    # Fact Vintages
    transfer_data_to_olap(
        message="Creating Fact_vintages in OLAP data warehouse...",
        oltp_select_query="""
        WITH important_toplist AS (
            SELECT 
                vtr.vintage_id, 
                MAX(tl.id) as toplist_id, 
                MAX(SUBSTR(tl.name, 10, 4)) as toplist_year
            FROM toplists tl
            JOIN vintage_toplists_rankings vtr ON tl.id  = vtr.top_list_id
            GROUP BY vtr.vintage_id
		),
        toplist_rank AS (
            SELECT 
                itl.vintage_id as vintage_id, 
                itl.toplist_year, 
                vtr.rank as rank, toplist_id
            FROM important_toplist itl
            JOIN vintage_toplists_rankings vtr
            ON vtr.vintage_id = itl.vintage_id AND itl.toplist_id = vtr.top_list_id 
            )
        
        SELECT
            v.id,
            v.wine_id,
            r.country_code,
            v.ratings_average,
            v.ratings_count,
            v.year,
            v.price_euros,
            tlr.toplist_id,
            tlr.rank
        FROM
            vintages v
        JOIN
            wines w ON w.id = v.wine_id JOIN
            regions r ON w.region_id = r.id
            LEFT JOIN toplist_rank tlr ON tlr.vintage_id = v.id;
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_vintages;
        CREATE TABLE Fact_vintages (
            fk_vintages_id INTEGER,
            fk_wine_id INTEGER,
            fk_country_code INTEGER,
            fk_last_toplist INTEGER,
            ratings_avg INTEGER,
            ratings_count INTEGER,
            year INTEGER,
            price_euros INTEGER,
            last_rank INTEGER,

            PRIMARY KEY (fk_vintages_id),
            FOREIGN KEY (fk_vintages_id) REFERENCES Dim_vintages(vintages_id),
            FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
            FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code),
            FOREIGN KEY (fk_last_toplist) REFERENCES Dim_toplists(toplists_id)
        );
        """,
        olap_insert_query="INSERT INTO Fact_vintages (fk_vintages_id, fk_wine_id, fk_country_code, ratings_avg, ratings_count, year, price_euros, fk_last_toplist, last_rank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)"
    )    

    # Fact keywords wine
    transfer_data_to_olap(
        message="Creating Fact_keywords_wine in OLAP data warehouse...",
        oltp_select_query="""
        SELECT DISTINCT 
            kw.keyword_id, 
            fg.name, 
            kw.wine_id, 
            kw.count  
        FROM keywords_wine kw
        JOIN flavor_groups fg ON kw.group_name = fg.name
        """,
        olap_table_creation="""
        DROP TABLE IF EXISTS Fact_keywords_wine;
        CREATE TABLE Fact_keywords_wine (
            keyword_id INTEGER,
            fk_flavor_groups VARCHAR,
            fk_wine_id INTEGER,
            count_keyword INTEGER, 

            PRIMARY KEY (fk_wine_id, fk_flavor_groups, keyword_id),	
            FOREIGN KEY (keyword_id) REFERENCES Dim_keywords (keywords_id),
            FOREIGN KEY (fk_flavor_groups) REFERENCES Dim_flavor_groups (flavor_groups_id),
            FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id)

        );
        """,
        olap_insert_query="INSERT INTO Fact_keywords_wine (keyword_id, fk_flavor_groups, fk_wine_id, count_keyword) VALUES (?, ?, ?, ?)"
    )

    # Create view that and aggregation from vintages. It shows a summary of measures (name, number of vintages,
    # number of reviews, avg weighted price, country and sales = sum(review_count*price))
    execute_sql(
        message="Creating view sales_per_wine in OLAP data warehouse...",
        sql_query="""
        CREATE VIEW sales_per_wine AS
        WITH Sales_vintage AS (
            SELECT dw.wine_name AS name, 
            fv.ratings_count AS volume, 
            (fv.ratings_count* fv.price_euros) AS sales_euro, 
            fv.fk_country_code AS country, 
            fv.ratings_avg as rating
            FROM Fact_vintages fv  
            JOIN Dim_wines dw ON dw.wine_id = fv.fk_wine_id)
    
        SELECT 
            name, 
            COUNT(name) AS numb_vintages, 
            country, 
            ROUND(AVG(rating),1) as avg_rating, 
            SUM(volume) AS total_count, 
            ROUND(SUM(sales_euro),0) AS total_sale, 
            ROUND(SUM(sales_euro)/SUM(volume),0) AS average_weighted_price
            FROM Sales_vintage
        GROUP BY name
        ORDER BY total_sale DESC, total_count DESC 
        """
    )


if __name__ == "__main__":
    main()
    # from config import Config
    # print(Config.BASE_DIR)
