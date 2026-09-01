/*
===========================================================================
Quality Checks
===========================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy,
    and standardization across the 'silver' schema. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after loading data into Silver Layer.
    - Investigate and resolve any descrepancies found during checks.
===========================================================================
*/

-- =================================================================
-- Checking 'silver.crm_cust_info'
-- =================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
	cst_id,
	COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL


-- Check for unwanted spaces
-- Expectation: No Results
SELECT cst_firstname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)


-- Data Standardization and Consistency
SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info

-- =================================================================
-- Checking 'silver.crm_prd_info'
-- =================================================================
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Results
SELECT
  prd_id,
  COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL

-- Check for unwanted spaces
-- Expectation: No Results
SELECT 
  prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm)

-- Check for NULLs or Negative Numbers in Cost
-- Expectation: No Results
SELECT 
  prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL

-- Data Standardization & Consistency
SELECT DISTINCT 
  prd_line
FROM silver.crm_prd_info

-- =================================================================
-- Checking 'silver.crm_sales_details'
-- =================================================================
-- Check for Invalid Dates
-- Expectation: No Invalid Dates
SELECT
  NULLIF(sls_ship_dt, 0) sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt <= 0
OR LEN(sls_ship_dt) != 8
OR sls_ship_dt > 20500101
OR sls_ship_dt < 19000101

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expection: No Results
SELECT 
*
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check Data Consistency between Sales, Quantity and Price
-- >> Sales = Quantity * Price
-- >> Values must be NULL, Zero or Negative
-- Expectation: No Results
SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL 
  OR sls_quantity IS NULL 
  OR sls_price IS NULL
  OR sls_sales <= 0 
  OR sls_quantity <= 0 
  OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- =================================================================
-- Checking 'silver.erp_cust_az12'
-- =================================================================
-- Identify Out-of-Range Dates
-- Expectation: Birthdates between 1924-01-01 and Today
SELECT DISTINCT
  bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
  OR bdate > GETDATE()

-- Data Standardization & Consistency
SELECT DISTINCT 
  gen
FROM silver.erp_cust_az12

-- =================================================================
-- Checking 'silver.erp_loc_a101'
-- =================================================================
-- Data Standardization & Consistency
SELECT DISTINCT 
  cntry
FROM silver.erp_loc_a101
ORDER BY cntry

-- =================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- =================================================================
-- Check for unwanted spaces
-- Expectation: No Results
SELECT 
  * 
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat) 
  OR subcat != TRIM(subcat) 
  OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT
  cat
FROM silver.erp_px_cat_g1v2
