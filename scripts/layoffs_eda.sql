-- -----------------------------------------------------------------------------
-- WORLD LAYOFFS EXPLORATORY DATA ANALYSIS (EDA) PROJECT
-- Purpose:		To uncover global layoff trends, identify high-impact industries, 
-- 				and analyze geographic and temporal patterns across 2020-2023.
-- Skills Used: Advanced CTEs, Multi-Level Aggregation, Window Functions (DENSE_RANK), 
--              Temporary Tables, Self-Joins, Time-Series Analysis.
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- 1. MACRO-LEVEL DISCOVERY & OUTLIERS
-- Identifying data boundaries, extreme values, total volume ranges, largest single events, and company shutdowns
-- -----------------------------------------------------------------------------

SELECT *
FROM layoffs_staging2;

-- INSIGHT: the largest single-day layoff event was 12000 and total company liquidations.
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- INSIGHT: Google recorded the single highest layoff event (12,000 employees).
SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000; 

-- INSIGHT: 116 companies laid off 100% of their staff. 
-- Sorting by funds raised identifies high-capital startups that failed.
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- -----------------------------------------------------------------------------
-- 2. CATEGORICAL AGGREGATIONS
-- Calculating total layoffs by company, industry, country, and funding stage.
-- -----------------------------------------------------------------------------

-- Top companies by total volume of layoffs: Amazon, Google and Meta are the top 3 most hardest hit companies
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs per industry: Consumer and Retail appear to be the most volatile
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs per Country: USA, India, and Netherlands lead the dataset.
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by Funding Stage.
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- -----------------------------------------------------------------------------
-- 3. TIME-SERIES ANALYSIS & SEASONALITY
-- Analyzing trends across years and months.
-- -----------------------------------------------------------------------------

-- Determining the dataset's timeframe: March 2020 to March 2023.
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Yearly totals: 2022 shows a significant spike compared to other pandemic years.
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;

-- Monthly Progression (Rolling Sum): 
-- This CTE calculates the accumulation of layoffs over time to visualize the 'wave' effect.
WITH Rolling_Total AS (
	SELECT SUBSTRING(`date`, 1, 7) AS Month, SUM(total_laid_off) AS total_per_month
	FROM layoffs_staging2
	WHERE  SUBSTRING(`date`, 1, 7) is NOT NULL
	GROUP BY SUBSTRING(`date`, 1, 7)
	ORDER BY 1
) 
SELECT `Month`, total_per_month, SUM(total_per_month) OVER (ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

-- -----------------------------------------------------------------------------
-- 4. COMPETITIVE RANKING (ADVANCED CTEs)
-- Using DENSE_RANK to identify the 'Top 5' biggest layoff events per year.
-- -----------------------------------------------------------------------------

-- Ranking Top 5 Companies with most layoffs per Year.
WITH Company_YEAR (company, years, total_laid_off )AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
), Company_year_rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS `Rank`
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_year_rank
WHERE `Rank` <= 5
;

-- Ranking top 5 industries with most layoffs per year
WITH Industry_Year (industry, years, total_laid_off) AS (
	SELECT industry, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY industry, YEAR(`date`)
), Industry_year_ranking AS (
	SELECT *, DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Industry_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Industry_year_ranking
WHERE Ranking <= 5
;

-- -----------------------------------------------------------------------------
-- 5. GEOGRAPHIC HIERARCHY & CONTRIBUTION ANALYSIS
-- Analyzing how specific cities/locations contribute to their respective country's total layoffs
-- -----------------------------------------------------------------------------

-- CTE's to analyze how the city totals contribute to the respective country's total layoffs
WITH country_total AS (
	SELECT country, SUM(total_laid_off) as total_laid_off_per_country
	FROM layoffs_staging2
	GROUP BY country
	HAVING total_laid_off_per_country IS NOT NULL
), location_total AS (
	SELECT country, location, SUM(total_laid_off) AS total_laid_off_per_location
	FROM layoffs_staging2
	GROUP BY country, location
    HAVING total_laid_off_per_location IS NOT NULL
)
SELECT country_total.country, total_laid_off_per_country, location, total_laid_off_per_location,
(total_laid_off_per_location/total_laid_off_per_country) * 100 AS location_contribution_percentage
FROM country_total
JOIN location_total
	ON country_total.country = location_total.country
ORDER BY total_laid_off_per_country DESC, total_laid_off_per_location DESC
;

-- -----------------------------------------------------------------------------
-- 6. SECTOR CONCENTRATION WITHIN TOP 10 COUNTRIES (TEMP TABLES)
-- Isolating the top 10 most-affected nations to analyze which industries drove the numbers.
-- -----------------------------------------------------------------------------

-- Temporary table isolates the top 10 countires with most layoffs
CREATE TEMPORARY TABLE Top_10_countries AS
SELECT country, SUM(total_laid_off) AS total_per_country
FROM layoffs_staging2
GROUP BY country
ORDER BY total_per_country DESC
LIMIT 10
;
SELECT *
FROM Top_10_countries;

-- Joining the Temp Table back to main data to filter out top 10 counties and calculate sectoral impact.
SELECT t2.country, t1.industry, t2.total_per_country  AS total_country_layoffs, SUM(t1.total_laid_off) AS total_industry_layoffs, 
	(SUM(t1.total_laid_off)/t2.total_per_country) * 100 AS pct_of_country_total
FROM layoffs_staging2 AS t1
JOIN Top_10_countries AS t2
	ON t1.country = t2.country
GROUP BY t2.country, t1.industry, t2.total_per_country
HAVING total_industry_layoffs IS NOT NULL
ORDER BY total_country_layoffs DESC, total_industry_layoffs DESC
;

-- -----------------------------------------------------------------------------
-- 7. METHODOLOGICAL NOTES & LIMITATIONS
-- STATISTICAL NOTE: 'percentage_laid_off' is an unreliable metric for cross-company 
-- comparison as the total employee base is unknown. Averaging this column can lead to 
-- misleading conclusions (e.g., a 50% layoff followed by a 5% layoff averages to 27.5%, 
-- which fails to represent the true headcount reduction). 
-- Focus was shifted to 'total_laid_off' for high-confidence insights.
-- -----------------------------------------------------------------------------

