--
--  Q1 -------------------------

CREATE VIEW sales_per_wine AS
	WITH Sales_vintage AS (
		SELECT dw.wine_name AS name, 
		fv.ratings_count AS volume, 
		(fv.ratings_count* fv.price_euros) AS sales_euro, 
		fv.fk_country_code AS country, 
		fv.ratings_avg as rating
		FROM Fact_vintages fv  
		JOIN Dim_wines dw ON dw.wine_id = fv.fk_wine_id)

	SELECT 
		name, 
		COUNT(name) AS numb_vintages, 
		country, 
		ROUND(AVG(rating),1) as avg_rating, 
		SUM(volume) AS total_count, 
		ROUND(SUM(sales_euro),0) AS total_sale, 
		ROUND(SUM(sales_euro)/SUM(volume),0) AS average_weighted_price
		FROM Sales_vintage
	GROUP BY name
	ORDER BY total_sale DESC, total_count DESC

-- First approach

SELECT name, ROUND(numb_vintages *total_count* avg_rating) AS measure, average_weighted_price, avg_rating, total_count, total_sale, numb_vintages  
FROM sales_per_wine spw
ORDER BY measure DESC
LIMIT 10


-- Second solution:

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


------------------------------------
-- Q2

SELECT 
	country,  
	COUNT(name) AS count_wines,
	SUM (numb_vintages) AS count_vintages,
	SUM(total_count) AS sum_ratings_count, 
	SUM(total_sale) as sum_sales_euro, 
	ROUND(AVG (average_weighted_price)) AS avg_price_bottle
FROM sales_per_wine spw
GROUP BY country
ORDER BY sum_sales_euro DESC
----------------------------------------

--Q 4:

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
)

SELECT wine_id, wine, COUNT(key_word) AS n_matched_flavors, GROUP_CONCAT(key_word, ', ') AS matched_flavors
FROM filtered_fact_keywords_wine
GROUP BY wine_id
HAVING n_matched_flavors = 5
ORDER BY n_matched_flavors DESC, wine ASC




----------------------------------
----------------------------------
--COde that was already merged, was to create the star schema


-- Create Schema

-- Dimension Tables

"""CREATE TABLE Dim_regions (
  region_id INTEGER PRIMARY KEY,
  fk_country_id INTEGER,
  region_name VARCHAR
);"""

"""CREATE TABLE Dim_countries (
  country_code VARCHAR PRIMARY KEY,
  country_name VARCHAR
);"""

"""CREATE TABLE Dim_wines (
  wine_id INTEGER PRIMARY KEY,
  wine_name VARCHAR
);
"""

-- In manage db it has a plural in the name
CREATE TABLE Dim_vintages (
  vintage_id INTEGER PRIMARY KEY, -- In manage db it has a plural in the name
  vintage_name VARCHAR-- In manage db it has a plural in the name
);


"""CREATE TABLE Dim_toplists (
	toplists_id INTEGER PRIMARY KEY,
	toplists_name VARCHAR,
	toplists_year INTEGER,
	toplists_type_wine VARCHAR	
	);
"""
"""CREATE TABLE Dim_flavor_groups (
	flavor_groups_id INTEGER PRIMARY KEY,
	flavor_groups_name VARCHAR
);"""
"""
CREATE TABLE Dim_keywords (
	keywords_id INTEGER PRIMARY KEY,
	keywords_name VARCHAR
);
"""
-- Fact Tables
"""CREATE TABLE Fact_keywords_wine (
	keyword_id INTEGER,
	fk_flavor_groups INTEGER,
	fk_wine_id INTEGER,
	count_keyword INTEGER, 

	PRIMARY KEY (fk_wine_id,fk_flavor_groups,keyword_id),	
	FOREIGN KEY (keyword_id) REFERENCES Dim_keywords (keywords_id),
	FOREIGN KEY (fk_flavor_groups) REFERENCES Dim_flavor_groups (flavor_groups_id),
	FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id)
);"""


"""CREATE TABLE Fact_vintages (
  fk_wine_id INTEGER,
  fk_vintages_id INTEGER,
  fk_region_id INTEGER,
  fk_country_code INTEGER,
  fk_last_toplist INTEGER,
  year_harvest INTEGER, -- change to year !!!
  ratings_average INTEGER, -- change to ratings_avg!!!
  ratings_count INTEGER,
  price_euros INTEGER,
  last_rank INTEGER,
  
  PRIMARY KEY (fk_vintages_id),
  FOREIGN KEY (fk_vintages_id) REFERENCES Dim_vintages (vintage_id),
  FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
  FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
  FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code),
  FOREIGN KEY (fk_last_toplist) REFERENCES Dim_toplists(toplists_id)
);
"""
-- Inserts

-- Dimentions

"""INSERT INTO Dim_countries (country_code, country_name)
SELECT DISTINCT code, name
FROM countries;
"""
"""INSERT INTO Dim_regions (region_id, fk_country_id, region_name)
SELECT DISTINCT id, country_code, name
FROM regions;"""

--OK
"""INSERT INTO Dim_wines (wine_id, wine_name)
SELECT DISTINCT id, name
FROM wines ;"""

"""INSERT INTO Dim_vintages (vintage_id, vintage_name)
SELECT DISTINCT id, name
FROM vintages;"""

"""INSERT INTO Dim_flavor_groups (flavor_groups_name)
SELECT DISTINCT group_name 
FROM keywords_wine;
"""
"""INSERT INTO Dim_keywords (keywords_id, keywords_name)
SELECT DISTINCT id, name
FROM keywords;"""


-- Facts

"""INSERT INTO Fact_keywords_wine (keyword_id, fk_flavor_groups, fk_wine_id, count_keyword)
SELECT DISTINCT kw.keyword_id, dfg.flavor_groups_id, kw.wine_id, kw.count  
FROM keywords_wine kw
JOIN Dim_flavor_groups dfg ON kw.group_name = dfg.flavor_groups_name"""


INSERT INTO Fact_vintages (fk_wine_id,fk_vintages_id, fk_region_id, fk_country_code, year_harvest, ratings_average, ratings_count, price_euros, fk_last_toplist, last_rank)
	WITH important_toplist AS (
		SELECT vtr.vintage_id, MAX(toplists_id) as toplist_id, MAX(toplists_year) as toplist_year
		FROM Dim_toplists dt 
		JOIN vintage_toplists_rankings vtr ON dt.toplists_id  = vtr.top_list_id
		GROUP BY vtr.vintage_id
		),
toplist_rank AS (
		SELECT itl.vintage_id as vintage_id, itl.toplist_year, vtr.rank as rank, toplist_id
		FROM important_toplist itl
		JOIN vintage_toplists_rankings vtr
		ON vtr.vintage_id = itl.vintage_id AND itl.toplist_id = vtr.top_list_id 
		)
SELECT
    v.wine_id,
    v.id,
    w.region_id, -- think about this
    r.country_code, -- think about this
    v.year,
    v.ratings_average,
    v.ratings_count, 
    v.price_euros,
    tlr.toplist_id,
    tlr.rank
    
FROM
    vintages v
JOIN
	wines w ON w.id = v.wine_id JOIN
    regions r ON w.region_id = r.id 
    LEFT JOIN toplist_rank tlr ON tlr.vintage_id = v.id

