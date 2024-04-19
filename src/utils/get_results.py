import pandas as pd

from utils.db import select_query_to_pandas


def highlight_top_wines(df):
    """
    Highlights 10 wines to increase sales based on specific criteria such as sales trends,
    ratings, and uniqueness.
    """
    return pd.DataFrame()  # This will eventually return a DataFrame


def prioritize_country(df):
    """
    Determines which country to prioritize for marketing based on factors like market potential,
    current sales trends, and budget constraints.
    """
    # Logic to be implemented later
    return pd.DataFrame()  # This will eventually return a DataFrame


def award_best_wineries():
    """
    Selects 3 wineries to give awards based on criteria such as quality of wine,
    innovation, and contribution to the wine industry.
    """
    df_results = select_query_to_pandas("""
    SELECT dwn.name, fw.num_of_wines, fw.avg_rating, fw.total_ratings, fw.avg_price
    FROM Fact_Wineries fw LEFT JOIN Dim_Winery_Name dwn ON fw.winery = dwn.id 
    ORDER BY fw.overal_score DESC 
    LIMIT 3  
    """)
    return df_results


def find_wines_by_taste(df, keywords, min_users=10):
    """
    Finds all wines that match specific taste keywords confirmed by at least a given number of users.
    """
    # Logic to be implemented later
    return pd.DataFrame()  # This will eventually return a DataFrame


def select_common_grapes_wines(df):
    """
    Identifies the top 3 most common grapes worldwide and lists the top 5 best-rated wines
    for each grape.
    """
    # Logic to be implemented later
    return pd.DataFrame()  # This will eventually return a DataFrame


def create_country_vintage_visual():
    """
    Creates visuals for the average wine rating by country and by vintage.
    """
    df_results = select_query_to_pandas("""
        SELECT
            dc.country_name,
            AVG(fw.ratings_avg) AS avg_rating
        FROM
            Fact_wines fw
        JOIN
            Dim_countries dc ON fw.fk_country_code = dc.country_code
        GROUP BY
            dc.country_name; 
        """)
    return df_results

def recommend_cabernet_sauvignon():
    """
    Recommends the top 5 Cabernet Sauvignon wines to a VIP client based on ratings and reviews.
    """
    df_results = select_query_to_pandas("""
        SELECT 
            dw.wine_name AS wine_name, fw.ratings_avg, fw.ratings_count
        FROM 
            Fact_wines fw
        INNER JOIN 
            Dim_wines dw ON dw.wine_id = fw.fk_wine_id
        WHERE 
            dw.wine_name LIKE 'Cabernet Sauvignon%'  -- Focus on relevant keywords
        OR 
            dw.wine_name LIKE '%Blend%' 
        ORDER BY 
            fw.ratings_avg DESC, fw.ratings_count DESC -- Order results by ratings_average and ratings_count
        LIMIT 5; 
    """)
    return df_results


if __name__ == "__main__":
    print(award_best_wineries())
