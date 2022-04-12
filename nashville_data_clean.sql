CREATE TABLE Public."nashville_housing"(UniqueID int, ParcelID varchar(30), LandUse varchar(100), 
PropertyAddress varchar(100), SaleDate date, SalePrice int, LegalReference varchar(50), 
SoldAsVacant varchar(10), OwnerName varchar(100), OwnerAddress varchar(100), Acreage float, 
TaxDistrict varchar(100), LandValue int, BuildingValue int, TotalValue int, YearBuilt int, 
Bedrooms int, FullBath int, HalfBath int);

SELECT * FROM Public."nashville_housing";
SELECT DISTINCT(PropertyAddress) FROM Public."nashville_housing";

/* Select saleDateConverted, CONVERT(Date,SaleDate)
FROM Public."nashville_housing" */

-- Populate Property Address missing data

Select *
From Public."nashville_housing"
Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, COALESCE(a.PropertyAddress,b.PropertyAddress)
From Public."nashville_housing" a
JOIN Public."nashville_housing" b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null

/*
BEGIN;
UPDATE nashville_housing
SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress)
From Public."nashville_housing" a
JOIN Public."nashville_housing" b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 
Where a.PropertyAddress is null
ROLLBACK; */

--BEGIN; to test the update
UPDATE nashville_housing as a
SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress)
From Public."nashville_housing" b
WHERE a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID 

--ROLLBACK; to revert the update
--------------------------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT split_part(PropertyAddress, ',', 1) AS Address,
split_part(PropertyAddress, ',', 2) AS City
FROM Public."nashville_housing"

SELECT a[1],a[2]
FROM (SELECT string_to_array(PropertyAddress, ',')
	 FROM nashville_housing) as dt(a); 

-- BEGIN;
ALTER TABLE nashville_housing ADD COLUMN Address varchar(255);
UPDATE nashville_housing
SET Address = split_part(PropertyAddress, ',', 1);

-- ROLLBACK;

-- BEGIN;
ALTER TABLE nashville_housing ADD COLUMN City varchar(255);
UPDATE nashville_housing
SET City = split_part(PropertyAddress, ',', 2);

-- ROLLBACK;

SELECT * FROM Public."nashville_housing";

----------------------------------------------------------------------------------------------------------------------
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM Public."nashville_housing"
GROUP BY SoldAsVacant
ORDER BY 2;

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Public."nashville_housing"

--BEGIN;
Update Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
	   
--ROLLBACK;

--------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Public."nashville_housing"
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From Public."nashville_housing"


ALTER TABLE Public."nashville_housing"
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

