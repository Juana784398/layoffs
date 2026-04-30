-- Data Cleaning
-- This has all my thought process

SELECT *
FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize Data
-- 3. Null and blank values
-- 4. Remove unnecessary rows/columns

-- -------- STAGING: to create a working table --------
-- a. create table template
CREATE TABLE layoffs_staging
LIKE layoffs;

-- b. look at the empty table
SELECT * 
FROM layoffs_staging;

-- c. insert from raw data
INSERT layoffs_staging
SELECT *
FROM layoffs;

-- -------- REMOVING DUPLICATES --------

-- a. Partitioning and creeating row numbers, should give unique row numbers if there is not duplicates
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

-- b. Use that cte to filter out rows where row_num is 2 or more, meaning it's a duplicate
WITH duplicates_cte AS
(
	SELECT * ,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
SELECT *
FROM duplicates_cte
WHERE row_num > 1
;

-- c. Look at the company called 'Casper' from the prev query, it has multiple duplicates
SELECT *
FROM layoffs_staging
WHERE company = 'Casper'
ORDER BY `date`;

-- d. delete the rows from the cte
-- if we try to delete/update cte it won't work
WITH duplicates_cte AS
(
	SELECT * ,
	ROW_NUMBER() OVER(
    PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_staging
)
DELETE
FROM duplicates_cte
WHERE row_num > 1
;

-- Instead we can create another staging database where there is the extra row unm and deleting those records
-- we need to add a row column to the new table so we do it this way
-- world_layoffs -> layoffs_staging -> Copy to a clipboard -> create statement -> ctrl v

-- Opens up this following, we just add row_num column
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

SELECT *
FROM layoffs_staging2;

-- Insert everything from the window function
INSERT INTO layoffs_staging2
SELECT * ,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1
;

DELETE
FROM layoffs_staging2
WHERE row_num > 1
;

SELECT *
FROM layoffs_staging2;

# Note: Having a unique column would have made it much easier to delete

-- ------------STANDARDIZATION ------------

SELECT *
FROM layoffs_staging2;

-- Remove whitespace
SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);

-- Running this shows empty cell, null cell and lots of similar values like "crypto currency", "crypotcurrency", "crypto"
SELECT DISTINCT industry
FROM layoffs_staging2
ORDER BY 1;

SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%' ;

UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- locate any other mistakes

SELECT DISTINCT location
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

-- found a united states with a period at the end
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country) # or set country = 'United States' also works
WHERE country LIKE 'United States';

-- Date is a text column, if we want to do time series during EDA it could cause problems
SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y') # capital M or lowercase Y won't work
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

-- Note: we're converting into date format but not the column into date datatype
-- Tying to convert it into a date column without previous step will not work

-- We can turn it the data type after that step
-- The following changes text column to date column
ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- ---------------NULL Values---------------

SELECT *
FROM layoffs_staging2;

-- returns few industries, we'll try to check if we could populate those
SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ''; 

-- turning empty industries to null so its easier to populate
UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = '';


-- returned 2 airbnb column and the industry is 'Travel
-- similarly there is many more companies with no industries
-- we cannot just update one airbnb industry, we need  code that will automatically populate all such companies
SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb'; 

-- self join the table based on industries which are null to industries which are not null for the same company
SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- update and populate the industries for the same company
UPDATE layoffs_staging2 AS t1
JOIN layoffs_staging2 AS t2
	ON t1.company = t2.company 
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

-- We cannot populate total_laid_off from percent laid off or vice versa, since we do not have total employees.
-- So we leave those as it is
-- most other cols we cannot populate

SELECT *
FROM layoffs_staging2
WHERE stage IS NULL;
;

-- If both total and % laid off is null, those records are fairly useless to us
-- The project is dealing with layoffs, so it is fairly safe to delete the columns where neither values are present
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL # = NULL would not work here
AND percentage_laid_off IS NULL;

 
DELETE
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SELECT *
FROM layoffs_staging2;

-- We need to drop that row_num column we created in the beginning
ALTER TABLE layoffs_staging2
DROP COLUMN row_num;







