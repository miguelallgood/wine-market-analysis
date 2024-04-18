-- Create Schema

-- Dimension Tables

CREATE TABLE Dim_regions (
  region_id INTEGER PRIMARY KEY,
  fk_country_id INTEGER,
  region_name VARCHAR
);

CREATE TABLE Dim_countries (
  country_code VARCHAR PRIMARY KEY,
  country_name VARCHAR
);

CREATE TABLE Dim_wines (
  wine_id INTEGER PRIMARY KEY,
  wine_name VARCHAR
);

CREATE TABLE Dim_vintages (
  vintage_id INTEGER PRIMARY KEY,
  vintage_name VARCHAR
);


CREATE TABLE Dim_toplists (
	toplists_id INTEGER PRIMARY KEY,
	toplists_name VARCHAR,
	toplists_year INTEGER,
	toplists_type_wine VARCHAR	
	);

CREATE TABLE Dim_flavor_groups (
	flavor_groups_id INTEGER PRIMARY KEY,
	flavor_groups_name VARCHAR
);

CREATE TABLE Dim_keywords (
	keywords_id INTEGER PRIMARY KEY,
	keywords_name VARCHAR
);

-- Fact Tables
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


CREATE TABLE Fact_vintages (
  fk_wine_id INTEGER,
  fk_vintages_id INTEGER,
  fk_region_id INTEGER,
  fk_country_code INTEGER,
  fk_last_toplist INTEGER,
  year_harvest INTEGER,
  ratings_average INTEGER,
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

-- Inserts

-- Dimentions

INSERT INTO Dim_countries (country_code, country_name)
SELECT DISTINCT code, name
FROM countries;

INSERT INTO Dim_regions (region_id, fk_country_id, region_name)
SELECT DISTINCT id, country_code, name
FROM regions;

--OK
INSERT INTO Dim_wines (wine_id, wine_name)
SELECT DISTINCT id, name
FROM wines ;

INSERT INTO Dim_vintages (vintage_id, vintage_name)
SELECT DISTINCT id, name
FROM vintages;

INSERT INTO Dim_flavor_groups (flavor_groups_name)
SELECT DISTINCT group_name 
FROM keywords_wine;

INSERT INTO Dim_keywords (keywords_id, keywords_name)
SELECT DISTINCT id, name
FROM keywords;

INSERT INTO Dim_toplists (toplists_id, toplists_name, toplists_year, toplists_type_wine)
SELECT 
	id,
	name,	
    SUBSTRING(name, 10, 4),
    TRIM(SUBSTRING(name, CHARINDEX(':', name)+1,100))
FROM 
   toplists 
 WHERE country_code = 'global' AND name LIKE '%Vivino%';
-- Facts

INSERT INTO Fact_keywords_wine (keyword_id, fk_flavor_groups, fk_wine_id, count_keyword)
SELECT DISTINCT kw.keyword_id, dfg.flavor_groups_id, kw.wine_id, kw.count  
FROM keywords_wine kw
JOIN Dim_flavor_groups dfg ON kw.group_name = dfg.flavor_groups_name


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



-- Querries

--Q1: We want to highlight 10 wines to increase our sales. Which ones should we choose and why?
-- We want to set a little equation to see how diverse, of good quality, popular and revenue generator is a wine
-- 79% of winelovers have no brand loyalty https://www.morningadvertiser.co.uk/Article/2015/09/17/79-of-wine-drinkers-don-t-have-any-brand-loyalty


SELECT name, ROUND(numb_vintages *total_count* avg_rating) AS measure, average_weighted_price, avg_rating, total_count, total_sale, numb_vintages  
FROM sales_per_wine spw
ORDER BY measure DESC


-- second solution:
-- Get the top 5 types of wine with the most reviews and return a list of 10 popular wines,
--  inside those types that have a decent number of vintages
-- Reasoning being: people change brands all the time, but like to keep to the same type of wines
-- So if someone tried one of those, maybe they can try another one

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


-- Second quesiton:
-- We have a limited marketing budget for this year. Which country should we prioritise and why?
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
-- I would promote italy to drive prices up.


/*We detected that a big cluster of customers likes a specific combination of tastes. 
 We identified a few keywords that match these tastes: 
 coffee, toast, green apple, cream, and citrus. 
 We would like you to find all the wines that are related to these keywords. 
 Check that at least 10 users confirm those keywords, 
 to ensure the accuracy of the selection. 
 Additionally, identify an appropriate group name for this cluster.
*/

-- ANSWER PART 1:
-- WINES THAT MATCH ONE OR MORE OF THE FLAVORS
-- MOST OF THE MATCHES FOR ALL FLAVORS ARE BRUT CHAMPAGNES

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
-- n_matched_flavors =5


    
-- SECOND PART OF THE QUESTION: IDENTIFY GOOD FLAVOR GROUP NAME FOR THIS LIST OF FLAVORS
    
-- FIRST APPROACH IS TO STUDY THE GROUPS FOR THOSE KEYWORDS AND SEE THE OCCURENCES
    
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

-- SECOND APPROACH IS TO LOOK AT THE GROUPS FOR THE WINES PREVIOUSLY SELECTED

WITH selected_wines AS (
SELECT DISTINCT dw.wine_name AS wine, dw.wine_id AS wine_id
FROM Fact_keywords_wine fkw 
JOIN Dim_keywords dk ON dk.keywords_id = fkw.keyword_id 
JOIN Dim_wines dw ON dw.wine_id = fkw.fk_wine_id 
WHERE dk.keywords_name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus') AND fkw.count_keyword >=10
GROUP BY wine
HAVING COUNT(DISTINCT dk.keywords_name) = 5
ORDER BY wine ASC
)
SELECT DISTINCT dfg.flavor_groups_name, count (dfg.flavor_groups_name) as counting 
FROM Dim_flavor_groups dfg 
JOIN Fact_keywords_wine fkw ON fkw.fk_flavor_groups = dfg.flavor_groups_id 
JOIN selected_wines sw ON sw.wine_id = fkw.fk_wine_id
GROUP BY dfg.flavor_groups_name 
ORDER BY counting DESC



WITH selected_wines AS (
SELECT DISTINCT dw.wine_name AS wine, dw.wine_id AS wine_id
FROM Fact_keywords_wine fkw 
JOIN Dim_keywords dk ON dk.keywords_id = fkw.keyword_id 
JOIN Dim_wines dw ON dw.wine_id = fkw.fk_wine_id 
WHERE dk.keywords_name IN ('coffee', 'toast', 'green apple', 'cream', 'citrus') AND fkw.count_keyword >=10
GROUP BY wine
HAVING COUNT(DISTINCT dk.keywords_name) = 5
ORDER BY wine ASC
)
SELECT DISTINCT dfg.flavor_groups_name, sw.wine, sw.wine_id 
FROM Dim_flavor_groups dfg 
JOIN Fact_keywords_wine fkw ON fkw.fk_flavor_groups = dfg.flavor_groups_id 
JOIN selected_wines sw ON sw.wine_id = fkw.fk_wine_id

-- Third approach is just to say most of the wines in the 19 that matched all the flavors
-- are champagne brut and that's what we are going to recommend the clients
