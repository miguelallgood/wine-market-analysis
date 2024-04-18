-- -- Question 7: One of our VIP clients likes Cabernet Sauvignon and would like our top 5 recommendations. Which wines would you recommend to him?

-- -- Create a new table to store associations between wines and grapes

-- CREATE TABLE Fact_wine_grape (
--   fk_wine_id INTEGER NOT NULL,  -- Foreign key referencing the wines table
--   fk_grape_id INTEGER NOT NULL, -- Foreign key referencing the grapes table
--   PRIMARY KEY (fk_wine_id, fk_grape_id), -- Define a composite primary key
--   FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),  -- Define foreign key constraint for wine_id
--   FOREIGN KEY (fk_grape_id) REFERENCES Dim_grapes(grape_id) -- Define foreign key constraint for grape_id
-- );

-- -- Insert data into the wine_grape_fact table

-- INSERT INTO wine_grape_fact (fk_wine_id, fk_grape_id)

-- SELECT w.id, g.id
-- FROM wines w
-- INNER JOIN grapes g ON 
--   w.name LIKE '%' || g.name || '%'  -- Match grape name in wine name
-- UNION ALL
-- SELECT w.id, k.id AS grape_id  -- Use keyword as suggestion
-- FROM wines w
-- INNER JOIN keywords_wine kw ON w.id = kw.wine_id
-- INNER JOIN keywords k ON kw.keyword_id = k.id
-- WHERE k.name LIKE 'Cabernet Sauvignon%'  -- Focus on relevant keywords
--   OR k.name LIKE '%Blend%';  -- Might indicate multiple grape varieties

-- -- Query to retrieve top 5 wines associated with the 'Cabernet Sauvignon' grape

-- SELECT w.name AS wine_name, w.ratings_average, w.ratings_count
-- FROM Fact_wine_grape fwg
-- INNER JOIN Dim_wine dw ON dw.wine_id = fwg.fk_wine_id
-- INNER JOIN Dim_grapes dg ON dg.grape_id = fwg.fk_grape_id
-- WHERE dg.grape_name = 'Cabernet Sauvignon' -- Filter wines associated with the 'Cabernet Sauvignon' grape
-- ORDER BY w.ratings_average DESC, w.ratings_count DESC -- Order results by ratings_average and ratings_count
-- LIMIT 5; -- Limit the results to the top 5 wines

SELECT dw.wine_name AS wine_name, fw.ratings_avg, fw.ratings_count
FROM Fact_wines fw
INNER JOIN Dim_wines dw ON dw.wine_id = fw.fk_wine_id
WHERE dw.wine_name LIKE 'Cabernet Sauvignon%'  -- Focus on relevant keywords
  OR dw.wine_name LIKE '%Blend%' 
ORDER BY fw.ratings_avg DESC, fw.ratings_count DESC -- Order results by ratings_average and ratings_count
LIMIT 5; -- Limit the results to the top 5 wines
