import argparse
import shutil
import sqlite3

from config import Config


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
    print(Config.PATH_FIXED_DATABASE)
    print(Config.PATH_OLAP_DATABASE)
    print("Updating OLAP data warehouse...")


if __name__ == "__main__":
    main()
    # from config import Config
    # print(Config.BASE_DIR)