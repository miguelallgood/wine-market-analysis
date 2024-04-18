-- INSERT INTO Dim_wines (wine_id, wine_name)
-- SELECT DISTINCT id, name
-- FROM wines ;

-- INSERT INTO Dim_regions (region_id, fk_country_code, region_name)
-- SELECT DISTINCT id, country_code, name
-- FROM regions;

-- INSERT INTO Dim_countries (country_code, country_name)
-- SELECT DISTINCT code, name
-- FROM countries;

-- INSERT INTO Dim_vintages (vintages_id, vintages_name)
-- SELECT DISTINCT id, name
-- FROM vintages ;

-- INSERT INTO Dim_grapes (grape_id, grape_name)
-- SELECT DISTINCT id, name
-- FROM grapes;  


-- INSERT INTO Fact_wines (fk_wine_id, fk_region_id, fk_country_code, ratings_avg, ratings_count, calc_avg_price, calc_weighted_rating)
-- WITH avg_prices AS(  
--  	SELECT vintages.wine_id, avg(vintages.price_euros) AS price_avg
--  	FROM vintages
--  	GROUP BY vintages.wine_id
--  	)
-- SELECT
--     w.id,
--     w.region_id,
--     r.country_code,
--     w.ratings_average,
--     w.ratings_count, 
--     a.price_avg AS calc_avg_price,
--     w.ratings_count * w.ratings_average AS calc_weighted_rating 
-- FROM
--     wines w
-- JOIN
--     regions r ON w.region_id = r.id,
--     avg_prices a ON w.id = a.wine_id;


-- INSERT INTO Fact_vintages (fk_vintages_id, fk_wine_id, fk_region_id, fk_country_code, ratings_avg, ratings_count, year)
-- SELECT
--     v.id,
--     v.wine_id,
--     w.region_id,
--     r.country_code,
--     v.ratings_average,
--     v.ratings_count,
--     v.year
 
-- FROM
--     vintages v
-- JOIN
-- 	wines w ON w.id = v.wine_id,
-- 	regions r ON w.region_id = r.id;


-- INSERT INTO Fact_grapes (fk_grape_id, wines_count)
-- SELECT grape_id, wines_count
-- FROM most_used_grapes_per_country mugpc
-- GROUP BY grape_id; 
   
