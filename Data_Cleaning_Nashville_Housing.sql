---------------------------------------------------------------------------------------
/*
Cleaning Data in SQL Queries
*/

SELECT * 
FROM dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format using CONVERT, UPDATE, ALTER

SELECT SaleDate, CONVERT(Date,Saledate) 
FROM dbo.NashvilleHousing


UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,Saledate) 

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,Saledate) 




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data by using SELF JOIN, ISNULL and UPDATE


SELECT * 
FROM dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID



SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM dbo.NashvilleHousing A
JOIN dbo.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] != B.[UniqueID ]
WHERE A.PropertyAddress IS NULL




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State) using SUBSTRING, CHARINDEX


SELECT PropertyAddress
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID




SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) AS Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255); 

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255); 

UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1 , LEN(PropertyAddress))




SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM dbo.NashvilleHousing


ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255); 

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field using CASE statement


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM dbo.NashvilleHousing



UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates using CTE


WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
FROM dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


SELECT * 
FROM dbo.NashvilleHousing