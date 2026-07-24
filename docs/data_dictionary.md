# Data Dictionary - Nashville Housing Dataset

## Table: `NashvilleHousing`

| Column Name | Original Data Type | Cleaned Data Type | Description |
|---|---|---|---|
| `UniqueID` | Integer | Integer | Primary key identifying individual record |
| `ParcelID` | Varchar(255) | Varchar(255) | Geographic parcel identification code |
| `LandUse` | Varchar(255) | Varchar(255) | Property zoning classification |
| `PropertyAddress` | Varchar(255) | *Dropped* | Raw combined address string |
| `PropertySplitAddress` | - | Varchar(255) | Parsed street address |
| `PropertySplitCity` | - | Varchar(255) | Parsed city |
| `SaleDate` | DateTime | *Dropped* | Original unformatted transaction timestamp |
| `SaleDateConverted` | - | Date | Standardized `YYYY-MM-DD` transaction date |
| `SalePrice` | Currency | Currency | Transaction sale price |
| `SoldAsVacant` | Varchar(10) | Varchar(10) | Transformed from `Y`/`N` to `Yes`/`No` |
| `OwnerName` | Varchar(255) | Varchar(255) | Name of deed holder |
| `OwnerSplitAddress` | - | Varchar(255) | Parsed owner street address |
| `OwnerSplitCity` | - | Varchar(255) | Parsed owner city |
| `OwnerSplitState` | - | Varchar(255) | Parsed owner state code |
