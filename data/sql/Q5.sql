---- We would like to select wines that are easy to find all over the world. 
---- Find the top 3 most common grapes all over the world and for each grape, give us the the 5 best rated wines.
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
   
