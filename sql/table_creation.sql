-- Dimension table Wines Q1, Q5, Q6
CREATE TABLE Dim_wines (
  wine_id INTEGER PRIMARY KEY,
  wine_name VARCHAR
);

-- Dimension table Regions Q6
CREATE TABLE Dim_regions (
  region_id INTEGER PRIMARY KEY,
  fk_country_id INTEGER,
  region_name VARCHAR,
  FOREIGN KEY (fk_country_id) REFERENCES Dim_countries(country_code)
);

-- Dimension table Countries Q6
CREATE TABLE Dim_countries (
  country_code VARCHAR PRIMARY KEY,
  country_name VARCHAR
);

-- Dimension table Vintages Q6
CREATE TABLE Dim_vintages (
  vintages_id INTEGER PRIMARY KEY,
  vintages_name VARCHAR
);

-- Dimension table Grapes Q5
CREATE TABLE Dim_grapes (
  grape_id INTEGER PRIMARY KEY,
  grape_name VARCHAR  
);

-- Fact Table Wines Q1, Q6
CREATE TABLE Fact_wines (
  fk_wine_id INTEGER,
  fk_region_id INTEGER,
  fk_country_id INTEGER,
  ratings_avg INTEGER,
  ratings_count INTEGER,
  calc_avg_price INTEGER,
  calc_weighted_rating INTEGER,
  PRIMARY KEY (fk_wine_id),
  FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
  FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
  FOREIGN KEY (fk_country_id) REFERENCES Dim_countries(country_id)
);

-- Fact Table Vintages Q6
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

-- Fact Table Grapes Q5
CREATE TABLE Fact_grapes (
  fk_grape_id INTEGER,
  wines_count INTEGER,
  PRIMARY KEY (fk_grape_id),
  FOREIGN KEY (fk_grape_id) REFERENCES Dim_grapes(grape_id)
);