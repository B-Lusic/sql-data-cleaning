# Nashville Housing SQL Data Cleaning Project

[![SQL Server](https://img.shields.io/badge/SQL_Server-CC292B?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)](#)
[![ETL](https://img.shields.io/badge/ETL-Data_Cleaning-blue?style=for-the-badge)](#)

[View Live Portfolio Write-Up](https://benlusic.wixsite.com/bensportfolio/post/nashville-housing-data-cleaning-project)

---

## 1. What business question did you answer?
Raw real estate transactional records often suffer from missing fields, inconsistent formatting, embedded delimited strings, and duplicate entries that prevent accurate market analysis. This project answers:
* How can raw real estate datasets be systematically standardized and cleaned in SQL Server for downstream analytics and reporting?
* How can missing property addresses be accurately populated using relational self-joins on parcel identifiers?
* How can unstructured address strings be split into structured, queryable relational attributes (`Address`, `City`, `State`)?

---

## 2. Where did the data come from?
The dataset contains raw historical housing market sales records from Nashville, Tennessee.

---

## 3. Is the data real, public, synthetic, or modified?
**Public & Real.** Public housing sales data extracted for real estate analytics benchmarking.

---

## 4. How many records and what time period?
* **Record Count:** ~56,000 property sale records.
* **Time Period:** Historical residential property sales transactions.

---

## 5. What tools did you use?
* **Database Management System:** Microsoft SQL Server / T-SQL (SQL Server Management Studio).
* **Key SQL Techniques:** String Manipulation (`SUBSTRING`, `CHARINDEX`, `PARSENAME`), Self-Joins (`ISNULL`), Conditional Logic (`CASE`), Window Functions (`ROW_NUMBER()`), Common Table Expressions (CTEs), and DDL Statements (`ALTER TABLE`, `DROP COLUMN`).

---

## 6. What transformations did you perform?
1. **Date Standardization:** Converted unformatted `DateTime` values into a standardized `Date` format using `CONVERT()`.
2. **Missing Address Imputation:** Performed a self-join matching on `ParcelID` to populate missing `PropertyAddress` values where `UniqueID` differed.
3. **Address Delimiter Parsing:**
   - Parsed `PropertyAddress` into `PropertySplitAddress` and `PropertySplitCity` using `SUBSTRING` and `CHARINDEX`.
   - Parsed `OwnerAddress` into `OwnerSplitAddress`, `OwnerSplitCity`, and `OwnerSplitState` using `PARSENAME` and `REPLACE`.
4. **Categorical Value Normalization:** Standardized the `SoldAsVacant` binary column by converting inconsistent `'Y'`/`'N'` values into uniform `'Yes'`/`'No'` strings.
5. **Deduplication:** Utilized a CTE with `ROW_NUMBER() OVER(PARTITION BY ...)` to identify and remove duplicate rows across matching parcel, address, price, and date keys.
6. **Column Cleanup:** Dropped redundant and unformatted staging columns (`PropertyAddress`, `OwnerAddress`, `TaxDistrict`, `SaleDate`).

---

## 7. How did you validate the results?
* Checked `NULL` counts on `PropertyAddress` pre- and post-join to ensure 100% address resolution.
* Executed `DISTINCT(SoldAsVacant)` queries to confirm only `'Yes'` and `'No'` values remained.
* Ran verification queries on `ROW_NUMBER()` outputs to confirm zero duplicate record keys remained in the final dataset.

---

## 8. What did you find?
* Over 100+ property records had missing address fields that were successfully recovered through `ParcelID` self-joins.
* Identified and deleted duplicate rows that would have skewed average sales price calculations in market analysis.

---

## 9. What decisions could follow?
* Downstream analysts can now execute reliable neighborhood price-per-square-foot aggregations without string parsing overhead.
* Cleansed dataset can be directly ingested into BI platforms (Power BI/Tableau) without requiring complex ETL transformations on load.

---

## 10. What are the limitations?
* Transformations were executed directly in a SQL Server staging table; in a production data warehouse setting, transformations would be executed within dedicated staging views or orchestration pipelines.

---

## 11. How can someone reproduce the work?
1. Clone this repository:
   ```bash
   git clone [https://github.com/your-username/sql-data-cleaning.git](https://github.com/your-username/sql-data-cleaning.git)
