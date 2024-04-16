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
  PRIMARY KEY (fk_vintages_id, fk_wine_id, fk_region_id, fk_country_id), -- Assuming composite key
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
    dc.country_name,
    AVG(fv.ratings_avg) AS avg_rating
FROM
    Fact_vintages fv
JOIN
    Dim_countries dc ON fv.fk_country_id = dc.country_code
GROUP BY
    dc.country_name;
