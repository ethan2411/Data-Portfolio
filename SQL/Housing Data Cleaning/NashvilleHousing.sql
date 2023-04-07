-- Active: 1680755937802@@127.0.0.1@3306@nashvillehousing

-- Looking at all the data
Select *
From nashvillehousing;

-- Populate Property Address Data 
Select *
From nashvillehousing
ORDER BY `ParcelID`;
-- From Query above we can see that 'ParcelID' is unique for the property address
-- So each property with the same address has the same 'ParcelID'. Now going to use
-- this to populate 'PropertyAddress' where there are null values
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(b.PropertyAddress, a.PropertyAddress)
From nashvillehousing as a
join nashvillehousing as b
    on a.ParcelID = b.ParcelID
    and a.UniqueID != b.UniqueID
Where a.PropertyAddress =''

-- Updating the Addresses
UPDATE nashvillehousing AS a
JOIN nashvillehousing AS b 
    ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
SET a.PropertyAddress = COALESCE(b.PropertyAddress, a.PropertyAddress)
WHERE a.PropertyAddress = '';

-- Separating the Addess into it's individual columns (Address, City, State)
-- Starting with 'PropertyAddress', then will do 'OwnerAddress'
SELECT PropertyAddress
FROM nashvillehousing;

SELECT SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
       SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2, LENGTH(PropertyAddress)) AS City
FROM nashvillehousing;

--Creating the new columns
-- Creating column for Address
DROP TABLE IF EXISTS PropertySplitAddress;
ALTER TABLE nashvillehousing ADD PropertySplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

-- Creating column for City
DROP TABLE IF EXISTS PropertySplitCity;
ALTER TABLE nashvillehousing ADD PropertySplitCity VARCHAR(255);

UPDATE nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 2, LENGTH(PropertyAddress));

--Checking results
SELECT PropertySplitAddress, PropertySplitCity
FROM nashvillehousing;

-- Now for `OwnerAddress`
SELECT 
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1)) AS Address,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
    TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1)) AS State
FROM nashvillehousing;

-- Creating column for Address
DROP TABLE IF EXISTS OwnerSplitAddress;
ALTER TABLE nashvillehousing ADD OwnerSplitAddress VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitAddress =TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1), ',', -1));

-- Creating column for City
DROP TABLE IF EXISTS OwnerSplitCity;
ALTER TABLE nashvillehousing ADD OwnerSplitCity VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));

-- Creating column for State
DROP TABLE IF EXISTS OwnerSplitState;
ALTER TABLE nashvillehousing ADD OwnerSplitState VARCHAR(255);

UPDATE nashvillehousing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3), ',', -1));

-- Checking Results
Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From nashvillehousing;
