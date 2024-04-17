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


CREATE TABLE Dim_flavor_groups (
	flavor_groups_id INTEGER PRIMARY KEY,
	flavor_groups_name VARCHAR
);

CREATE TABLE Dim_keywords (
	keywords_id INTEGER PRIMARY KEY,
	keywords_name VARCHAR
);

CREATE TABLE Fact_keywords_wine (
	keyword_id INTEGER,
	fk_flavor_groups INTEGER,
	fk_wine_id INTEGER,
	count_keyword INTEGER, 

	PRIMARY KEY (fk_wine_id,fk_flavor_groups,keyword_id),	
	FOREIGN KEY (keyword_id) REFERENCES Dim_keywords (keywords_id),
	FOREIGN KEY (fk_flavor_groups) REFERENCES Dim_flavor_groups (flavor_groups_id),
	FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id)
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


INSERT INTO Dim_keywords (keywords_id, keywords_name)
SELECT DISTINCT id, name
FROM keywords;


INSERT INTO Dim_flavor_groups (flavor_groups_name)
SELECT DISTINCT group_name 
FROM keywords_wine;


INSERT INTO Fact_keywords_wine (keyword_id, fk_flavor_groups, fk_wine_id, count_keyword)
SELECT DISTINCT kw.keyword_id, dfg.flavor_groups_id, kw.wine_id, kw.count  
FROM keywords_wine kw
JOIN Dim_flavor_groups dfg ON kw.group_name = dfg.flavor_groups_name


-- HERE STARTS THE QUERIES FOR THE QUESTIONS

--CREATES VIEW THAT AGGREGATES INFORMATION TO MEASURE "SALES" THIS IS USED IN Q1 AND Q2

CREATE VIEW sales_per_wine AS
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


-- Q2: We have a limited marketing budget for this year. Which country should we prioritise and why?
/* ANSWER: 
FRANCE MOST USERS BUY FRENCH WINES AND THEY SPEND THE MOST WITH THEM
AT THE SAME TIME, ITALY has more brand of wines, more vintages
Italy sells more volume but the price is cheap
R: Promote italy to drive prices up, france doesn't need more promoting.*/
-- Query:

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


/* Q4:
 We detected that a big cluster of customers likes a specific combination of tastes. 
 We identified a few keywords that match these tastes: 
 coffee, toast, green apple, cream, and citrus. 
 1- We would like you to find all the wines that are related to these keywords. 
 Check that at least 10 users confirm those keywords, 
 to ensure the accuracy of the selection. 
 2- Additionally, identify an appropriate group name for this cluster.
*/

/* ANSWER PART 1: 
  There are 19 wines that match all those flavors.
*/ 
-- Query:
/* First we do a temporary table to:
 * Remove duplicated rows of wine, keyword, count of keyword in Fact_keywords_wine
 * the reson why there is this duplication is because they have different group_flavor
 * Aka: when the website classified a keyword from a review, 
 * it put sometimes into two different groups. But of this analysis,
 * we don't care about group_flavor and just want to know distinct wine,keyword,count.
 * We also guarantee here the keyword is inside the list we want, 
 * and with a minimum count of 10
 */

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
/* Now with the view we select the wine, count how many times that keyword
 * appeared for this specific wine_id and create a column contatenating the matched strings.
 * It's good to see that some wines have the same name, but are different ids.
 */

SELECT wine_id, wine, COUNT(key_word) AS n_matched_flavors, GROUP_CONCAT(key_word, ', ') AS matched_flavors
FROM filtered_fact_keywords_wine
GROUP BY wine_id
ORDER BY n_matched_flavors DESC, wine ASC

--If necessaryt he above can be turned into a temp_table and we just get the 
-- n_matched_flavors =5 = TO BE DISCUSSED

/* ANSWER PART 2: 
  From the 19 wines most were Champagne Brut.
*/ 
    
-- Other approaches:   
-- Study the groups that usually match those keywords in all the wines, to guide the client
-- Answer: Citrus, Tree_fruit, Microbio, Oak, Non_oak
--Query:

    
WITH flavors_count AS(
SELECT 
    fkw.count_keyword AS occurences, 
    dk.keywords_name AS flavor, 
    dfg.flavor_groups_name AS groups
    FROM Fact_keywords_wine fkw 
    JOIN Dim_keywords dk ON dk.keywords_id = fkw.keyword_id
    JOIN  Dim_flavor_groups dfg ON dfg.flavor_groups_id = fkw.fk_flavor_groups 
    WHERE dk.keywords_name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus')
)

SELECT flavor, groups, SUM(occurences)
FROM flavors_count	
GROUP BY flavor, groups
