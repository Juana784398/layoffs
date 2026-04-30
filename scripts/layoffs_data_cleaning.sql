-- -----------------------------------------------------------------------------
-- WORLD LAYOFFS DATA CLEANING PROJECT
-- Purpose: To clean and standardize raw layoff data for future EDA.
-- Skills Used: Staging Tables, Window Functions (ROW_NUMBER), CTEs, 
-- 				Self-Joins, String Manipulation, Data Type Conversion.
-- -----------------------------------------------------------------------------

-- 1. DATA STAGING
-- Create a copy of the raw data to ensure the source data remains untouched.
CREATE TABLE layoffs_staging
LIKE layoffs;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- Create a second staging table to handle de-duplication with a row number column.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
	PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- 2. REMOVING DUPLICATES
-- Deleting records where row_num > 1 (exact duplicates across all columns).
DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

-- 3. STANDARDIZING DATA
-- Trimming whitespace from company names.
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Consolidating varying industry names (e.g., 'Crypto Currency' -> 'Crypto').
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Cleaning country names (Removing trailing periods).
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) # or set country = 'United States' also works
WHERE country LIKE 'United States';

-- Converting 'date' from Text to Date format for time-series analysis.

-- first change to date format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- then change to date column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- 4. HANDLING NULL AND BLANK VALUES
-- Standardizing empty strings to NULL for consistent processing.
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';

-- Populating missing industry data using a Self-Join.
-- If a company has a populated industry on another row, we map it to the NULL entry.
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- 5. REMOVING UNNECESSARY DATA
-- Deleting rows where both metrics for layoffs are missing (non-actionable data).
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


-- Final cleanup: Dropping the temporary helper column.
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

-- Final verification of cleaned dataset
SELECT * FROM layoffs_staging2;






