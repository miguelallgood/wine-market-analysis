-------------------------------------------------------
-- Create table
DROP TABLE IF EXISTS Dim_Winery_Name;
CREATE TABLE Dim_Winery_Name (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);
-- copy winery names to dim_winery names
INSERT INTO Dim_Winery_Name (id, name)
SELECT id, name
FROM wineries;

-- Insert data into Fact_Wineries by aggregating information from vintages and wines tables
-- drop and create Fact_Wineries

INSERT INTO Fact_Wineries (winery, avg_price, avg_rating, total_ratings, overal_score, num_of_wines)
SELECT
    wines.winery_id,
    ROUND(AVG(vintages.price_euros)) AS avg_price,         -- Average price rounded
    AVG(vintages.ratings_average) AS avg_rating,           -- Average rating
    SUM(vintages.ratings_count) AS total_ratings,          -- Sum of all ratings
    ROUND(AVG(vintages.price_euros) *                      -- Calculated overall score
          AVG(vintages.ratings_average) *
          SUM(vintages.ratings_count)) AS overal_score,
    COUNT(DISTINCT vintages.wine_id) AS num_of_wines       -- Count of distinct wines
FROM vintages
LEFT JOIN wines ON vintages.wine_id = wines.id
GROUP BY wines.winery_id;