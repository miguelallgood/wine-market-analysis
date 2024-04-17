-- Dimension Tables
CREATE TABLE Dim_wines (
  wine_id INTEGER PRIMARY KEY,
  wine_name VARCHAR
);

CREATE TABLE Dim_regions (
  region_id INTEGER PRIMARY KEY,
  fk_country_id INTEGER,
  region_name VARCHAR,
  FOREIGN KEY (fk_country_id) REFERENCES Dim_countries(country_code)
);

CREATE TABLE Dim_countries (
  country_code VARCHAR PRIMARY KEY,
  country_name VARCHAR
);

-- Fact Table
CREATE TABLE Fact_wines (
  fk_wine_id INTEGER,
  fk_region_id INTEGER,
  fk_country_id INTEGER,
  ratings_avg INTEGER,
  ratings_count INTEGER,
  calc_avg_price INTEGER,
  PRIMARY KEY (fk_wine_id),
  FOREIGN KEY (fk_wine_id) REFERENCES Dim_wines(wine_id),
  FOREIGN KEY (fk_region_id) REFERENCES Dim_regions(region_id),
  FOREIGN KEY (fk_country_id) REFERENCES Dim_countries(country_id)
);

CREATE TABLE Dim_grapes (
  grape_id INTEGER PRIMARY KEY,
  grape_name VARCHAR  
);

-- Fact Table
CREATE TABLE Fact_grapes (
  fk_grape_id INTEGER,
  wines_count INTEGER,
  PRIMARY KEY (fk_grape_id),
  FOREIGN KEY (fk_grape_id) REFERENCES Dim_grapes(grape_id)
);
