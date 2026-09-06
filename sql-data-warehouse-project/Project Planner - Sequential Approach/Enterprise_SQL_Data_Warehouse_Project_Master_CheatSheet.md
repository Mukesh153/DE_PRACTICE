# End-to-End Enterprise Data Warehouse Engineering: Master Interview Cheat Sheet

A comprehensive, production-grade guide synthesizing the complete end-to-end lifecycle of an Enterprise Data Warehouse project. Based on real-world engineering workflows, Medallion Architecture, Kimball Dimensional Modeling, Stored Procedure ETL pipelines, data governance, and SQL Server implementations.

---

## Master Project Blueprint & Architecture Flow

```
+-----------------------------------------------------------------------------------------------------------------------+
|                                    END-TO-END DATA PIPELINE LIFECYCLE (MEDALLION)                                     |
|                                                                                                                       |
|  [ SOURCES ]                      [ BRONZE LAYER ]                [ SILVER LAYER ]                 [ GOLD LAYER ]     |
|                                   (Raw / Traceability)          (Cleansed / Standardized)        (Business Star Schema|
|  +--------------+                                                                                                     |
|  | CRM (CSV)    | --BULK INSERT-> +-------------------+         +-------------------+            +------------------+ |
|  | - Customers  |                 | bronze.crm_*      | ------> | silver.crm_*      | --VIEWS--> | gold.dim_cust    | |
|  | - Products   |                 | (Raw Text, As-Is) | (Clean) | (Casted, Trimmed) | (Kimball)  | gold.dim_prod    | |
|  | - Sales Det. |                 +-------------------+         +-------------------+            | gold.fact_sales  | |
|  +--------------+                           |                             |                      +------------------+ |
|  +--------------+                           |                             |                               |           |
|  | ERP (CSV)    | --BULK INSERT-> +-------------------+         +-------------------+                     v           |
|  | - Cust Demog |                 | bronze.erp_*      | ------> | silver.erp_*      |             [ CONSUMPTION ]     |
|  | - Locations  |                 | (Raw Text, As-Is) | (Clean) | (Deduplicated,    |             - Power BI / Tableau|
|  | - Categories |                 +-------------------+         |  Enriched)        |             - Ad-hoc SQL        |
|  +--------------+                                               +-------------------+             - ML / Data Science |
+-----------------------------------------------------------------------------------------------------------------------+
```

---

## Phase 1: Foundations & Architecture Selection

### Module 1: Types of SQL Projects in Data Engineering
In production and interview technical evaluations, SQL workloads split into three distinct project categories:

```
                                      SQL PROJECTS SPECTRUM
                                                |
        +---------------------------------------+---------------------------------------+
        |                                       |                                       |
        v                                       v                                       v
[ DATA WAREHOUSING ]                 [ EXPLORATORY ANALYSIS (EDA) ]       [ ADVANCED DATA ANALYTICS ]
"Organize, Structure, Prepare"       "Understand Data Profiling"          "Answer Strategic Questions"
- Architecture & Medallion Design    - Schema inspections & data types    - Window Functions & Rank/Dense_Rank
- ETL / ELT batch pipelines          - Descriptive stats & distributions  - Multi-CTE query trees
- Data cleaning & normalization      - Spotting anomalies, nulls, gaps    - Cohort retention & churn logic
- Star / Snowflake dimensional model - Exploratory joins & subqueries     - Business metric reporting (KPIs)
```

| Project Class | Focus & Purpose | Core SQL Techniques | Target Outcome |
| :--- | :--- | :--- | :--- |
| **Data Warehousing** | Ingestion, data hygiene, dimensional modeling, and establishing pipelines. | DDL, DML, `BULK INSERT`, Stored Procedures, `MERGE`, Indexing. | Scalable, reliable analytical data models (Gold Star Schema). |
| **Exploratory Data Analysis (EDA)** | Profiling ingested data, understanding cardinalities, finding gaps. | `COUNT(DISTINCT)`, `GROUP BY`, summary statistics, outlier filters. | Clean technical specifications for downstream transformations. |
| **Advanced Data Analytics** | Solving business problems, finding growth drivers, executive reporting. | Window aggregations, recursive CTEs, pivoting, statistical percentiles. | Business intelligence dashboards, revenue forecasts, executive decisions. |

---

### Module 2: The Core Problem: Why Direct Reporting Fails
In traditional transactional architectures without a Data Warehouse, departments (Finance, Sales, Marketing) run individual ad-hoc reports directly on operational database instances:

```
WITHOUT DATA WAREHOUSE (Fragmented Silos - Days to Weeks of Manual Labor)
[ Operational DB 1 ] ---> (Manual Pull) ---> Excel Sheet 1 [ Operational DB 2 ] ---> (Manual Pull) ---> Excel Sheet 2  +---> Conflicting Reports (Takes 40 Days!)
[ Big Data Source  ] ---> (Failed Pull) ---> DB Crash / Lock/

WITH DATA WAREHOUSE (Automated Ingestion - Fast, Hours to Minutes)
[ All Source DBs ] ---> [ ETL / ELT Engine ] ---> [ Centralized DW ] ---> [ Single Version of Truth ] (1 Day / Hours)
```

1. **Transactional Lockouts**: Complex aggregations lock live tables in operational databases, failing point-of-sale customer transactions.
2. **Conflicting Business Definitions**: Marketing calculates revenue after refunds; Finance calculates revenue before taxes. No single version of truth exists.
3. **Data Volume Bottlenecks**: Operational systems struggle when joining terabytes of historical time-series data with external unstructured files.
4. **Bill Inmon's 4 Mandatory Data Warehouse Pillars**:
   * **Subject-Oriented**: Organized by business domain (Customer, Product, Sales) rather than operational application workflows.
   * **Integrated**: Standardizes naming, unit conversions, and data formats across disparate systems.
   * **Time-Variant**: Preserves historical trends via timestamps, snapshot dates, and surrogate keys.
   * **Non-Volatile**: Data is immutable once committed; operational mutations append new records rather than overwriting historical facts.

---

### Module 3: Modern ETL & ELT Lifecycle Mechanics
ETL (Extract, Transform, Load) defines the physical data transformation lifecycle across pipeline stages:

```
[ EXTRACTION ]                     [ TRANSFORMATION ]                   [ LOADING ]
- Push vs. Pull Methods            - Data Cleansing (Nulls, Spaces)     - Batch vs. Streaming
- Full vs. Incremental (CDC)       - Type Casting & Deduplication       - Truncate & Insert (Full)
- Source API / File / Direct DB    - Business Rules & Calculations      - Upsert / Merge / Append (Delta)
                                   - Derived Columns & Enrichment       - Slowly Changing Dimensions (SCD)
```

* **Extraction Paradigms**:
  * **Pull Extraction**: The DW pipeline queries or polls source systems on scheduled batch intervals.
  * **Push Extraction**: Source applications stream events or trigger webhooks as soon as transactions occur.
  * **Incremental Extraction (CDC)**: Leverages Change Data Capture (database write-ahead transaction logs) to extract only delta inserts/updates without scanning entire source tables.
* **Loading Strategies**:
  * **Truncate & Insert**: Drops all table contents and reloads from scratch. Safe and simple for small tables, lookups, or transient Bronze staging.
  * **Upsert (MERGE)**: Updates existing records matching business keys; inserts brand-new incoming records.
  * **Append-Only**: Appends incoming time-stamped events without modifying prior rows (optimal for immutable fact tables).

---

### Module 4: Project Scope & Technical Requirements
* **Objective**: Build a production-grade modern Data Warehouse on **Microsoft SQL Server** consolidating disparate customer, product, and sales transactions.
* **Source Systems**:
  * **CRM System**: Customer contact details, product catalogs, and transactional sales details (Delivered as raw CSV files).
  * **ERP System**: Customer demographic profiles, geographic store locations, and category lookup hierarchies (Delivered as raw CSV files).
* **Engineering Scope**:
  * Implement strict data quality checks, data cleaning, and deduplication.
  * Consolidate CRM and ERP into an integrated analytical Star Schema.
  * Scope: Current operational snapshot (historization/SCD2 out of scope for initial MVP).
  * Full version control, automated stored procedures, DDL scripts, and technical documentation.

---

### Module 5 & 6: Data Architecture Decision & Medallion Layering

#### Why Medallion Architecture over Classic Inmon or Kimball Alone?
* **Inmon (Top-Down)**: Requires extensive upfront 3NF modeling of the entire enterprise before delivering value; slow time-to-market.
* **Kimball (Bottom-Up)**: Direct pipeline build into Star Schema marts can lead to duplicated cleaning pipelines across marts without a unified staging foundation.
* **Medallion Architecture Choice**: Combines the best of both worlds by establishing strict **Separation of Concerns (SoC)** across three physical storage stages:

```
                               MEDALLION LAYER SPECIFICATIONS
+--------------------------------------------------------------------------------------------------------+
| Dimension           | Bronze Layer                 | Silver Layer              | Gold Layer            |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Core Definition** | Raw, unprocessed source data | Cleaned, standardized,    | Business-ready,       |
|                     | loaded as-is.                | and enriched data.        | modeled presentation. |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Core Objective**  | Traceability, auditing, and  | Prepare data for analysis | Fast reporting, BI    |
|                     | rapid debugging.             | and analytical modeling.  | dashboards, & KPIs.   |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Database Object** | Physical Tables              | Physical Tables           | SQL Views             |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Load Strategy**   | Full Load (Truncate & Insert)| Full Load / Upsert        | None (Dynamic queries)|
+---------------------+------------------------------+---------------------------+-----------------------+
| **Transformations** | None (100% As-Is)            | Cleansing, Trim, Casting, | Integration, Aggs,    |
|                     |                              | Normalization, Derived    | Kimball Star Schema   |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Data Modeling**   | Flat raw source structure    | Normalized staging        | Dimensional Model     |
|                     |                              |                           | (Fact & Dimensions)   |
+---------------------+------------------------------+---------------------------+-----------------------+
| **Target Audience** | Data Engineers               | Data Engineers / Analysts | BI Analysts, End-Users|
+--------------------------------------------------------------------------------------------------------+
```

---

## Phase 2: Project Setup & Initialization

### Module 7 & 8: Environment Configuration & Naming Conventions
To ensure maintainability across distributed engineering teams, rigorous naming conventions and directory structures are enforced:

```
sql-data-warehouse-project/
├── datasets/                     # Raw ERP and CRM source CSV files
├── docs/                         # Technical documentation, catalogs, architecture diagrams
│   ├── data_architecture.png
│   ├── data_catalog.md
│   ├── data_flow.png
│   └── naming_conventions.md
├── scripts/                      # DDL and Stored Procedures by layer
│   ├── init_database.sql         # Master database and schema creation
│   ├── bronze/                   # DDL & proc_load_bronze.sql
│   ├── silver/                   # DDL & proc_load_silver.sql
│   └── gold/                     # DDL (Views) ddl_gold.sql
└── tests/                        # Data quality assertion suites
    ├── quality_checks_silver.sql
    └── quality_checks_gold.sql
```

* **Schema Naming**: Reflects medallion stages: `bronze`, `silver`, `gold`.
* **Table Naming**:
  * Bronze & Silver: `<source_system>_<entity>` (e.g., `bronze.crm_cust_info`, `silver.erp_loc_a101`).
  * Gold: `dim_<business_entity>` and `fact_<business_process>` (e.g., `gold.dim_customers`, `gold.fact_sales`).
* **Stored Procedures**: `proc_load_<layer>` (e.g., `bronze.proc_load_bronze`).

---

### Module 9 & 10: Master Database & Schema Initialization (`init_database.sql`)
The database and schemas are initialized via idempotent SQL scripts:

```sql
/*
===============================================================================
Script: init_database.sql
Purpose: Create DataWarehouse database and initialize medallion architecture schemas.
===============================================================================
*/

USE master;
GO

-- Drop and recreate database if it already exists
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Create Medallion Architecture Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
```

---

## Phase 3: Building the Bronze Layer (Raw Ingestion)

```
[ BRONZE PIPELINE WORKFLOW ]
[ Source System Analysis ] ---> [ DDL Definition (All VARCHAR) ] ---> [ BULK INSERT Procedure ] ---> [ Validation Checks ]
```

### Module 11 & 12: Source System Analysis
Before writing ingestion DDL, engineers evaluate:
1. **Ownership & Data Governance**: Who owns the source ERP/CRM, and what upstream SLAs apply?
2. **Integration Capabilities**: File-based CSV drops vs. API limits vs. direct read replicas.
3. **Network & Extraction Impact**: Ensuring bulk extracts run off-peak to prevent degrading operational POS performance.

---

### Module 13: Bronze DDL Table Design
Bronze tables mirror source structures exactly. All columns are configured as permissive `NVARCHAR(MAX)` or large `VARCHAR` to ensure ingestion never fails due to unexpected formatting, dirty characters, or casting errors:

```sql
-- Bronze CRM Tables
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

-- Bronze ERP Tables
CREATE TABLE bronze.erp_cust_az12 (
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50)
);

CREATE TABLE bronze.erp_loc_a101 (
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);

CREATE TABLE bronze.erp_px_cat_g1v2 (
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintenance NVARCHAR(50)
);
```

---

### Module 14: Automated High-Performance Bronze Load (`proc_load_bronze.sql`)
Data is ingested using SQL Server's high-speed `BULK INSERT` engine, wrapped in an automated stored procedure with execution profiling, row counts, and error-trapping blocks:

```sql
CREATE OR ALTER PROCEDURE bronze.proc_load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME;
    BEGIN TRY
        SET @batch_start_time = GETDATE();
        PRINT '================================================';
        PRINT 'Loading Bronze Layer Started...';
        PRINT '================================================';

        -- Truncate & Load crm_cust_info
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Bulk inserting into: bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLEREMOVING = '
',
            TABLOCK
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + ' seconds';

        -- [Additional Bulk Inserts for remaining CRM and ERP tables...]

        PRINT 'Bronze Layer Ingestion Completed Successfully.';
    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE INGESTION!';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';
    END CATCH
END;
```

---

## Phase 4: Building the Silver Layer (Cleansing & Standardization)

```
[ SILVER CLEANSING PIPELINE ]
[ Bronze Raw Data ] ---> [ Whitespace Trimming ] ---> [ Data Type Casting ] ---> [ Business Calculation Validation ] ---> [ Silver Storage ]
```

### Module 16 & 18: Silver DDL & Technical Audit Metadata
Silver tables introduce clean, strongly typed schemas and append system-level technical metadata columns to establish data lineage:

* **Technical Metadata Columns**:
  * `dwh_create_date`: Audit timestamp recording when the record was processed into the warehouse layer (`DEFAULT GETDATE()`).
  * `source_system`: Identifies source origin (`'CRM'` vs. `'ERP'`).

```sql
CREATE TABLE silver.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE,
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
```

---

### Module 19 & 20: Silver Cleansing Rules & Production Stored Procedure

```
COMMON DATA QUALITY CLEANING RULES APPLIED IN SILVER:
1. Whitespace Cleaning:       UPPER(TRIM(cst_firstname))
2. Code Standardization:      CASE UPPER(TRIM(cst_gndr)) WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE 'n/a' END
3. Handling Missing Nulls:    COALESCE(country_code, 'n/a')
4. Mathematical Invariants:   Sales = Quantity * Price (Strict Rule: No negative or zero prices allowed!)
```

#### Production Business Calculation Correction Script
If raw source data contains negative prices, missing sales, or mismatched totals ($	ext{Sales} 
e 	ext{Quantity} 	imes 	ext{Price}$), clean them conditionally using `CASE` and `NULLIF`:

```sql
INSERT INTO silver.crm_sales_details (
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
)
SELECT 
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    -- Fix Integer Dates (e.g. 20260101 -> DATE)
    CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE) END AS sls_order_dt,
    CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE) END AS sls_ship_dt,
    CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
         ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE) END AS sls_due_dt,
    -- Recalculate or Clean Sales Amount
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales 
    END AS sls_sales,
    sls_quantity,
    -- Derive or Correct Unit Price
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0 
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price) 
    END AS sls_price
FROM bronze.crm_sales_details;
```

---

## Phase 5: Building the Gold Layer (Kimball Dimensional Star Schema)

```
                              SALES DATA MART (STAR SCHEMA)
                              
      +-----------------------------+                 +-----------------------------+
      |     gold.dim_customers      |                 |      gold.dim_products      |
      +-----------------------------+                 +-----------------------------+
      | PK  customer_key (Surrogate)|                 | PK  product_key (Surrogate) |
      |     customer_id             |                 |     product_id              |
      |     customer_number         |                 |     product_number          |
      |     first_name              |                 |     product_name            |
      |     last_name               |                 |     category                |
      |     country                 |                 |     subcategory             |
      |     marital_status          |                 |     cost                    |
      |     gender                  |                 |     product_line            |
      |     birthdate               |                 |     start_date              |
      +--------------+--------------+                 +--------------+--------------+
                     |                                               |
                     |             +-------------------+             |
                     +------------>|  gold.fact_sales  |<------------+
                                   +-------------------+
                                   |     order_number  | (Degenerate Dimension)
                                   | FK  customer_key  |
                                   | FK  product_key   |
                                   |     order_date    |
                                   |     shipping_date |
                                   |     due_date      |
                                   |     sales_amount  | (Additive Fact)
                                   |     quantity      | (Additive Fact)
                                   |     price         | (Non-Additive Fact)
                                   +-------------------+
```

### Module 21 & 22: Conceptual, Logical & Physical Modeling
* **Conceptual Model (Big Picture)**: High-level entities and business relationships (`Customers` create `Orders`; `Orders` contain `Products`).
* **Logical Model (The Blueprint)**: Defines primary keys, foreign key linkages, and attributes independent of physical database constraints.
* **Physical Model (Implementation)**: Concrete database objects with explicit data types, indexing, views, and partitioning schemes.

---

### Module 23 & 26: Building Dimensional Views (`ddl_gold.sql`)
Gold objects are implemented as **SQL Views** directly over Silver tables. This provides zero storage duplication, near-instant refresh, and modular abstraction:

#### 1. Gold Dimension: Customer (`gold.dim_customers`)
Integrates CRM demographics with ERP geographic locations:

```sql
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Surrogate Key
    ci.cst_id                          AS customer_id,
    ci.cst_key                         AS customer_number,
    ci.cst_firstname                   AS first_name,
    ci.cst_lastname                    AS last_name,
    la.cntry                           AS country,
    ci.cst_marital_status              AS marital_status,
    CASE 
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END                                AS gender,
    ca.bdate                           AS birthdate,
    ci.cst_create_date                 AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la  ON ci.cst_key = la.cid;
```

#### 2. Gold Dimension: Product (`gold.dim_products`)
Integrates CRM product catalog with ERP category lookup hierarchies:

```sql
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key, -- Surrogate Key
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pc.cat          AS category,
    pc.subcat       AS subcategory,
    pc.maintenance  AS maintenance,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pn.prd_key = pc.id
WHERE pn.prd_end_dt IS NULL; -- Filter active current catalog
```

#### 3. Gold Fact: Sales Transactions (`gold.fact_sales`)
Links facts to dimensions via surrogate keys:

```sql
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num     AS order_number, -- Degenerate Dimension
    pr.product_key     AS product_key,  -- Foreign Key
    cu.customer_key    AS customer_key, -- Foreign Key
    sd.sls_order_dt    AS order_date,
    sd.sls_ship_dt     AS shipping_date,
    sd.sls_due_dt      AS due_date,
    sd.sls_sales       AS sales_amount, -- Additive Metric
    sd.sls_quantity    AS quantity,     -- Additive Metric
    sd.sls_price       AS price         -- Unit Measure
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu ON sd.sls_cust_id = cu.customer_id;
```

---

## Phase 6: Governance, Quality Assurance & Data Catalog

### Module 28: Enterprise Data Catalog (`data_catalog.md`)
A production Data Catalog acts as the contract between Data Engineering and Business Consumers (Analysts, BI Developers, Executives). It ensures clear understanding and discoverability of warehouse assets:

```
[ DATA ENGINEER ] ===== Registers Metadata =====> [ DATA CATALOG ] <===== Explores Assets ===== [ DATA ANALYSTS / BI ]
```

* **Asset Registry**: Lists every object, its layer, and its purpose (`gold.dim_customers`, `gold.fact_sales`).
* **Column Data Dictionaries**: Explicit descriptions of business terms, units of measure, nullability, and primary key relationships.
* **Lineage Tracking**: Documents the precise upstream dependencies (e.g., `gold.dim_customers` $\leftarrow$ `silver.crm_cust_info` + `silver.erp_cust_az12`).

---

### Quality Assurance Testing Suites (`quality_checks_silver.sql` & `quality_checks_gold.sql`)
Data quality checks are performed both **before** and **after** each layer is built. A check should return no rows unless a different expectation is stated. Resolve failed checks before moving to the next layer.

#### Pre-build checks (source and upstream readiness)

Run these checks before building the Silver layer. They validate that Bronze data is available and that known source issues are understood before cleansing and type conversion:

```sql
-- Source tables must exist and contain data
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
UNION ALL
SELECT 'crm_prd_info', COUNT(*) FROM bronze.crm_prd_info
UNION ALL
SELECT 'crm_sales_details', COUNT(*) FROM bronze.crm_sales_details;

-- CRM customer IDs should not be null or duplicated in the source
SELECT cst_id, COUNT(*) AS duplicate_count
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL OR COUNT(*) > 1;

-- Source sales dates must be valid eight-digit dates
SELECT sls_order_dt, sls_ship_dt, sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) <> 8
    OR sls_ship_dt <= 0 OR LEN(sls_ship_dt) <> 8
    OR sls_due_dt <= 0 OR LEN(sls_due_dt) <> 8;
```

Run these checks before building Gold. They confirm that Silver has loaded successfully and that the upstream data needed by the dimensional views is usable:

```sql
-- Silver tables must contain data before Gold views are created
SELECT 'crm_cust_info' AS table_name, COUNT(*) AS row_count FROM silver.crm_cust_info
UNION ALL
SELECT 'crm_prd_info', COUNT(*) FROM silver.crm_prd_info
UNION ALL
SELECT 'crm_sales_details', COUNT(*) FROM silver.crm_sales_details;

-- Silver sales measures must satisfy the business invariant
SELECT sls_ord_num, sls_sales, sls_quantity, sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
    OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0
    OR sls_sales <> sls_quantity * sls_price;
```

#### Post-build checks (layer acceptance)

After the Silver load, run [`tests/quality_checks_silver.sql`](../tests/quality_checks_silver.sql). It validates null or duplicate keys, whitespace, standardized codes, non-negative costs, date order, valid dates, and the sales calculation invariant across Silver tables.

After the Gold views are created, run [`tests/quality_checks_gold.sql`](../tests/quality_checks_gold.sql). It validates uniqueness of customer and product surrogate keys and confirms that every fact row connects to both dimensions:

```sql
-- Duplicate surrogate keys must not exist
SELECT customer_key, COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT product_key, COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- Every fact row must resolve to both dimensions
SELECT f.order_number, f.customer_key, f.product_key
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p ON p.product_key = f.product_key
WHERE c.customer_key IS NULL OR p.product_key IS NULL;
```

Recommended execution order: **Bronze load -> Silver pre-build checks -> Silver load -> Silver post-build checks -> Gold pre-build checks -> Gold view creation -> Gold post-build checks**.

---

## High-Yield Technical Interview Q&A

### Q1: Why did you choose the Medallion Architecture instead of loading directly into a Star Schema?
**Answer:** Loading directly from raw files into a Star Schema couples data extraction with complex business modeling. If source formats change or an error is discovered in business logic, you have to re-extract everything from scratch. Medallion architecture enforces **Separation of Concerns**:
* **Bronze** provides an immutable, auditable landing zone for raw data.
* **Silver** centralizes data hygiene, typing, and deduplication into clean tables.
* **Gold** allows fast, flexible dimensional modeling via SQL views without duplicating physical disk storage.

### Q2: Why define the Gold Layer as Views rather than physical tables?
**Answer:** Views in the Gold Layer eliminate redundant storage and remove the need for complex pipeline synchronization between Silver and Gold. Since data is already cleaned and standardized in Silver tables, Gold views apply the business logic, joins, and surrogate key generation dynamically. If query latency requires physical storage later, views can be converted into indexed/materialized views without changing the downstream BI reporting contracts.

### Q3: How did you handle data quality issues where Sales Amount did not equal Quantity $	imes$ Price?
**Answer:** In the Silver stored procedure, conditional logic evaluates data integrity using `CASE` and `NULLIF`:
* If `Price` is zero or null, it is back-calculated as $rac{	ext{Sales}}{	ext{Quantity}}$.
* If `Sales` is missing or mismatched, it is recalculated as $	ext{Quantity} 	imes |	ext{Price}|$.
* Negative values are converted using `ABS()`, ensuring that no corrupted or negative metrics enter the Gold analytical layer.

### Q4: What is the purpose of the Degenerate Dimension in your Sales Fact table?
**Answer:** `order_number` acts as a **Degenerate Dimension**. It is an operational transaction identifier that has no associated descriptive attributes of its own (unlike a product or customer), but is essential in the Fact table for grouping line items on the same receipt and calculating basket-analysis metrics.
