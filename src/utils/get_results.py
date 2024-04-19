import pandas as pd

from utils.db import select_query_to_pandas


def highlight_top_wines_1():
    """
    Highlights 10 wines to increase sales based on specific criteria such as sales trends,
    ratings, and uniqueness.
    """
    df_results = select_query_to_pandas("""
    --SELECT name, ROUND(numb_vintages *total_count* avg_rating) AS measure, average_weighted_price, avg_rating, total_count, total_sale, numb_vintages  
    SELECT id, name, ROUND(numb_vintages *total_count* avg_rating/1000000) AS measure, average_weighted_price, numb_vintages, avg_rating, total_count, total_sale 
    FROM sales_per_wine spw
    ORDER BY measure DESC
    LIMIT 10
    """)
    return df_results


def highlight_top_wines_2():
    """
    Highlights 10 wines to increase sales based on specific criteria such as sales trends,
    ratings, and uniqueness.
    """
    df_results = select_query_to_pandas("""
    WITH top_types AS (
        SELECT fv.fk_wine_id AS wine_id, SUM(fv.ratings_count) as total_reviews, dt.toplists_type_wine as type_wine
        FROM Fact_vintages fv 
        JOIN Dim_toplists dt ON dt.toplists_id = fv.fk_last_toplist
        GROUP BY fv.fk_wine_id
        ORDER BY total_reviews DESC
    )
    
    SELECT top_types.wine_id, dw.wine_name, spw.total_count , type_wine, spw.average_weighted_price, spw.numb_vintages, spw.total_sale  
    FROM top_types
    JOIN Dim_wines dw ON dw.wine_id = top_types.wine_id
    JOIN sales_per_wine spw ON spw.name = dw.wine_name
    WHERE type_wine IN (SELECT DISTINCT type_wine
    FROM top_types
    LIMIT 5) 
    AND numb_vintages > 5
    ORDER BY total_count DESC
    LIMIT 10
    """)
    return df_results


def prioritize_country():
    """
    Q2: Determines which country to prioritize for marketing based on factors like market potential,
    current sales trends, and budget constraints.
    Approach: See which countries bring the most revenue, and general metrics for comparing as number of wines, harvests, reviews, avg price.
    """
    df_results = select_query_to_pandas("""
    SELECT 
        dc.country_name AS country,  
        COUNT(spw.name) AS count_wines,
        SUM (spw.numb_vintages) AS count_vintages,
        SUM(spw.total_count) AS sum_ratings_count, 
        SUM(spw.total_sale) as sum_sales_euro, 
        ROUND(AVG (spw.average_weighted_price)) AS avg_price_bottle
    FROM sales_per_wine spw
    JOIN Dim_countries dc ON dc.country_code = spw.country 
    GROUP BY spw.country

    ORDER BY sum_sales_euro DESC
    LIMIT 5
    """)
    return df_results


def award_best_wineries():
    """
    Selects 3 wineries to give awards based on criteria such as quality of wine,
    innovation, and contribution to the wine industry.
    """
    df_results = select_query_to_pandas("""
    SELECT dwn.winery_name, fw.num_of_wines, fw.avg_rating, fw.total_ratings, fw.avg_price
    FROM Fact_Wineries fw LEFT JOIN Dim_Wineries dwn ON fw.fk_winery_id = dwn.winery_id 
    ORDER BY fw.overal_score DESC 
    LIMIT 3  
    """)
    return df_results


def find_wines_by_taste():
    """
    Q4: Finds all wines that match specific taste keywords confirmed by at least a given number of users.
    Approach: find all wines that match all the listed flavors.
    """
    df_results = select_query_to_pandas("""
    WITH filtered_fact_keywords_wine AS (
        SELECT 
            DISTINCT fkw.keyword_id, 
            dk.keywords_name AS key_word, 
            fkw.fk_wine_id AS wine_id, 
            fkw.count_keyword,
            dw.wine_name AS wine        
        FROM Fact_keywords_wine fkw 
        JOIN Dim_keywords dk 
            ON dk.keywords_id = fkw.keyword_id 
        JOIN Dim_wines dw 
            ON dw.wine_id = fkw.fk_wine_id 
        WHERE dk.keywords_name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
            AND fkw.count_keyword >=10
    ),
    match_all AS (
        SELECT 
            wine_id, 
            wine, COUNT(key_word) AS n_matched_flavors, 
            GROUP_CONCAT(key_word, ', ') AS matched_flavors
        FROM filtered_fact_keywords_wine
        GROUP BY wine_id
        HAVING n_matched_flavors = 5
        ORDER BY n_matched_flavors DESC, wine ASC
    )
    SELECT wine_id, wine
    FROM match_all
    """)
    return df_results 


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


def create_country_vintage_visual_1():
    """
    Creates visuals for the average wine rating by country and by vintage.
    """

    sql = """
        SELECT
            dc.country_name,
            AVG(fw.ratings_avg) AS avg_rating
        FROM
        Fact_wines fw
        JOIN
            Dim_countries dc ON fw.fk_country_code = dc.country_code
        GROUP BY
            dc.country_name;
    """
    df_results = select_query_to_pandas(sql)
    return df_results

def create_country_vintage_visual_2():
    """
    Creates visuals for the average wine rating by country and by vintage.
    """

    sql = """
        SELECT
            dc.country_name,fv.year,
            AVG(fv.ratings_avg) AS avg_rating
        FROM
        Fact_vintages fv
        JOIN
            Dim_countries dc ON fv.fk_country_code = dc.country_code
        GROUP BY
            dc.country_name, fv.year;
    """
    df_results = select_query_to_pandas(sql)
    return df_results


def recommend_cabernet_sauvignon():
    """
    Recommends the top 5 Cabernet Sauvignon wines to a VIP client based on ratings and reviews.
    """

    sql = """
        SELECT dw.wine_name AS wine_name, fw.ratings_avg, fw.ratings_count
        FROM Fact_wines fw
        INNER JOIN Dim_wines dw ON dw.wine_id = fw.fk_wine_id
        WHERE dw.wine_name LIKE 'Cabernet Sauvignon%'  
        OR dw.wine_name LIKE '%Blend%' 
        ORDER BY fw.ratings_avg DESC, fw.ratings_count DESC
        LIMIT 5;
        """
    df_results = select_query_to_pandas(sql)

    # Logic to be implemented later
    return df_results


if __name__ == "__main__":
    print(award_best_wineries())
