-- Question 1 answer

SELECT
    w.wine_name,
    f.ratings_count * f.ratings_avg * f.calc_avg_price AS score
FROM
    Fact_wines f
JOIN
    Dim_wines w ON f.fk_wine_id = w.wine_id
ORDER BY
    score DESC
LIMIT 10;
