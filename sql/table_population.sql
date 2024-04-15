INSERT INTO Dim_countries (country_code, country_name)
SELECT DISTINCT code, name
FROM countries;

INSERT INTO Dim_regions (region_id, fk_country_id, region_name)
SELECT DISTINCT id, country_code, name
FROM regions;

INSERT INTO Dim_wines (wine_id, wine_name)
SELECT DISTINCT id, name
FROM wines ;

INSERT INTO Fact_wines (fk_wine_id, fk_region_id, fk_country_id, ratings_avg, ratings_count, calc_avg_price)
with avg_prices as(  
 	Select vintages.wine_id, avg(vintages.price_euros) as price_avg
 	from vintages
 	group by vintages.wine_id
 	)
SELECT
    w.id,
    w.region_id,
    w.ratings_average,
    w.ratings_count, 
    r.country_code,
    a.price_avg as calc_avg_price 
FROM
    wines w
JOIN
    regions r ON w.region_id = r.id,
    avg_prices a ON w.id = a.wine_id;
   

