/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Change SaleDate Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)



-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data for the currently NULL fields on the data

Select ParcelID, PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

-- Check rows that have a NULL in PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select ParcelID, PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,     -- the '-1' is to get rid of the comma in the field since teh CHARINDEX is specifying a character position number, not the char itself.
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as State

From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))



-- Splitting OWNER ADDRESS into different fields
Select *
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From PortfolioProject.dbo.NashvilleHousing




-- Add and Update Owner Split Address
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


-- Add and Update Owner Split City
ALTER TABLE NashvilleHousing
Add OwnerSplitcity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitcity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


-- Add and Update Owner Split State
ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)




--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field for consistency purposes.

Select distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP By SoldAsVacant
ORDER BY 2


Select SoldAsVacant,
 (CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END ) AS UPDATEDSAV
From PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant =
	CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Identifying (And Removing) Duplicates (I Understand its not as standard Practice to delete data but will do for purposes of keeping data clean)

-- CTE to find where the duplicates are

WITH RowNumCTE
AS (
	SELECT *, 
	ROW_Number() OVER (
	PARTITION BY PARCELID,
					PROPERTYADDRESS,
					SALEPRICE,
					SALEDATE,
					LEGALREFERENCE
					ORDER BY
						UniqueID
						) Row_Num

	From PortfolioProject.dbo.NashvilleHousing
	-- Order By PARCELID
	)

SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress

-- QUERY TO DELETE DUPLICATES FOUND IN THE CTE (MUST INCLUDE CTE WHEN RUNNING THE QUERY)
--DELETE
--FROM RowNumCTE
--WHERE ROW_NUM > 1





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns (Since its deleting RAW Data, this is not to be done often. Just to show ability to run query) RUN a Table VIEW instead


SELECT *
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
