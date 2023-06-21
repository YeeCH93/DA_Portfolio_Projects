/*
Cleaning Data in SQL Queries

Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, 
Creating Views, Converting Data Types, String Manipulation
*/

-- Check amount of rows
SELECT COUNT(*)
FROM nashville_housing;

-- Check first 10 rows
SELECT *
FROM nashville_housing
LIMIT 10;

--------------------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT CAST(sale_date AS date)
FROM nashville_housing;

-- Add new column to store new date value 
ALTER TABLE nashville_housing
ADD sale_date_converted date;

-- update table
UPDATE nashville_housing
SET sale_date_converted = CAST(sale_date AS date);

-- check
SELECT unique_id, sale_date, sale_date_converted
FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (NULL Values)
-- assume the same parcel_id will have the same address
SELECT 
	unique_id
	, parcel_id
	, property_address
FROM nashville_housing
WHERE parcel_id IN ('072 07 0 042.00', '018 00 0 164.00');

-- Self-Join
SELECT 
	h1.parcel_id
	, h1.property_address
	, h2.parcel_id
	, h2.property_address
	, COALESCE(h1.property_address, h2.property_address) AS completed_address
FROM nashville_housing AS h1
JOIN nashville_housing AS h2
	ON h1.parcel_id = h2.parcel_id
	AND h1.unique_id != h2.unique_id -- not to repeat themself
WHERE h1.property_address IS NULL;

-- Update table
UPDATE nashville_housing
SET property_address = COALESCE(h1.property_address, h2.property_address)
FROM nashville_housing AS h1
JOIN nashville_housing AS h2
	ON h1.parcel_id = h2.parcel_id
	AND h1.unique_id != h2.unique_id
WHERE h1.property_address IS NULL;

-- Check
SELECT *
FROM nashville_housing
WHERE property_address IS NULL;

--------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out property_address into Individual Columns (Address, City)
SELECT 
	property_address
	, SUBSTRING(property_address, 1, POSITION(',' IN property_address)-1) AS property_split_address
	, SUBSTRING(property_address, POSITION(',' IN property_address)+2, LENGTH(property_address)) AS property_split_city
FROM nashville_housing;

-- Add new column 'property_split_address'
ALTER TABLE nashville_housing
ADD property_split_address varchar(255);

-- update table
UPDATE nashville_housing
SET property_split_address = SUBSTRING(property_address, 1, POSITION(',' IN property_address)-1);

-- Add new column 'property_split_city'
ALTER TABLE nashville_housing
ADD property_split_city varchar(255);

-- update table
UPDATE nashville_housing
SET property_split_city = SUBSTRING(property_address, POSITION(',' IN property_address)+2, LENGTH(property_address));

-- Check
SELECT 
	property_address
	, property_split_address
	, property_split_city
FROM nashville_housing 
LIMIT 5;

-- Breaking out owner_address into Individual Columns (Address, City, State)
SELECT 
	owner_address
	, SPLIT_PART(owner_address, ',', 1) AS owner_split_address
	, SPLIT_PART(owner_address, ',', 2) AS owner_split_city
	, SPLIT_PART(owner_address, ',', 3) AS owner_split_state
FROM nashville_housing;

-- 1. Add new column 'owner_split_address'
ALTER TABLE nashville_housing
ADD owner_split_address varchar(255);

-- update table
UPDATE nashville_housing
SET owner_split_address = SPLIT_PART(owner_address, ',', 1)

-- 2. Add new column 'owner_split_city'
ALTER TABLE nashville_housing
ADD owner_split_city varchar(255);

-- update table
UPDATE nashville_housing
SET owner_split_city = SPLIT_PART(owner_address, ',', 2)

-- 3. Add new column 'owner_split_state'
ALTER TABLE nashville_housing
ADD owner_split_state varchar(255);

-- update table
UPDATE nashville_housing
SET owner_split_state = SPLIT_PART(owner_address, ',', 3)

-- Check
SELECT
	owner_address
	, owner_split_address
	, owner_split_city
	, owner_split_state
FROM nashville_housing;

--------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in 'sold_as_vacant' field
SELECT 
	DISTINCT sold_as_vacant
	, COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY 1
ORDER BY 2;

SELECT
	sold_as_vacant
	, CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		   WHEN sold_as_vacant = 'N' THEN 'No'
		   ELSE sold_as_vacant
	  END
FROM nashville_housing
WHERE sold_as_vacant IN ('Y', 'N');

-- Update
UPDATE nashville_housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
		   				  WHEN sold_as_vacant = 'N' THEN 'No'
		   				  ELSE sold_as_vacant
	  				 END;

--------------------------------------------------------------------------------------------------------------------------------------

-- Detect Duplicate Rows
-- Create Temp Table
WITH row_num_cte AS (
	SELECT
		*
		, ROW_NUMBER() OVER(
			PARTITION BY 
						parcel_id
						, property_address
						, sale_price
						, sale_date
						, legal_reference
		ORDER BY unique_id
		) row_num
	FROM nashville_housing
)
SELECT *
FROM row_num_cte
WHERE row_num > 1
ORDER BY property_address;

-- Review duplicate rows
/*SELECT 
	parcel_id
	, property_address
	, sale_price
	, sale_date
	, legal_reference
	, row_num
FROM row_num_cte
WHERE parcel_id IN ('081 02 0 144.00', '081 07 0 265.00', '081 10 0 313.00');*/

--------------------------------------------------------------------------------------------------------------------------------------

-- Delete unused columns
-- Drop duplicate rows
-- Export result to CSV
WITH row_num_cte AS (
	SELECT
		*
		, ROW_NUMBER() OVER(
			PARTITION BY 
						parcel_id
						, property_address
						, sale_price
						, sale_date
						, legal_reference
		ORDER BY unique_id
		) row_num
	FROM nashville_housing
)
SELECT
	unique_id, parcel_id, land_use, property_split_address, property_split_city, sale_date_converted,
	sale_price, legal_reference, sold_as_vacant, owner_name, owner_split_address, owner_split_city, owner_split_state,
	land_value, building_value, total_value, year_built, full_bath, half_bath
FROM row_num_cte
WHERE row_num = 1
ORDER BY unique_id;



