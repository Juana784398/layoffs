# World Layoffs Analysis (2020-2023) - SQL Data Exploration

## Project Overview  
This project analyzes global layoffs from 2020–2023 using SQL to uncover patterns in industry volatility, company-level impact, and geographic concentration during major economic disruption periods.

The focus is on transforming raw, inconsistent data into a structured analytical dataset and extracting actionable business insights using SQL-based exploratory analysis.


## Key Insights

- 2022 recorded the highest layoff volume, indicating a delayed economic correction following the initial COVID-era disruption.  
- Consumer and Retail sectors experienced the highest overall layoffs, while major Tech firms dominated individual layoff events.  
- Amazon recorded the highest cumulative layoffs (~18,150), followed by Google, Meta, Salesforce, and Microsoft.  
- Google recorded the largest single-day layoff event (~12,000 employees).  
- Layoffs were heavily concentrated in major tech hubs, with a small number of cities contributing a disproportionate share of national totals.  
- 116 companies experienced 100% workforce reductions, indicating full shutdowns despite substantial funding and capital backing.  

## Tools & Skills

- SQL (MySQL Workbench)
- Data Cleaning & Standardization  
- Exploratory Data Analysis (EDA)  
- Window Functions (ROW_NUMBER, DENSE_RANK)  
- CTEs & Temporary Tables  
- Time-Series Analysis  
- Data Aggregation & Ranking  

## Project Assets

* [Data Cleaning Script](scripts/layoffs_data_cleaning.sql) - Final code for data cleaning and standardization 
* [EDA Script](scripts/layoffs_eda.sql) - Final exploratory analysis queries and trend analysis  
* [Cleaning Working Notes](scripts/layoffs_data_cleaning_working_notes.sql) - Iterative validation and development queries  
* [EDA Working Notes](scripts/layoffs_eda_working_notes.sql) - Draft analysis queries and exploratory workflow  


## Dataset

The dataset contains layoffs data with 9 columns categorized into:
* **Company metadata:** `company`, `industry`, `stage`, `funds_raised_millions`
* **Geographic markers:** `location`, `country`
* **Layoff metrics:** `total_laid_off`, `percentage_laid_off`
* **Timeline:** `date` 


## Analysis Approach

### 1. Data Cleaning & Standardization
- Removed duplicate records using window functions  
- Standardized industry naming inconsistencies  
- Converted date fields into proper SQL `DATE` format  
- Imputed missing industry values using self-joins  
- Removed rows with no usable layoff data  


### 2. Exploratory Analysis

#### Macro-Level Analysis
- Identified extreme events (largest layoffs, full company shutdowns)  
- Measured overall distribution of layoffs across dataset  

#### Industry & Company Impact
- Aggregated total layoffs by industry and company  
- Identified most affected sectors and firms  

#### Time-Series Trends
- Analyzed yearly and monthly layoff patterns  
- Identified peak periods using aggregated timelines  

#### Ranking Analysis
- Used `DENSE_RANK()` to identify top companies and industries per year  
- Compared relative impact across time periods  

#### Geographic Distribution
- Analyzed country and city-level concentration of layoffs  
- Measured regional contribution to global totals  


## Technical Highlights

- Built multi-stage data cleaning pipeline using staging tables  
- Applied window functions for duplicate removal and ranking logic  
- Used CTEs for structured, modular SQL analysis  
- Performed hierarchical aggregations (company → industry → country)  
- Designed reusable SQL queries for trend and ranking analysis  


## Outcome

The cleaned dataset enabled structured analysis of global workforce reductions and revealed clear macroeconomic patterns across industries and geographies.

This project demonstrates the ability to:
- Clean and structure raw datasets using SQL  
- Perform exploratory and trend-based analysis  
- Extract business-relevant insights from large datasets  
- Communicate findings in a structured analytical format  
