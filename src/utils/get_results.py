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
