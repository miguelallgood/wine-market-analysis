---- We would like to create a country leaderboard. 
---- Come up with a visual that shows the average wine rating for each country. 
---- Do the same for the vintages.
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
