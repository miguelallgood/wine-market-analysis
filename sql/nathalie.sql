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

-- Question 6 
-- wines average rating per country
-- ANSWER 
SELECT
    dc.country_name,
    AVG(fw.ratings_avg) AS avg_rating
FROM
    Fact_wines fw
JOIN
    Dim_countries dc ON fw.fk_country_id = dc.country_code
GROUP BY
    dc.country_name;

-- vintages average rating per country   
-- DIM/FACT: creation/population additional dim/facts tables    
CREATE TABLE Dim_vintages (
  vintages_id INTEGER PRIMARY KEY,
  vintages_name VARCHAR
);

INSERT INTO Dim_vintages (vintages_id, vintages_name)
SELECT DISTINCT id, name
FROM vintages ;

CREATE TABLE Fact_vintages (
  fk_vintages_id INTEGER,
  fk_wine_id INTEGER,
  fk_region_id INTEGER,
  fk_country_id INTEGER,
  ratings_avg INTEGER,
  ratings_count INTEGER,
  year INTEGER,
  PRIMARY KEY (fk_vintages_id),
  FOREIGN KEY (fk_vintages_id) REFERENCES Dim_vintages(vintages_id),
  FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
  FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
  FOREIGN KEY (fk_country_id) REFERENCES Dim_countries(country_id)
);

INSERT INTO Fact_vintages (fk_vintages_id, fk_wine_id, fk_region_id, fk_country_id, ratings_avg, ratings_count, year)
SELECT
    v.id,
    v.wine_id,
    w.region_id,
    r.country_code,
    v.ratings_average,
    v.ratings_count,
    v.year
 
FROM
    vintages v
JOIN
	wines w ON w.id = v.wine_id,
	regions r ON w.region_id = r.id

-- ANSWER 
SELECT
    dc.country_name,fv.year,
    AVG(fv.ratings_avg) AS avg_rating
FROM
    Fact_vintages fv
JOIN
    Dim_countries dc ON fv.fk_country_id = dc.country_code
GROUP BY
    dc.country_name, fv.year;

--- Question 5
---- !!!! Work in progress, queries are ok, but need refactoring with dim/fact tables
--- first create a view to fetch top3 grape names
CREATE VIEW top3_grape_names AS
WITH top3grapes as (
	SELECT 
		mugpc.grape_id,
		g.name, 
		mugpc.wines_count
	FROM most_used_grapes_per_country mugpc
	join grapes g on g.id = mugpc.grape_id 
	group by grape_id
	order by wines_count desc
	LIMIT 3
	)
SELECT name from top3grapes;


--- next use the view joined with the wines to fetch top5 ranked wines
SELECT
	grape_name,
    wine_name,
    rating
FROM
    (
        SELECT
            g.name AS grape_name,
            w.name AS wine_name,
            w.ratings_average AS rating,
            ROW_NUMBER() OVER(PARTITION BY g.name ORDER BY w.ratings_average DESC) AS row_num
        FROM
            top3_grape_names g
        JOIN
            wines w ON w.name LIKE '%' || g.name || '%'
    ) AS ranked_wines
WHERE
    row_num <= 5;
