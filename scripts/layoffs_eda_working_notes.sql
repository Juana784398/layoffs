-- Exploratory Data Analysis

-- Some basic questions to think about
-- Which industry has highest layoffs?
-- What years had highest layoffs?
-- Which sector had highest layoffs?

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;
-- output: someone had a max lay_off of 12000 on a specific day
-- the same day 100% of employees were laid off, from another company
-- let's take a look at more infos on those companies

SELECT *
FROM layoffs_staging2
WHERE total_laid_off = 12000; 
-- output: google laid off that many employees

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- these are the companies that most likely shutdown, 116 companies
-- ordered by the ones that got most funding

SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- output: companies with most no: of layoffs in descending order

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- looking at date ranges, we find that the layoffs data starts from March 2020 to March 2023, during the pandemic. 

SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;
-- output: industies with most no: of layoffs in descending order. consumer and retail hit hardest

SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;
-- US had most layoffs at 256k, followed by India at 35k and Netherlands at 17k

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- 2022 faced most layoffs, probably because effects of covid started to actually hit?

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, (AVG(percentage_laid_off))
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- percentage_laid_off does not give very accurate representation since we do not have total employee no:s
-- for example, avg() will give 11%, even if a company had an initial 50%, then 5% layoff. Almost half the
-- company has been laid off but the avg() gives a much lower %. not very useful insight!

-- Progression of layoffs: rolling sum of total_laid_off every month starting from March 2020

SELECT SUBSTRING(`date`, 1, 7) AS Month, SUM(total_laid_off)
FROM layoffs_staging2
WHERE  SUBSTRING(`date`, 1, 7) is NOT NULL
GROUP BY SUBSTRING(`date`, 1, 7)
ORDER BY 1;
-- output is the totaL-laid_off per every month

WITH Rolling_Total AS (
	SELECT SUBSTRING(`date`, 1, 7) AS Month, SUM(total_laid_off) AS total_per_month
	FROM layoffs_staging2
	WHERE  SUBSTRING(`date`, 1, 7) is NOT NULL
	GROUP BY SUBSTRING(`date`, 1, 7)
	ORDER BY 1
) 
SELECT `Month`, total_per_month, SUM(total_per_month) OVER (ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

-- let's see how many people did each company lay off throughout the years
SELECT company, YEAR(`date`) , SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;

-- Rolling total per company
WITH Company_YEAR (company, years, total_laid_off )AS (
	SELECT company, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY company, YEAR(`date`)
	ORDER BY 3 DESC
), Company_year_rank AS (
SELECT *, DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS `Rank`
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT * 
FROM Company_year_rank
WHERE `Rank` <= 5
;
-- output shows top 5 companies that laid most people off per year
-- Note: we created second cte to be able to filter on the ranks, otherwise it could've stayed out of the cte


-- let's do the same but for sectors
SELECT industry, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry, YEAR(`date`)
ORDER BY 3 DESC
;

WITH Industry_Year (industry, years, total_laid_off) AS (
	SELECT industry, YEAR(`date`), SUM(total_laid_off)
	FROM layoffs_staging2
	GROUP BY industry, YEAR(`date`)
	ORDER BY 3 DESC
), Industry_year_ranking AS (
	SELECT *, DENSE_RANK() OVER( PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Industry_Year
    WHERE years IS NOT NULL
)
SELECT *
FROM Industry_year_ranking
WHERE Ranking <= 5
;

-- output shows top 5 industries that had highest layoffs per year


-- let's explore countries and location layoffs
SELECT *
FROM layoffs_staging2;

-- total layoffs per city in a country
SELECT country, location, SUM(total_laid_off) AS total_laid_off_per_city
FROM layoffs_staging2
GROUP BY country, location
ORDER BY 1, 3 DESC
;

-- gives total lay offs per country
SELECT country, SUM(total_laid_off) as total_laid_off_per_country
FROM layoffs_staging2
GROUP BY country
HAVING total_laid_off_per_country IS NOT NULL
ORDER BY total_laid_off_per_country DESC ;
    
    
-- let's see what's the total layoffs per country and per city in a country and how much does each city contribute to the overall countries layoffs
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

-- lets look at the top 10 countries with most no: of layoffs by ranking them
SELECT *
FROM layoffs_staging2;

SELECT country, SUM(total_laid_off) AS total_per_country,
RANK() OVER (ORDER BY SUM(total_laid_off) DESC) AS Ranking
FROM layoffs_staging2
GROUP BY country
;
-- Now I want to filter out the top 10 countries with most layoffs
-- let's actually store it in a temp table instead of cte this time

CREATE TEMPORARY TABLE Top_10_countries AS
SELECT country, SUM(total_laid_off) AS total_per_country
FROM layoffs_staging2
GROUP BY country
ORDER BY total_per_country DESC
LIMIT 10
;

-- Use that temp table to filter the original table by using inner join
-- then show the total layoffs per industry per country
SELECT t2.country, t1.industry, t2.total_per_country  AS total_country_layoffs, SUM(t1.total_laid_off) AS total_industry_layoffs, 
	(SUM(t1.total_laid_off)/t2.total_per_country) * 100 AS pct_of_country_total
FROM layoffs_staging2 AS t1
JOIN Top_10_countries AS t2
	ON t1.country = t2.country
GROUP BY t2.country, t1.industry, t2.total_per_country
HAVING total_industry_layoffs IS NOT NULL
ORDER BY total_country_layoffs DESC, total_industry_layoffs DESC
;
