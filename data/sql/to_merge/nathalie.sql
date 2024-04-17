----------------------------------------------------------------------------------------------------------------------
----- We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
----------------------------------------------------------------------------------------------------------------------
-- Question 1 answer ---- should be replaced by Andreas version
SELECT
    dw.wine_name, fw.fk_country_code, 
    fw.ratings_count * fw.ratings_avg * fw.calc_avg_price AS score
FROM
    Fact_wines fw
JOIN
    Dim_wines dw ON fw.fk_wine_id = dw.wine_id
ORDER BY
    score DESC
LIMIT 10;

----------------------------------------------------------------------------------------------------------------------
------ We would like to select wines that are easy to find all over the world. 
---- Find the top 3 most common grapes all over the world and for each grape, give us the the 5 best rated wines.
----------------------------------------------------------------------------------------------------------------------
-- Question 5 answers
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
   
----------------------------------------------------------------------------------------------------------------------   
---- We would like to create a country leaderboard. 
---- Come up with a visual that shows the average wine rating for each country. 
---- Do the same for the vintages.
----------------------------------------------------------------------------------------------------------------------
-- Question 6 answers
-- wines average rating per country
SELECT
    dc.country_name,
    AVG(fw.ratings_avg) AS avg_rating
FROM
    Fact_wines fw
JOIN
    Dim_countries dc ON fw.fk_country_code = dc.country_code
GROUP BY
    dc.country_name;

-- vintages average rating per country   
------- correct data first - Andrea Query
SELECT
    dc.country_name,fv.year,
    AVG(fv.ratings_avg) AS avg_rating
FROM
    Fact_vintages fv
JOIN
    Dim_countries dc ON fv.fk_country_code = dc.country_code
GROUP BY
    dc.country_name, fv.year;

