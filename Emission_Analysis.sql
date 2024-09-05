-- Create the Table
CREATE TABLE carbon_emissions (
    Year INT PRIMARY KEY,
    Country1 DECIMAL(20, 2),
    Country2 DECIMAL(20, 2),
    -- Add all 221 country columns and 7 region columns
    Region1 DECIMAL(20, 2),
    Region2 DECIMAL(20, 2),
    -- Continue for all countries and regions
    Region7 DECIMAL(20, 2)
);

-- Import Data from CSV
LOAD DATA INFILE '/path/to/Global_Carbon_Emissions.csv'
INTO TABLE carbon_emissions
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Year, Country1, Country2, -- Add all country columns
 Region1, Region2, -- Add all region columns
 Region7); -- Adjust as needed

-- Handle NULL values
UPDATE carbon_emissions
SET Country1 = COALESCE(Country1, 0),
    Country2 = COALESCE(Country2, 0),
    -- Add all country columns
    Region1 = COALESCE(Region1, 0),
    Region2 = COALESCE(Region2, 0),
    -- Add all region columns
    Region7 = COALESCE(Region7, 0);

-- Trend Analysis: Emissions Trend for a Specific Country
SELECT Year, 
       Country1 AS Total_Emissions
FROM carbon_emissions
ORDER BY Year;

-- Top Emitting Regions Over Time
SELECT Year,
       Region1 AS Region1_Emissions,
       Region2 AS Region2_Emissions
FROM carbon_emissions
ORDER BY Year;

-- Annual Emissions Growth Rate by Region
WITH Emissions_Yearly AS (
    SELECT Year, Region1 AS Total_Emissions
    FROM carbon_emissions
),
Growth_Rates AS (
    SELECT Year,
           Total_Emissions,
           LAG(Total_Emissions) OVER (ORDER BY Year) AS Previous_Year_Emissions,
           (Total_Emissions - LAG(Total_Emissions) OVER (ORDER BY Year)) / 
           LAG(Total_Emissions) OVER (ORDER BY Year) * 100 AS Growth_Rate
    FROM Emissions_Yearly
    WHERE Previous_Year_Emissions IS NOT NULL
)
SELECT Year, 
       Total_Emissions, 
       Growth_Rate
FROM Growth_Rates
ORDER BY Year;

-- Emissions Comparison Between Two Specific Regions
SELECT Year,
       Region1 AS Region1_Emissions,
       Region2 AS Region2_Emissions
FROM carbon_emissions
ORDER BY Year;

-- Year with Highest Growth Rate in a Specific Region
WITH Emissions_Yearly AS (
    SELECT Year, Region1 AS Total_Emissions
    FROM carbon_emissions
),
Growth_Rates AS (
    SELECT Year,
           Total_Emissions,
           LAG(Total_Emissions) OVER (ORDER BY Year) AS Previous_Year_Emissions,
           (Total_Emissions - LAG(Total_Emissions) OVER (ORDER BY Year)) / 
           LAG(Total_Emissions) OVER (ORDER BY Year) * 100 AS Growth_Rate
    FROM Emissions_Yearly
    WHERE Previous_Year_Emissions IS NOT NULL
)
SELECT Year, 
       Growth_Rate
FROM Growth_Rates
ORDER BY Growth_Rate DESC
LIMIT 1;

-- Total Emissions Contribution of Each Country in a Specific Year
SELECT Year,
       Country1 AS Country1_Emissions,
       Country2 AS Country2_Emissions,
       -- Include additional countries as needed
       (Country1 + Country2) / (Country1 + Country2 + ...) * 100 AS Contribution_Percentage
FROM carbon_emissions
WHERE Year = 2023;

-- Correlation of Emissions Between Two Regions
WITH Emissions_Comparison AS (
    SELECT Year,
           Region1 AS Region1_Emissions,
           Region2 AS Region2_Emissions
    FROM carbon_emissions
)
SELECT CORR(Region1_Emissions, Region2_Emissions) AS Correlation
FROM Emissions_Comparison;
