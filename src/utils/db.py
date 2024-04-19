import sqlite3

import pandas as pd

from config import Config


def transfer_data_to_olap(message, oltp_select_query, olap_table_creation, olap_insert_query):
    print(message)

    # Connect to the source database
    source_conn = sqlite3.connect(Config.PATH_FIXED_DATABASE)
    source_cursor = source_conn.cursor()

    # Execute the SELECT query
    source_cursor.execute(oltp_select_query)
    data = source_cursor.fetchall()

    # Connect to the destination database
    destination_conn = sqlite3.connect(Config.PATH_OLAP_DATABASE)
    destination_cursor = destination_conn.cursor()

    destination_cursor.executescript(olap_table_creation)
    # Execute the INSERT query for each row
    for row in data:
        destination_cursor.execute(olap_insert_query, row)

    # Commit changes to the destination database and close connections
    destination_conn.commit()
    source_conn.close()
    destination_conn.close()


def select_query_to_pandas(query):
    conn = sqlite3.connect(Config.PATH_OLAP_DATABASE)
    df = pd.read_sql_query(query, conn)
    conn.close()
    return df


def execute_sql(message, sql_query):
    print(message)
    conn = sqlite3.connect(Config.PATH_OLAP_DATABASE)
    cursor = conn.cursor()
    cursor.execute(sql_query)
    conn.commit()
    conn.close()
