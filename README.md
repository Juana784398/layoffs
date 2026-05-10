# World Layoffs: Data Cleaning & Exploratory Data Analysis

## Project Overview

This project follows end-to-end data lifecycle of `layoffs` dataset using `MySQL`. Raw, inconsistent data was transformed into a structured format followed by Exploratory Data Analysis (EDA) to uncover key economic trends and sector-level volatility between 2020 and 2023.


## Tools & Skills
* **Database:** MySQL Workbench
* **SQL Techniques:** Staging Tables, CTEs, Window Functions (`ROW_NUMBER`, `DENSE_RANK`), Self-Joins, Temporary Tables, String Manipulation, Data Type Casting.
* **Analysis:** Time-Series Analysis, Hierarchical Aggregation, Sector Concentration, Data Integrity Validation.


## Data Structure
The dataset comprises of 9 columns categorized into:
* **Corporate Identifiers:** `company`, `industry`, `stage`, `funds_raised_millions`
* **Geographic Markers:** `location`, `country`
* **Layoff Metrics & Timeline:** `total_laid_off`, `percentage_laid_off`, `date`

## Project Documentation
Detailed scripts document the iterative development process, including validation steps and inline commentary. These were used to track decisions and verify results throughout the project.
* **[Data Cleaning Script:](scripts/layoffs_data_cleaning.sql)**  Final code used to clean and standardize the dataset.
* **[EDA Script:](scripts/layoffs_eda.sql)** SQL queries used to explore trends and generate insights.
* **[Cleaning Working Notes:](scripts/layoffs_data_cleaning_working_notes.sql)** Step-by-step Iterative queries and validation steps during data cleaning development.
* **[EDA Working Notes:](scripts/layoffs_eda_working_notes.sql)** Exploratory draft queries and notes capturing the analysis process



## Part 1: Data Cleaning Workflow

### Summary
* **De-duplication:** Identified and removed duplicates using Window Functions and a secondary staging table.
* **Standardization:** Unified industry labels and cleaned up inconsistent string values.
* **Type Casting:** Converted `date` column from `TEXT` to `DATE` format using `STR_TO_DATE()`.
* **Imputation:** Used self-joins on company names to populate missing industry values where possible.
---

### Detailed Process

<details>
<summary><b>1. Staging and De-duplication</b></summary>

A staging environment was created to protect the raw source data. Since the dataset lacked a unique primary key, a **CTE** and **Window Function** identified duplicates by partitioning across all columns.

**Technical Choice:** A secondary staging table with a `row_num` column was to facilitate the removal of duplicates, as MySQL does not support direct `DELETE` operations on CTEs.

**Action:** Populated `layoffs_staging2` and filtered out rows where `row_num > 1`.
</details>

<details>
<summary><b>2. Standardization & Type Casting</b></summary>

* **Trimming:** Removed leading and trailing whitespace from text fields.
* **Consolidation:** Merged inconsistent labels (e.g., 'Crypto Currency' and 'Cryptocurrency' --> 'Crypto').
* **Data Typing:** Converted the `date` column from `TEXT` to `DATE` using `STR_TO_DATE()` to enable time-series analysis.
</details>

<details>
<summary><b>3. Handling Nulls and Data Imputation</b></summary>

**Self-joins** were used to populate missing `industry` records. By joining the table to itself on the `company` name, missing values were filled using existing entries from the same company.
</details>

<details>
<summary><b>4. Final Pruning</b></summary>

Removed records where both `total_laid_off` and `percentage_laid_off` were `NULL`, as they provided no actionable insight for analysis.
</details>

## Part 2: Exploratory Analysis Workflow
### Summary
* **Macro Analysis:** Identified dataset boundaries, major layoff events, and company shutdowns.
* **Categorical Analysis:** Aggregated layoffs across company, industry, country, and funding stage.
* **Time-Series Analysis:** Analyzed yearly and monthly trends, including rolling totals.
* **Ranking Analysis:** Identified top companies and industries with most layoffs per year using window functions.
* **Geographic Analysis:** Examined how cities contributed to overall country-level layoffs.
* **Sector Analysis:** Analyzed industry concentration within the most affected countries.

### Detailed Process
<details>
<summary><b>1. Macro-Level Discovery & Outliers</b></summary>

Started by exploring the dataset to understand its structure, range and identify extreme values.

* Identified the largest single layoff events and full company shutdowns.
* Analyzed companies with 100% workforce reductions to identify failed startups
</details>

<details>
<summary><b>2. Categorical Aggregations</b></summary>

Aggregated layoffs across key business dimensions to understand where the impact was most significant.
* **Company-Level:** Identified companies with the highest total layoffs
* **Industry-Level:** Highlighted the most affected sectors
* **Country-Level:** Compared impact across countries
* **Funding Stage:** Analyzed layoffs across different stages of company growth
</details>

<details>
<summary><b>3. Time-Series Analysis & Trend Identification</b></summary>

Analyzed temporal patterns to uncover trends and cycles in layoffs.
* Determined dataset timeframe (2020–2023)
* Compared yearly totals to identify peak periods
* Calculated monthly rolling totals using CTEs and window functions to visualize cumulative trends
</details>

<details>
<summary><b>4. Competitive Ranking (Advanced Window Functions)</b></summary>

Used `DENSE_RANK()` to identify top-performing entities within each year.
* Ranked top 5 companies by layoffs per year
* Ranked top 5 industries by layoffs per year
* Enabled year-over-year comparison of major contributors
</details>

<details>
<summary><b>5. Geographic Contribution Analysis</b></summary>

Analyzed how individual locations contribute to national layoff totals.
* Calculated total layoffs per country and per city
* Measured each city's percentage contribution to its country’s total
* Highlighted regional concentration within high-impact countries
</details>

<details>
<summary><b>6. Sector Concentration within Top Countries</b></summary>

Focused analysis on the top 10 most affected countries.
* Isolated top countries by total layoffs
* Analyzed which industries contributed most within each country
* Calculated industry share as a percentage of national totals
</details>

<details>
<summary><b>7. Methodological Notes & Limitations</b></summary>

The `percentage_laid_off` column was not used for aggregate analysis due to lack of total workforce data, which can lead to misleading interpretations.

Analysis focused primarily on `total_laid_off` to ensure more reliable and comparable insights.
</details>


## Final Result
The dataset was cleaned and standardized, then used to analyze key trends in global layoffs between 2020 and 2023. The final output includes a ready-to-use dataset (`layoffs_staging2`) and a set of analytical SQL queries.


## Key Findings
* **Peak Volatility:** Although layoffs began in 2020, 2022 recorded the highest volume, indicating a delayed economic correction.

* **Industry Drivers:** Consumer and Retail sectors saw the highest overall layoffs. Among individual companies, Amazon led in total layoffs (18,150), followed by Google, Meta, Salesforce, and Microsoft. Google also recorded the largest single-day event (12,000 layoffs).

* **Geographic Concentration:** Layoffs were concentrated in key tech hubs, with a small number of cities contributing a significant share of national totals.

* **Startup Mortality:** 116 companies (primarily well-funded startups) experienced 100% layoffs, indicating total liquidation despite substantial capital and funding.


---
