-- Question 7: One of our VIP clients likes Cabernet Sauvignon and would like our top 5 recommendations. Which wines would you recommend to him?

-- create a new table linking wines with grapes
CREATE TABLE wine_grape (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  wine_id INTEGER NOT NULL,
  grape_id INTEGER NOT NULL,
  FOREIGN KEY (wine_id) REFERENCES wines(id),
  FOREIGN KEY (grape_id) REFERENCES grapes(id)
);

-- Insert data into wine_grape table
INSERT INTO wine_grape (wine_id, grape_id)
SELECT w.id, g.id
FROM wines w
INNER JOIN grapes g ON 
  w.name LIKE '%' || g.name || '%'  -- Match grape name in wine name
UNION ALL
SELECT w.id, k.id AS grape_id  -- Use keyword as suggestion
FROM wines w
INNER JOIN keywords_wine kw ON w.id = kw.wine_id
INNER JOIN keywords k ON kw.keyword_id = k.id
WHERE k.name LIKE 'Cabernet Sauvignon%'  -- Focus on relevant keywords
  OR k.name LIKE '%Blend%'  -- Might indicate multiple grape varieties
;

-- Answer
SELECT w.name AS wine_name, w.ratings_average, w.ratings_count
FROM wines w
INNER JOIN wine_grape wg ON w.id = wg.wine_id
INNER JOIN grapes g ON wg.grape_id = g.id
WHERE g.name = 'Cabernet Sauvignon'
ORDER BY w.ratings_average DESC, w.ratings_count DESC
LIMIT 5;

-- queries using fact tables and dimensional tables
CREATE TABLE wine_grape_fact (
  wine_id INTEGER NOT NULL,
  grape_id INTEGER NOT NULL,
  PRIMARY KEY (wine_id, grape_id),
  FOREIGN KEY (wine_id) REFERENCES wines(id),
  FOREIGN KEY (grape_id) REFERENCES grapes(id)
);

INSERT INTO wine_grape_fact (wine_id, grape_id)
SELECT w.id, g.id
FROM wines w
INNER JOIN grapes g ON 
  w.name LIKE '%' || g.name || '%'  -- Match grape name in wine name
UNION ALL
SELECT w.id, k.id AS grape_id  -- Use keyword as suggestion
FROM wines w
INNER JOIN keywords_wine kw ON w.id = kw.wine_id
INNER JOIN keywords k ON kw.keyword_id = k.id
WHERE k.name LIKE 'Cabernet Sauvignon%'  -- Focus on relevant keywords
  OR k.name LIKE '%Blend%';  -- Might indicate multiple grape varieties

-- Asnwer querying with dimensional and fact tables
SELECT w.name AS wine_name, w.ratings_average, w.ratings_count
FROM wines w
INNER JOIN wine_grape_fact wg ON w.id = wg.wine_id
INNER JOIN grapes g ON wg.grape_id = g.id
WHERE g.name = 'Cabernet Sauvignon'
ORDER BY w.ratings_average DESC, w.ratings_count DESC
LIMIT 5;
