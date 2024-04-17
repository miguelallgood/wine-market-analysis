import sqlite3
from config import Config


def transfer_data(message, select_query, table_creation, insert_query):
    print(message)

    # Connect to the source database
    source_conn = sqlite3.connect(Config.PATH_FIXED_DATABASE)
    source_cursor = source_conn.cursor()

    # Execute the SELECT query
    source_cursor.execute(select_query)
    data = source_cursor.fetchall()

    # Connect to the destination database
    destination_conn = sqlite3.connect(Config.PATH_OLAP_DATABASE)
    destination_cursor = destination_conn.cursor()

    destination_cursor.executescript(table_creation)
    # Execute the INSERT query for each row
    for row in data:
        destination_cursor.execute(insert_query, row)

    # Commit changes to the destination database and close connections
    destination_conn.commit()
    source_conn.close()
    destination_conn.close()


if __name__ == '__main__':
    transfer_data(
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
