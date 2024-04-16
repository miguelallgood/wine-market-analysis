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

-- Question 6 answer
-- wines average rating per country
SELECT
    dc.country_name,
    AVG(fw.ratings_avg) AS avg_rating
FROM
    Fact_wines fw
JOIN
    Dim_countries dc ON fw.fk_country_id = dc.country_code
GROUP BY
    dc.country_name;
