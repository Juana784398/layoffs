# World Layoffs: Data Cleaning & Exploratory Data Analysis

## Project Overview

This project follows **end-to-end data lifecycle** of `layoffs` dataset using `MySQL`. Raw, inconsistent data was transformed into a structured format to conduct a deep-dive Exploratory Data Analysis (EDA), uncovering critical economic trends and sectoral volatility between 2020 and 2023.


## Tools & Skills
* **Database:** MySQL Workbench
* **SQL Techniques:** Staging Tables, CTEs, Window Functions (`ROW_NUMBER`, `DENSE_RANK`), Self-Joins, Temporary Tables, String Manipulation, Data Type Casting.
* **Analysis:** Time-Series Analysis, Hierarchical Aggregation, Sector Concentration, Data Integrity Validation.


## Data Structure
The dataset comprises 9 columns categorized into:
* **Corporate Identifiers:** `company`, `industry`, `stage`, `funds_raised_millions`
* **Geographic Markers:** `location`, `country`
* **Layoff Metrics & Timeline:** `total_laid_off`, `percentage_laid_off`, `date`

## Project Documentation
Detailed scripts document the iterative development process, including validation steps and inline commentary: 
* **[Data Cleaning Script:](./layoffs_data_cleaning.sql)**  Final production code for data standardization
* **[EDA Script:](./layoffs_eda.sql)** Comprehensive analytical queries for trend discovery.
* **[Cleaning Working Notes:](./layoffs_data_cleaning_working_notes.sql)** Step-by-step development and validation logic.
* **[EDA Working Notes:](./layoffs_eda_working_notes.sql)** Analytical thought process and exploratory draft queries



## Part 1: Data Cleaning Workflow

### Summary
* **De-duplication:** Identified and removed duplicates using Window Functions and a secondary staging table.
* **Standardization:** Unified industry labels and cleaned string values for consistency.
* **Type Casting:** Converted `date` column from `TEXT` to `DATE` format using `STR_TO_DATE()`.
* **Imputation:** Populated missing industry values using Self-Joins based on company matches.

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
* **Consolidation:** Unified inconsistent naming conventions (e.g., 'Crypto Currency' and 'Cryptocurrency' --> 'Crypto').
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
* **Macro Analysis:** Identified dataset boundaries, extreme layoff events, and company shutdowns
* **Categorical Analysis:** Aggregated layoffs by company, industry, country, and funding stage
* **Time-Series Analysis:** Analyzed yearly and monthly trends, including rolling totals
* **Ranking Analysis:** Identified top companies and industries per year using window functions
* **Geographic Analysis:** Measured city-level contributions to country-wide layoffs
* **Sector Analysis:** Evaluated industry concentration within the top 10 most affected countries

### Detailed Process
<details>
<summary><b>1. Macro-Level Discovery & Outliers</b></summary>

Initial exploration was conducted to understand the dataset’s structure, range, and extreme values.
* Identified maximum layoffs in a single event and full company shutdowns
* Highlighted major outliers, including large-scale layoffs by major companies
* Analyzed companies with 100% workforce reductions to detect failed startups
</details>

<details>
<summary><b>2. Categorical Aggregations</b></summary>

Aggregated total layoffs across key business dimensions to identify high-impact segments.
* **Company-Level:** Identified organizations with the highest total layoffs
* **Industry-Level:** Determined the most volatile sectors
* **Country-Level:** Compared geographic impact across nations
* **Funding Stage:** Evaluated layoffs across different business maturity levels
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

Focused analysis on the top 10 most affected countries using temporary tables.
* Isolated top countries by total layoffs
* Analyzed which industries contributed most within each country
* Calculated industry share as a percentage of national totals
</details>

<details>
<summary><b>7. Methodological Notes & Limitations</b></summary>

The `percentage_laid_off` column was not used for aggregate analysis due to lack of total workforce context, which can lead to misleading interpretations.

Analysis focused primarily on `total_laid_off` to ensure more reliable and comparable insights.
</details>


## Final Result
The dataset was successfully cleaned, standardized, and analyzed to reveal the key trends in global layoffs between 2020 and 2023. The final outputs include a production-ready dataset (layoffs_staging2) and a comprehensive suite of analytical queries.

### Key Findings
* **Peak Volatility:** Although layoffs began in 2020, 2022 recorded the highest volume, indicating a delayed economic correction

* **Industry Drivers:** Consumer and Retail sectors saw the highest aggregate layoffs. Tech companies dominated by their individual impact: Amazon led in cumulative losses (18,150) followed by Google, Meta, Salesforce and Miscrosoft. Google held the record for the largest single-day event of 12,000 layoffs.

* **Geographic Concentration:** Layoffs were concentrated in key tech hubs, with a small number of cities contributing a significant share of national totals

* **Startup Mortality:** 116 companies (primarily well-funded startups) experienced 100% layoffs, indicating total liquidation despite substantial capital and funding.


---