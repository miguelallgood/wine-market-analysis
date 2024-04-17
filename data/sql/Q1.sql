-- We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
-- Question 1 answer
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