-------------------------------------------------------
-- Winery name Dimension
DROP TABLE IF EXISTS Dim_Winery_Name;
CREATE TABLE Dim_Winery_Name (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255)
);

-- Fact table for wineries
DROP TABLE IF EXISTS Fact_Wineries;
CREATE TABLE Fact_Wineries (
    winery INT,               -- FK
    avg_price FLOAT,          -- Average price
    avg_rating FLOAT,         -- Average rating
    total_ratings INT,        -- Total number of ratings
	overal_score INT,
	num_of_wines INT,
    FOREIGN KEY (winery) REFERENCES Dim_Winery_Name(id)
);
-------------------------------------------------------
-- drop wineries and delete fk to wineries
DELETE FROM wineries;
UPDATE wines SET winery_id = NULL;

-- re populate wineries
INSERT INTO wineries (name)
SELECT DISTINCT
    REPLACE(vintages.name, ' ' || wines.name || ' ' || CAST(vintages.year AS VARCHAR), '') AS WineryName
FROM vintages
JOIN wines ON vintages.wine_id = wines.id;

-- update the fk to the wineries
UPDATE wines
SET winery_id = (
    SELECT wineries.id
    FROM wineries
    JOIN vintages ON vintages.wine_id = wines.id
    WHERE wineries.name = REPLACE(vintages.name, ' ' || wines.name || ' ' || CAST(vintages.year AS VARCHAR), '')
)
-------------------------------------------------------
-- copy winery names to dim_winery names
INSERT INTO Dim_Winery_Name (id, name)
SELECT id, name
FROM wineries;

-- Insert data into Fact_Wineries by aggregating information from vintages and wines tables
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
