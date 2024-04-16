-- JUST CREATING THE STAR TABLE FOR THE QUERRIES, THIS WILL BE REDUDANT AT THE END
-- Dimension Tables

CREATE TABLE Dim_wines (
  wine_id INTEGER PRIMARY KEY,
  wine_name VARCHAR
);

CREATE TABLE Dim_vintages (
  vintage_id INTEGER PRIMARY KEY,
  vintage_name VARCHAR
);

CREATE TABLE Dim_regions (
  region_id INTEGER PRIMARY KEY,
  fk_country_id INTEGER,
  region_name VARCHAR
);

CREATE TABLE Dim_countries (
  country_code VARCHAR PRIMARY KEY,
  country_name VARCHAR
);

-- Fact Table
CREATE TABLE Fact_vintages (
  fk_wine_id INTEGER,
  fk_vintages_id INTEGER,
  fk_region_id INTEGER,
  fk_country_code INTEGER,
  year_harvest INTEGER,
  ratings_average INTEGER,
  ratings_count INTEGER,
  price_euros INTEGER,  
  
  PRIMARY KEY (fk_vintages_id),
  FOREIGN KEY (fk_vintages_id) REFERENCES Dim_vintages (vintage_id),
  FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
  FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
  FOREIGN KEY (fk_country_code) REFERENCES Dim_countries(country_code)
);

-- Populating the above schema
INSERT INTO Dim_countries (country_code, country_name)
SELECT DISTINCT code, name
FROM countries;

INSERT INTO Dim_regions (region_id, fk_country_id, region_name)
SELECT DISTINCT id, country_code, name
FROM regions;

INSERT INTO Dim_wines (wine_id, wine_name)
SELECT DISTINCT id, name
FROM wines ;

INSERT INTO Dim_vintages (vintage_id, vintage_name)
SELECT DISTINCT id, name
FROM vintages

INSERT INTO Fact_vintages (fk_wine_id,fk_vintages_id, fk_region_id, fk_country_code, year_harvest, ratings_average, ratings_count, price_euros)
SELECT
    v.wine_id,
    v.id,
    w.region_id, -- think about this
    r.country_code, -- think about this
    v.year,
    v.ratings_average,
    v.ratings_count, 
    v.price_euros
    
FROM
    vintages v
JOIN
	wines w ON w.id = v.wine_id,
    regions r ON w.region_id = r.id;


-- HERE STARTS THE QUERRIES FOR THE QUESTIONS

--CREATES VIEW THAT AGGREGATES INFORMATION TO MEASURE "SALES"

CREATE VIEW sales_per_wine AS
    -- THIS TEMP TABLE IS PER VINTAGE, USED LATER TO AGGREGATE PER WINE
	WITH Sales_vintage AS (
		SELECT dw.wine_name AS name, 
		fv.ratings_count AS volume, 
		(fv.ratings_count* fv.price_euros) AS sales_euro, 
		fv.fk_country_code AS country, 
		fv.ratings_average as rating
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

-- START WITH QUESTIONS

-- Second quesiton:
-- Q: We have a limited marketing budget for this year. Which country should we prioritise and why?
-- Solution:

CREATE VIEW Question_2 AS
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

-- ANSWER: 
-- FRANCE MOST USERS BUY FRENCH WINES AND THEY SPEND THE MOST WITH THEM
-- AT THE SAME TIME, ITALY has more brand of wines, more vintages
-- Italy sells more volume but the price is cheap
-- R: Promote italy to drive prices up, france doesn't need more promoting.