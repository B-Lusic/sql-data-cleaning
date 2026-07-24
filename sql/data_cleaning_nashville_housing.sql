/*
===============================================================================
Nashville Housing Data Cleaning Project
Tool: Microsoft SQL Server (T-SQL)
Author: Ben Lusic
Description: End-to-end data pipeline to ingest, clean, standardize, and deduplicate 
             the Nashville Housing dataset. Includes schema creation, CSV ingestion, 
             self-join null imputation, string parsing, categorical normalization, 
             window function deduplication, and final column renaming.
===============================================================================
*/

USE PortfolioProject;
GO

-------------------------------------------------------------------------------
-- 1. Table Creation & Data Ingestion
-------------------------------------------------------------------------------
IF OBJECT_ID('dbo.NashvilleHousing', 'U') IS NOT NULL 
    DROP TABLE dbo.NashvilleHousing;
GO

CREATE TABLE dbo.NashvilleHousing (
    UniqueID VARCHAR(255),
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(255),
    SalePrice VARCHAR(255),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(255),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage VARCHAR(255),
    TaxDistrict VARCHAR(255),
    LandValue VARCHAR(255),
    BuildingValue VARCHAR(255),
    TotalValue VARCHAR(255),
    YearBuilt VARCHAR(255),
    Bedrooms VARCHAR(255),
    FullBath VARCHAR(255),
    HalfBath VARCHAR(255)
);
GO

-- Ingest raw CSV data using RFC 4180 CSV parser
BULK INSERT dbo.NashvilleHousing 
FROM "C:\Analyst Projects\Excel Operations\Nashville Housing Data for Data Cleaning.csv"
WITH (
    FORMAT = 'CSV',             -- Uses RFC 4180 CSV parser
    FIELDQUOTE = '"',           -- Double quote as text qualifier
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
GO


-------------------------------------------------------------------------------
-- 2. Standardize Date Format
-------------------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted DATE;
GO

UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

-- Verify conversion
SELECT TOP 100 SaleDate, SaleDateConverted, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing;


-------------------------------------------------------------------------------
-- 3. Populate Missing Property Address Data (Self-Join)
-------------------------------------------------------------------------------
-- Identify missing addresses where ParcelID matches across different unique records
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, 
       ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

-- Populate null property addresses
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;


-------------------------------------------------------------------------------
-- 4. Breaking Out Addresses into Individual Columns (Address, City, State)
-------------------------------------------------------------------------------
-- Preview PropertyAddress split (Address, City)
SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing;

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255),
    PropertySplitCity NVARCHAR(255);
GO

UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PropertySplitCity    = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Split OwnerAddress (Address, City, State) using PARSENAME
ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255),
    OwnerSplitCity NVARCHAR(255),
    OwnerSplitState NVARCHAR(255);
GO

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
    OwnerSplitCity    = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
    OwnerSplitState   = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-------------------------------------------------------------------------------
-- 5. Standardize 'Sold as Vacant' Field Values
-------------------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
ALTER COLUMN SoldAsVacant VARCHAR(10);
GO

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant IN ('Y', '1') THEN 'Yes'
    WHEN SoldAsVacant IN ('N', '0') THEN 'No'
    ELSE SoldAsVacant
END;


-------------------------------------------------------------------------------
-- 6. Remove Duplicates using CTE and ROW_NUMBER()
-------------------------------------------------------------------------------
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1;


-------------------------------------------------------------------------------
-- 7. Delete Unused Staging Columns
-------------------------------------------------------------------------------
ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
GO


-------------------------------------------------------------------------------
-- 8. Rename Cleansed Columns for Final Presentation
-------------------------------------------------------------------------------
EXEC sp_rename 'dbo.NashvilleHousing.PropertySplitAddress', 'Address', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.PropertySplitCity', 'City', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitAddress', 'OwnerAddress', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitCity', 'OwnerCity', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.OwnerSplitState', 'OwnerState', 'COLUMN';
EXEC sp_rename 'dbo.NashvilleHousing.SaleDateConverted', 'SaleDate', 'COLUMN';
GO

-- Verify Final Cleansed Dataset
SELECT TOP 100 *
FROM dbo.NashvilleHousing;
