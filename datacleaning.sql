SELECT * 
from dbo.nashvillehousing

--standardise the date format
SELECT SaleDateConverted, CONVERT (Date, SaleDate)
from dbo.nashvillehousing

UPDATE dbo.nashvillehousing
SET SaleDate = CONVERT (Date, SaleDate)

--if that query didn't work
ALTER TABLE dbo.nashvillehousing
ADD SaleDateConverted Date;

UPDATE dbo.nashvillehousing
SET SaleDateConverted = CONVERT (Date, SaleDate)

--populate property address data for null values
SELECT PropertyAddress
from dbo.nashvillehousing
where PropertyAddress is null

SELECT PropertyAddress
from dbo.nashvillehousing
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehousing a
JOIN dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.nashvillehousing a
JOIN dbo.nashvillehousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--breaking out property address into individual columns (address, city, state)
SELECT PropertyAddress
from dbo.nashvillehousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address 
from dbo.nashvillehousing

ALTER TABLE dbo.nashvillehousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE dbo.nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE dbo.nashvillehousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE dbo.nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT*
from dbo.nashvillehousing

--break out owner address to address, city & state
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from dbo.nashvillehousing

ALTER TABLE dbo.nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE dbo.nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE dbo.nashvillehousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE dbo.nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE dbo.nashvillehousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE dbo.nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT*
from dbo.nashvillehousing

--change Y and N to 'yes' and 'no' in "sold as vacant" field
SELECT distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.nashvillehousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
end
from dbo.nashvillehousing

UPDATE dbo.nashvillehousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
when SoldAsVacant = 'N' THEN 'No'
else SoldAsVacant
END

--remove duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference
	ORDER BY UniqueID
	)row_num
from dbo.nashvillehousing
)
DELETE
from RowNumCTE
where row_num > 1

--delete unused columns
SELECT * 
from dbo.nashvillehousing

ALTER TABLE dbo.nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

ALTER TABLE dbo.nashvillehousing
DROP COLUMN SaleDate
