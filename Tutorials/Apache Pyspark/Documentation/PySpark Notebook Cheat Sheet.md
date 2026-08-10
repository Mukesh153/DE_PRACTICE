# PySpark Notebook Cheat Sheet

## 1. Notebook Notes
- `display(df)` is Databricks-style; use `df.show()` in local PySpark.
- `dbutils.fs.ls('/FileStore/tables/')` lists files in Databricks file storage.
- Notebook flow covers:
  - JSON + CSV read, schema inspection, schema definition, transformations, and DataFrame combination.

## 2. Data Loading
- JSON: `spark.read.format('json').option('inferSchema', True).option('header', True).load(path)`
- CSV: `spark.read.format('csv').option('inferSchema', True).option('header', True).load(path)`
- Custom schema with DDL: `.schema("""col1 STRING, col2 INT""")`
- Custom schema with StructType: `StructType([StructField('col1', StringType(), True), ...])`

## 3. Inspect Schema
- `df.printSchema()` → display schema tree
- `df.show()` / `df.display()` → preview rows

## 4. Select & Rename
- `df.select(col('A'), col('B'))`
- `col('A').alias('A_new')`
- `df.withColumnRenamed('A', 'A_new')`

## 5. Filter
- Single condition: `df.filter(col('Item_Fat_Content') == 'Regular')`
- Multiple conditions: `df.filter((col('Item_Type') == 'Soft Drinks') & (col('Item_Weight') < 10))`
- Null check: `col('Outlet_Size').isNull()`
- Membership: `col('Outlet_Location_Type').isin('Tier 1', 'Tier 2')`

## 6. Add / Change Columns
- Add constant: `df.withColumn('flag', lit('new'))`
- Derived column: `df.withColumn('multiply', col('Item_Weight') * col('Item_MRP'))`
- Replace text values: `df.withColumn('Item_Fat_Content', regexp_replace(col('Item_Fat_Content'), 'Regular', 'Reg'))`
- Cast type: `df.withColumn('Item_Weight', col('Item_Weight').cast(StringType()))`

## 7. Sort / Limit
- Descending sort: `df.sort(col('Item_Weight').desc())`
- Ascending sort: `df.sort(col('Item_Visibility').asc())`
- Multi-column sort: `df.sort(['Item_Weight', 'Item_Visibility'], ascending=[0, 1])`
- Limit rows: `df.limit(10)`

## 8. Clean Data
- Drop one column: `df.drop('Item_Visibility')`
- Drop multiple columns: `df.drop('Item_Visibility', 'Item_Type')`
- Remove duplicates: `df.dropDuplicates()`
- Remove duplicates by subset: `df.drop_duplicates(subset=['Item_Type'])`
- Distinct rows: `df.distinct()`

## 9. Combine DataFrames
- `df1.union(df2)` → union by position (same schema/order)
- `df1.unionByName(df2)` → union by column name

## 10. Useful Functions
- Strings: `upper('Item_Type')`
- Date functions:
  - `current_date()`
  - `date_add(current_date(), 7)`
  - `date_sub(current_date(), 7)`
  - `datediff(date1, date2)`
  - `date_format(date, 'dd-MM-yyyy')`

## 11. Null Handling
- Drop rows where all columns are null: `df.dropna('all')`
- Drop rows where any column is null: `df.dropna('any')`
- Drop rows based on subset: `df.dropna(subset=['Outlet_Size'])`
- Fill missing values: `df.fillna('NotAvailable')`

## 12. Split / Explode
- Split string column: `split(col('Outlet_Type'), ' ')`
- Explode array column: `explode(col('Outlet_Type'))`
- Check array contents: `array_contains(col('Outlet_Type'), 'Type1')`

## 13. Aggregation
- Group and aggregate: `df.groupBy('Item_Type').agg(sum('Item_MRP'))`
- Average: `avg('Item_MRP')`
- Collect list: `collect_list('book')`
- Pivot: `df.groupBy('Outlet_Size').pivot('Item_Type').agg(avg('Item_MRP'))`

## 14. Conditional Logic
- `when(condition, 'X').otherwise('Y')`
- Multi-branch conditions:
  - `.when(..., 'Veg_Inexpensive').when(..., 'Veg_Expensive').otherwise('Non_Veg')`

## 15. Joins
- Inner join: `df1.join(df2, df1['dept_id'] == df2['dept_id'], 'inner')`
- Other join types: `left`, `right`, `anti`

## 16. Window Functions
- `row_number().over(Window.orderBy('Item_Identifier'))`
- Ranking: `rank()`, `dense_rank()`
- Window range: `.rowsBetween(Window.unboundedPreceding, Window.currentRow)`

## 17. UDF
- Define and use: `my_udf = udf(my_func)`
- Add result column: `df.withColumn('mynewcol', my_udf(col('Item_MRP')))`

## 18. Write / SQL
- Write CSV: `df.write.format('csv').save(path)`
- Write parquet: `df.write.format('parquet').mode('overwrite').saveAsTable('my_table')`
- SQL view: `df.createTempView('my_view')`
- SQL query: `spark.sql("select * from my_view where Item_Fat_Content = 'Lf'")`

---

## Flashcard Format
- Card 1: `read.json` vs `read.csv`
- Card 2: `printSchema()` / `show()` / `display()`
- Card 3: `schema(DDL)` / `StructType`
- Card 4: `select`, `alias`, `withColumnRenamed`
- Card 5: `filter(condition)`, `isin`, `isNull`
- Card 6: `withColumn`, `cast`, `regexp_replace`
- Card 7: `sort(desc/asc)`, `limit()`
- Card 8: `drop`, `dropDuplicates`, `distinct`
- Card 9: `union`, `unionByName`
- Card 10: `groupBy`, `agg`, `pivot`
- Card 11: `when/otherwise`
- Card 12: `join(inner, left, right, anti)`
- Card 13: `current_date`, `date_add`, `datediff`
- Card 14: `split`, `explode`, `array_contains`
- Card 15: `write(csv/parquet)`, `createTempView`, `spark.sql`

## Tip
Study by writing the one-line command for each transformation and comparing it to the notebook examples.