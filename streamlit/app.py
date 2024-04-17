import streamlit as st
import sqlite3
import pandas as pd

# Function to fetch data from SQLite database
def fetch_data():
    conn = sqlite3.connect('./db/vivino.db')  # Replace 'your_database.db' with your SQLite database file
    cursor = conn.cursor()
    query = """
        SELECT w.name AS wine_name, w.ratings_average, w.ratings_count
        FROM wines w
        INNER JOIN wine_grape_fact wg ON w.id = wg.wine_id
        INNER JOIN grapes g ON wg.grape_id = g.id
        WHERE g.name = 'Cabernet Sauvignon'
        ORDER BY w.ratings_average DESC
        LIMIT 5;
    """
    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()
    return rows

# Main function to create Streamlit app
def main():
    st.title('Top 5 Recommended Wines')
    
    # Fetch data from database
    data = fetch_data()
    
    # Convert data to DataFrame
    df = pd.DataFrame(data, columns=['Wine Name', 'Ratings Average', 'Ratings Count'])
    
    # Apply color formatting to the table
    st.dataframe(df.style.highlight_max(axis=0, subset=['Ratings Average', 'Ratings Count'], color='lightgreen'))

if __name__ == "__main__":
    main()
