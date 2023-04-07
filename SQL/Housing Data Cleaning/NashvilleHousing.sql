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

-- Editing 'SoldAsVacant' to have consistent values
Select DISTINCT(SoldAsVacant), count(SoldAsVacant)
From nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;

-- Consolidating values
Select SoldAsVacant,
    CASE 
        WHEN SoldAsVacant ='Y' THEN  'Yes'
        WHEN SoldAsVacant ='N' THEN  'No'
        ELSE  SoldAsVacant 
    END
From nashvillehousing;

-- Updating columns
UPDATE nashvillehousing
set SoldAsVacant = CASE 
        WHEN SoldAsVacant ='Y' THEN  'Yes'
        WHEN SoldAsVacant ='N' THEN  'No'
        ELSE  SoldAsVacant 
    END;

--Finding duplicate values using CTE
With RowNumCTE as(
    SELECT *, 
    ROW_NUMBER() over(
        PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
        ORDER BY UniqueID) as row_num
FROM nashvillehousing)

Select *
From RowNumCTE
where row_num >1
ORDER BY PropertyAddress;

-- My DB won't allow deletion through CTE's so I deleted them this way
-- even though i found the duplicates with a CTE
Delete FROM nashvillehousing
WHERE UniqueID IN (
  SELECT UniqueID
  FROM (
    SELECT UniqueID, ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
      ORDER BY UniqueID
    ) as row_num
    FROM nashvillehousing
  ) as RowNumCTE
  WHERE row_num > 1
);

-- Removing unused Columns (`PropertyAddress` and `OwnerAddress`)
-- Since new columns have been made for those
Select *
From nashvillehousing;

Alter table nashvillehousing
drop column OwnerAddress,
drop column PropertyAddress;
