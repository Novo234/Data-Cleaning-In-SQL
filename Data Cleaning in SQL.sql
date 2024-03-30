-- THIS PROJECT ENCOMPASSES DATA CLEANING. THE SAMPLE DATA USED HERE WAS DOWNLOADED FROM AN OPEN SOURCED WEBSITE. 
-- THIS PROJECT CONTAINS A WHOLE LOT OF ANOMALIES AND WE ARE GOING TO ERADIDCATE THOSE ANOMALIES WITH SQL FUNCTIONS

SELECT *
FROM NashvilleHousing

-- CHANGING THE DATA FORMAT
SELECT saledateconverted, CONVERT(Date, saledate)
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


ALTER TABLE NashVilleHousing
ADD SaleDateConverted Date

-- POPULATE PROPERTY ADDRESS DATA
SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT NashA.ParcelID, NashA.PropertyAddress, NashB.ParcelID, NashB.PropertyAddress, ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
FROM NashvilleHousing  NashA
JOIN NashvilleHousing  NashB
   ON NashA.ParcelID = NashB.ParcelID
   AND NashA.[UniqueID ] <> NashB.[UniqueID ]
   WHERE NashA.PropertyAddress IS NULL


   UPDATE NashA
   SET PropertyAddress = ISNULL(NashA.PropertyAddress, NashB.PropertyAddress)
   FROM NashvilleHousing NashA
   JOIN NashvilleHousing NashB
       ON NashA.ParcelID = NashB.ParcelID
	   AND NashA.[UniqueID ] <> NashB.[UniqueID ]
	   WHERE NashA.PropertyAddress IS NULL


-- SPLITTING ADDRESS INTO INDIVIDUAL COLUMNS(ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing


ALTER TABLE NashVilleHousing
ADD PropertySplitAddress Nvarchar(260);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) 

ALTER TABLE NashVilleHousing
ADD PropertySplitCity Nvarchar(260);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing


-- SEPERATING OWNER ADDRESS COLUMN
SELECT OwnerAddress
FROM NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress Nvarchar(260);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashVilleHousing
ADD OwnerSplitCity Nvarchar(260);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashVilleHousing
ADD OwnerSplitState Nvarchar(260);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- IN "SOLD AS VACANT" COLUMN, WE WILL BE CHANGING VALUES THAT APPEARS AS "Y" AND "N" TO "YES" AND "NO"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant


SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	  WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


-- REMOVING DUPLICATES AND GETTING RID OF UNUSED COLUMNS IN THE DATA
WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				        UniqueId
						) ROW_NUM
FROM NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE ROW_NUM > 1
--ORDER BY PropertyAddress


-- REQUERING TO SEE IF THE DUPLICATES HAVE BEEN SUCCESSFULLY DELETED 
WITH RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER(
	 PARTITION BY ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY 
				        UniqueId
						) ROW_NUM
FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress



-- DELETING UNUSED COLUMNS

SELECT *
FROM NashvilleHousing


ALTER TABLE NashVilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict


ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate