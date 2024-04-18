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


# noinspection SqlDialectInspection,SqlNoDataSourceInspection
def select_common_grapes_wines():
    """
    Identifies the top 3 most common grapes worldwide and lists the top 5 best-rated wines
    for each grape.
    """
    sql = """
    WITH 
        top3grapes AS(
    SELECT 
        dg.grape_name AS grape_name 
    FROM 
        Fact_grapes fg 
    JOIN 
        Dim_grapes dg ON dg.grape_id = fg.fk_grape_id 
    GROUP BY fg.fk_grape_id
    ORDER BY fg.wines_count DESC 
    LIMIT 3
    ),
        
        wineratings AS(
    SELECT 
        dw.wine_name,
        fw.calc_weighted_rating AS weighted_rating
    FROM
        Fact_wines fw 
    JOIN
        Dim_wines dw ON dw.wine_id = fw.fk_wine_id 
    )
    
    SELECT
        grape_name,
        wine_name,
        rating
    FROM
        (
            SELECT
                tgn.grape_name AS grape_name,
                wr.wine_name AS wine_name,
                wr.weighted_rating AS rating,            
                ROW_NUMBER() OVER(PARTITION BY tgn.grape_name ORDER BY wr.weighted_rating DESC) AS row_num
                
            FROM
                top3grapes tgn
            JOIN
                wineratings wr ON wr.wine_name LIKE '%' || tgn.grape_name || '%'
        ) AS ranked_wines
    WHERE
        row_num <= 5;
    """
    df_results = select_query_to_pandas(sql)

    # Logic to be implemented later
    return df_results


def create_country_vintage_visual(df):
    """
    Creates visuals for the average wine rating by country and by vintage.
    """
    # Logic to be implemented later
    return pd.DataFrame()  # Placeholder for a DataFrame containing the visuals


def recommend_cabernet_sauvignon(df):
    """
    Recommends the top 5 Cabernet Sauvignon wines to a VIP client based on ratings and reviews.
    """
    # Logic to be implemented later
    return pd.DataFrame()  # This will eventually return a DataFrame


if __name__ == "__main__":
    print(award_best_wineries())
