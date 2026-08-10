# PySpark Notebook Documentation

This document explains each cell in the notebook in order, including its purpose, what code it runs, and how the logic works.

## Overall Purpose of the Notebook

This notebook demonstrates how to:

- Read data from JSON and CSV files using PySpark
- Load data into Spark DataFrames
- Inspect and print schemas
- Define custom schemas using DDL and StructType
- Apply common DataFrame transformations such as select, alias, filter, and rename

> Note: This notebook appears to be designed for a Databricks-style environment because it uses functions such as display() and dbutils.fs. In standard local PySpark, you would typically use show() instead of display().

---

## Cell 1 — Markdown Heading

Title: "# DATA READING"

Purpose:
- Acts as a section heading for the first part of the notebook.

How it works:
- It does not execute any code.
- It helps organize the notebook into logical sections.

---

## Cell 2 — Markdown Heading

Title: "### Data Reading JSON"

Purpose:
- Introduces the subsection for reading JSON data.

How it works:
- This is only a label and does not run any code.
- It indicates that the next cells will focus on JSON file ingestion.

---

## Cell 3 — Read JSON Data into a DataFrame

Code:
```python
df_json = spark.read.format('json').option('inferSchema',True)\
                    .option('header',True)\
                    .option('multiLine',False)\
                    .load('C:\\Mukesh\\Self-Practice\\DE Upskill Practice\\Sessions\\Session 8 - Tasks\\Apache PySpark\\Datasets\\drivers.json')
```

Purpose:
- Reads a JSON file into a Spark DataFrame called df_json.

How it works:
- spark.read starts the data reading process.
- format('json') tells Spark that the input file is JSON.
- option('inferSchema', True) allows Spark to automatically detect column types such as string, integer, or boolean.
- option('header', True) tells Spark that the first row contains column names.
- option('multiLine', False) indicates that each JSON record is not spread across multiple lines.
- load(...) points to the JSON file path.

Result:
- A Spark DataFrame is created and stored in df_json.
- This DataFrame can then be displayed, transformed, or queried.

---

## Cell 4 — Display the JSON DataFrame

Code:
```python
df_json.display()
```

Purpose:
- Shows the contents of the JSON DataFrame in a tabular view.

How it works:
- display() is a Databricks-friendly method for rendering a DataFrame visually.
- It helps the user confirm that the JSON file was read correctly.

In local PySpark, this would usually be:
```python
df_json.show()
```

---

## Cell 5 — Markdown Heading

Title: "### Data Reading Utils"

Purpose:
- Marks the start of the section related to file system utilities and CSV data reading.

How it works:
- This is only a section title.
- No computation happens here.

---

## Cell 6 — List Files in the FileStore Folder

Code:
```python
dbutils.fs.ls('/FileStore/tables/')
```

Purpose:
- Lists the files available in the Databricks FileStore tables directory.

How it works:
- dbutils.fs is a Databricks utility for working with the file system.
- ls() lists the contents of the specified folder.
- This helps verify that the CSV file has been uploaded and is accessible.

Why it matters:
- The next cells will load a CSV file from this location.

---

## Cell 7 — Read CSV Data into a DataFrame

Code:
```python
df = spark.read.format('csv').option('inferSchema',True).option('header',True).load('/FileStore/tables/BigMart_Sales.csv')
```

Purpose:
- Reads a CSV file into a DataFrame named df.

How it works:
- spark.read starts the read operation.
- format('csv') tells Spark the source is a CSV file.
- inferSchema=True makes Spark infer the data types for each column automatically.
- header=True tells Spark that the first row contains column names.
- load('/FileStore/tables/BigMart_Sales.csv') specifies where the file is located.

Result:
- The data is loaded into a Spark DataFrame.
- The variable df now represents the CSV data.

---

## Cell 8 — Display the CSV DataFrame

Code:
```python
df.display()
```

Purpose:
- Shows the loaded CSV content in a visual table format.

How it works:
- This cell is used to confirm that the data was read correctly.
- It helps the user inspect a few rows before applying transformations.

---

## Cell 9 — Markdown Heading

Title: "### Schema Definition"

Purpose:
- Introduces the section where the DataFrame schema will be examined.

How it works:
- This is a section label and does not execute code.

---

## Cell 10 — Print the DataFrame Schema

Code:
```python
df.printSchema()
```

Purpose:
- Displays the structure of the DataFrame columns and their inferred data types.

How it works:
- printSchema() prints the schema in a tree-like format.
- This helps confirm whether Spark inferred the correct types for each column.

Why it matters:
- Schema understanding is important before transforming or querying data.

---

## Cell 11 — Markdown Heading

Title: "### DDL SCHEMA"

Purpose:
- Introduces the next section where a schema will be defined using DDL syntax.

How it works:
- This is only a heading.

---

## Cell 12 — Define a Schema Using DDL String

Code:
```python
my_ddl_schema = '''
                    Item_Identifier STRING,
                    Item_Weight STRING,
                    Item_Fat_Content STRING, 
                    Item_Visibility DOUBLE,
                    Item_Type STRING,
                    Item_MRP DOUBLE,
                    Outlet_Identifier STRING,
                    Outlet_Establishment_Year INT,
                    Outlet_Size STRING,
                    Outlet_Location_Type STRING, 
                    Outlet_Type STRING,
                    Item_Outlet_Sales DOUBLE 

                ''' 
```

Purpose:
- Creates a schema definition string in DDL format.

How it works:
- The string contains column names and their expected data types.
- STRING, DOUBLE, and INT define how each column should be treated.
- This schema is later applied while reading the CSV file.

Why it matters:
- Explicit schemas are useful when you want to control data types rather than rely on Spark inference.

---

## Cell 13 — Read the CSV File Using the DDL Schema

Code:
```python
df = spark.read.format('csv')\
            .schema(my_ddl_schema)\
            .option('header',True)\
            .load('/FileStore/tables/BigMart_Sales.csv') 
```

Purpose:
- Reads the CSV data again, but this time uses the custom DDL schema.

How it works:
- spark.read starts reading the file.
- format('csv') specifies the input format.
- schema(my_ddl_schema) applies the custom schema defined in the previous cell.
- header=True indicates the first row contains column names.
- load(...) points to the CSV file.

Result:
- The DataFrame df is rebuilt with the custom schema.

---

## Cell 14 — Display the DataFrame After Applying the DDL Schema

Code:
```python
df.display()
```

Purpose:
- Displays the DataFrame after the custom schema has been applied.

How it works:
- This helps verify that the schema-based read worked properly.
- It is useful for checking whether the data appears as expected.

---

## Cell 15 — Print the Schema Again

Code:
```python
df.printSchema()
```

Purpose:
- Shows the schema after applying the DDL-defined structure.

How it works:
- This confirms that Spark has used the custom schema instead of the inferred one.

---

## Cell 16 — Markdown Heading

Title: "### StructType() Schema"

Purpose:
- Introduces a second schema definition approach using PySpark's StructType API.

How it works:
- This is a section title and does not execute code.

---

## Cell 17 — Import PySpark Types and Functions

Code:
```python
from pyspark.sql.types import * 
from pyspark.sql.functions import *  
```

Purpose:
- Imports the classes and functions needed to create a StructType schema and work with DataFrame transformations.

How it works:
- StructType and StructField are used to explicitly define column structure.
- col(), alias(), filter(), and other functions are used for transformation operations later in the notebook.

---

## Cell 18 — Example Schema Defined as a Markdown Cell

Content shown:
```python
my_strct_schema = StructType([
                                StructField('Item_Identifier',StringType(),True),
                                StructField('Item_Weight',StringType(),True),
                                StructField('Item_Fat_Content',StringType(),True),
                                StructField('Item_Visibility',StringType(),True),
                                StructField('Item_MRP',StringType(),True),
                                StructField('Outlet_Identifier',StringType(),True),
                                StructField('Outlet_Establishment_Year',StringType(),True),
                                StructField('Outlet_Size',StringType(),True),
                                StructField('Outlet_Location_Type',StringType(),True),
                                StructField('Outlet_Type',StringType(),True),
                                StructField('Item_Outlet_Sales',StringType(),True)

])
```

Purpose:
- Shows how to build a schema using the StructType and StructField APIs.

How it works:
- StructType defines the full schema as a list of columns.
- Each StructField describes one column with a name, a data type, and a nullable flag.
- In this notebook, it is presented as an example and not executed because it is stored as a markdown cell.

---

## Cell 19 — Example of Applying a StructType Schema

Content shown:
```python
df = spark.read.format('csv')\
            .schema(my_strct_schema)\
            .option('header',True)\
            .load('/FileStore/tables/BigMart_Sales.csv')
```

Purpose:
- Demonstrates how to apply the StructType-based schema while reading the CSV file.

How it works:
- This is similar to the DDL example, but it uses the StructType object instead of a string schema.
- It tells Spark to use the custom column structure defined earlier.

---

## Cell 20 — Print the Schema After Applying StructType

Code:
```python
df.printSchema()
```

Purpose:
- Confirms the DataFrame uses the StructType schema.

How it works:
- printSchema() shows the new column names and their data types.

---

## Cell 21 — Markdown Heading

Title: "# TRANSFORMATIONS"

Purpose:
- Marks the start of the transformation section.

How it works:
- It is a section label only.

---

## Cell 22 — Markdown Heading

Title: "### SELECT"

Purpose:
- Introduces the select transformation.

How it works:
- This is a section title and does not execute code.

---

## Cell 23 — Display the DataFrame Before Selection

Code:
```python
df.display()
```

Purpose:
- Shows the full DataFrame before applying a column selection.

How it works:
- It gives the user a reference view of the original dataset.

---

## Cell 24 — Select Specific Columns

Code:
```python
df.select(col('Item_Identifier'),col('Item_Weight'),col('Item_Fat_Content')).display()
```

Purpose:
- Selects only a subset of columns from the DataFrame.

How it works:
- select() creates a new DataFrame with only the listed columns.
- col('ColumnName') references the specific columns.
- display() shows the result.

Why it matters:
- This is a common DataFrame transformation used to reduce the number of columns in a result.

---

## Cell 25 — Markdown Heading

Title: "### ALIAS"

Purpose:
- Introduces the alias transformation.

How it works:
- This is a section title only.

---

## Cell 26 — Rename a Column Using Alias

Code:
```python
df.select(col('Item_Identifier').alias('Item_ID')).display()
```

Purpose:
- Renames the Item_Identifier column to Item_ID for the output.

How it works:
- The select() method creates a new DataFrame.
- alias('Item_ID') changes the display name of the selected column.
- The original column name in the DataFrame remains unchanged unless the renamed DataFrame is saved to a variable.

---

## Cell 27 — Display the Original DataFrame Again

Code:
```python
df.display()
```

Purpose:
- Shows the original DataFrame again after the alias example.

How it works:
- This helps compare the unchanged original data with the transformed output from the previous cell.

---

## Cell 28 — Markdown Heading

Title: "### FILTER"

Purpose:
- Introduces filtering operations.

How it works:
- This is a section title.

---

## Cell 29 — Markdown Heading

Title: "#### Scenario - 1"

Purpose:
- Introduces the first filter example.

How it works:
- This is a subheading only.

---

## Cell 30 — Filter Rows Where Fat Content is "Regular"

Code:
```python
df.filter(col('Item_Fat_Content')=='Regular').display()
```

Purpose:
- Filters the DataFrame to include only rows where Item_Fat_Content equals Regular.

How it works:
- filter() keeps only rows that satisfy the condition.
- col('Item_Fat_Content') references the column.
- The comparison == Regular checks for exact match.

Result:
- A DataFrame containing only the rows with Regular fat content is displayed.

---

## Cell 31 — Markdown Heading

Title: "#### Scenario - 2"

Purpose:
- Introduces the second filter example.

How it works:
- This is a subheading only.

---

## Cell 32 — Filter Rows Based on Multiple Conditions

Code:
```python
df.filter((col('Item_Type') == 'Soft Drinks') & (col('Item_Weight')<10)).display()  
```

Purpose:
- Filters the DataFrame based on two conditions at once.

How it works:
- The first condition checks whether Item_Type is Soft Drinks.
- The second condition checks whether Item_Weight is less than 10.
- The & operator combines both conditions.
- Only rows matching both conditions are returned.

---

## Cell 33 — Markdown Heading

Title: "#### Scenario - 3"

Purpose:
- Introduces the third filter example.

How it works:
- This is a subheading only.

---

## Cell 34 — Filter Rows with Null Values and Multiple Matching Values

Code:
```python
df.filter((col('Outlet_Size').isNull()) & (col('Outlet_Location_Type').isin('Tier 1','Tier 2'))).display()
```

Purpose:
- Filters rows where Outlet_Size is null and Outlet_Location_Type is either Tier 1 or Tier 2.

How it works:
- isNull() checks for missing values in Outlet_Size.
- isin('Tier 1','Tier 2') checks whether Outlet_Location_Type belongs to the provided list.
- The & operator combines both conditions.

---

## Cell 35 — Markdown Heading

Title: "### withColumnRenamed"

Purpose:
- Introduces a DataFrame transformation that renames a column.

How it works:
- This is a section title only.

---

## Cell 36 — Rename a Column Using withColumnRenamed

Code:
```python
df.withColumnRenamed('Item_Weight','Item_Wt').display()
```

Purpose:
- Renames the Item_Weight column to Item_Wt in a new DataFrame.

How it works:
- withColumnRenamed() returns a new DataFrame with the renamed column.
- The original DataFrame remains unchanged unless you assign the result to a variable.
- display() shows the transformed output.

---

## Summary of the Notebook Flow

The notebook follows this learning flow:

1. Read JSON data into a DataFrame
2. Read CSV data into a DataFrame
3. Inspect the schema
4. Define custom schemas using DDL and StructType
5. Apply DataFrame transformations such as select, alias, filter, and rename

This is a practical introduction to working with structured data in PySpark.

---

## Additional Documentation for the Remaining Notebook Cells

The earlier part of the file covered the first 36 cells. The remaining cells continue with more advanced DataFrame operations and are documented below.

### Cells 37–46 — withColumn, Derived Columns, and Type Casting

#### Cell 37 — Markdown Heading
Title: "### withColumn"

Purpose:
- Introduces the withColumn transformation, which is used to add or replace columns in a DataFrame.

How it works:
- This is a section title and does not execute code.

#### Cell 38 — Markdown Heading
Title: "#### Scenario - 1"

Purpose:
- Introduces the first example of adding a new column.

#### Cell 39 — Add a Constant Column
Code:
```python
df = df.withColumn('flag',lit("new"))
```

Purpose:
- Adds a new column named flag to the DataFrame.

How it works:
- withColumn creates a new column or replaces an existing one.
- lit("new") creates a literal value that is repeated for each row.

#### Cell 40 — Display the Updated DataFrame
Code:
```python
df.display()
```

Purpose:
- Shows the DataFrame after the new column has been added.

#### Cell 41 — Create a Calculated Column
Code:
```python
df.withColumn('multiply',col('Item_Weight')*col('Item_MRP')).display()
```

Purpose:
- Creates a new column by performing arithmetic on existing columns.

How it works:
- col('Item_Weight') and col('Item_MRP') refer to two numeric columns.
- The result is a new derived column named multiply.

#### Cell 42 — Markdown Heading
Title: "#### Scenario - 2"

Purpose:
- Introduces a second example that modifies existing values in a column.

#### Cell 43 — Replace Text Values in a Column
Code:
```python
df = df.withColumn('Item_Fat_Content',regexp_replace(col('Item_Fat_Content'),"Regular","Reg"))\
    .withColumn('Item_Fat_Content',regexp_replace(col('Item_Fat_Content'),"Low Fat","Lf"))
```

Purpose:
- Replaces specific strings in the Item_Fat_Content column.

How it works:
- regexp_replace performs pattern-based replacement.
- This is useful for cleaning or standardizing values in a column.

#### Cell 44 — Markdown Heading
Title: "### Type Casting"

Purpose:
- Introduces the concept of changing a column's data type.

#### Cell 45 — Cast a Column to String
Code:
```python
df = df.withColumn('Item_Weight', col('Item_Weight').cast(StringType()))
```

Purpose:
- Converts the Item_Weight column to a string type.

How it works:
- cast() changes the data type of a column.
- This is useful when you want to treat numeric values as text.

#### Cell 46 — Print the Updated Schema
Code:
```python
df.printSchema()
```

Purpose:
- Confirms the new schema after the cast operation.

---

### Cells 47–56 — Sorting and Limiting Data

#### Cell 47 — Markdown Heading
Title: "### sort"

Purpose:
- Introduces sorting operations.

#### Cell 48 — Markdown Heading
Title: "#### Scenario - 1"

Purpose:
- Introduces the first sorting example.

#### Cell 49 — Sort in Descending Order
Code:
```python
df.sort(col('Item_Weight').desc()).display()
```

Purpose:
- Sorts rows by Item_Weight in descending order.

#### Cell 50 — Markdown Heading
Title: "#### Scenario - 2"

Purpose:
- Introduces another sorting example.

#### Cell 51 — Sort in Ascending Order
Code:
```python
df.sort(col('Item_Visibility').asc()).display()
```

Purpose:
- Sorts rows by Item_Visibility in ascending order.

#### Cell 52 — Markdown Heading
Title: "#### Scenario - 3"

Purpose:
- Introduces multi-column sorting.

#### Cell 53 — Sort by Multiple Columns
Code:
```python
df.sort(['Item_Weight','Item_Visibility'],ascending = [0,0]).display()
```

Purpose:
- Sorts by two columns at the same time.

How it works:
- The first column uses descending order and the second also uses descending order.

#### Cell 54 — Markdown Heading
Title: "#### Scenario - 4"

Purpose:
- Introduces a second multi-column sort example.

#### Cell 55 — Sort with Mixed Ordering
Code:
```python
df.sort(['Item_weight','Item_Visibility'], ascending = [0,1]).display()
```

Purpose:
- Demonstrates sorting with mixed directions.

Note:
- Item_weight appears to be a typo of Item_Weight, so this example may need the correct column name to run successfully.

#### Cell 56 — Markdown Heading
Title: "### Limit"

Purpose:
- Introduces the limit transformation.

#### Cell 57 — Show Only the First 10 Rows
Code:
```python
df.limit(10).display()
```

Purpose:
- Returns only the first 10 rows from the DataFrame.

---

### Cells 58–67 — Dropping Columns and Removing Duplicates

#### Cell 58 — Markdown Heading
Title: "### DROP"

Purpose:
- Introduces column removal operations.

#### Cell 59 — Markdown Heading
Title: "#### Scenario - 1"

Purpose:
- Introduces the first drop example.

#### Cell 60 — Drop One Column
Code:
```python
df.drop('Item_Visibility').display()
```

Purpose:
- Removes the Item_Visibility column from the display result.

#### Cell 61 — Markdown Heading
Title: "#### Scenario - 2"

Purpose:
- Introduces the second drop example.

#### Cell 62 — Drop Multiple Columns
Code:
```python
df.drop('Item_Visibility','Item_Type').display()
```

Purpose:
- Removes several columns from the DataFrame view.

#### Cell 63 — Markdown Heading
Title: "### Drop Duplicates"

Purpose:
- Introduces duplicate removal.

#### Cell 64 — Remove Duplicate Rows
Code:
```python
df.dropDuplicates().display()
```

Purpose:
- Removes repeated rows from the DataFrame.

#### Cell 65 — Markdown Heading
Title: "#### Scenario - 2"

Purpose:
- Introduces a duplicate removal example based on a subset of columns.

#### Cell 66 — Remove Duplicates Based on a Column
Code:
```python
df.drop_duplicates(subset=['Item_Type']).display()
```

Purpose:
- Removes duplicates while considering only the Item_Type column.

#### Cell 67 — Get Distinct Rows
Code:
```python
df.distinct().display()
```

Purpose:
- Returns only distinct rows from the DataFrame.

---

### Cells 68–78 — UNION and UNION BY NAME

#### Cell 68 — Markdown Heading
Title: "### UNION and UNION BY NAME"

Purpose:
- Introduces row-combining operations.

#### Cell 69 — Markdown Heading
Title: "#### Preparing DataFrames"

Purpose:
- Introduces the setup for creating sample DataFrames.

#### Cell 70 — Create Two Sample DataFrames
Code:
```python
data1 = [('1','kad'),('2','sid')]
schema1 = 'id STRING, name STRING'
df1 = spark.createDataFrame(data1,schema1)

data2 = [('3','rahul'),('4','jas')]
schema2 = 'id STRING, name STRING'
df2 = spark.createDataFrame(data2,schema2)
```

Purpose:
- Creates two small DataFrames for union demonstrations.

#### Cells 71–72 — Display the Sample DataFrames
Code:
```python
df1.display()
df2.display()
```

Purpose:
- Shows the contents of the two DataFrames before combining them.

#### Cell 73 — Markdown Heading
Title: "### Union"

Purpose:
- Introduces the union operation.

#### Cell 74 — Combine Rows with Union
Code:
```python
df1.union(df2).display()
```

Purpose:
- Stacks the rows from df1 and df2 into one DataFrame.

#### Cell 75 — Create a DataFrame with Different Column Order
Code:
```python
data1 = [('kad','1',),('sid','2',)]
schema1 = 'name STRING, id STRING'
df1 = spark.createDataFrame(data1,schema1)
df1.display()
```

Purpose:
- Shows how union can behave differently when schema order changes.

#### Cell 76 — Demonstrate Union with Different Column Order
Code:
```python
df1.union(df2).display()
```

Purpose:
- Highlights that union requires compatible column structures and may produce unexpected results when schemas differ.

#### Cell 77 — Markdown Heading
Title: "### Union by Name"

Purpose:
- Introduces unionByName, which aligns columns by name instead of position.

#### Cell 78 — Combine DataFrames by Column Name
Code:
```python
df1.unionByName(df2).display()
```

Purpose:
- Combines two DataFrames while matching columns by their names.

---

### Cells 79–81 — String Functions

#### Cell 79 — Markdown Heading
Title: "### String Functions"

Purpose:
- Introduces string processing functions.

#### Cell 80 — Markdown Heading
Title: "#### Initcap()"

Purpose:
- Introduces a string transformation example.

#### Cell 81 — Convert Text to Uppercase
Code:
```python
df.select(upper('Item_Type').alias('upper_Item_Type')).display()
```

Purpose:
- Converts values in Item_Type to uppercase.

How it works:
- upper() is a Spark SQL string function used for text normalization.

---

### Cells 82–100 — Date Functions and Date Handling

#### Cell 82 — Markdown Heading
Title: "### Date Functions"

Purpose:
- Introduces functions for working with dates.

#### Cell 83 — Markdown Heading
Title: "#### Current_Date"

Purpose:
- Introduces the current_date function.

#### Cell 84 — Add a Current Date Column
Code:
```python
df = df.withColumn('curr_date',current_date())
df.display()
```

Purpose:
- Adds a new column containing the current system date.

#### Cell 85 — Markdown Heading
Title: "#### Date_Add()"

Purpose:
- Introduces date addition.

#### Cell 86 — Add 7 Days to the Date Column
Code:
```python
df = df.withColumn('week_after',date_add('curr_date',7))
df.display()
```

Purpose:
- Creates a new column with a date seven days after the current date.

#### Cell 87 — Markdown Heading
Title: "#### Date_Sub()"

Purpose:
- Introduces date subtraction.

#### Cell 88 — Create a Column with a Date 7 Days Earlier
Code:
```python
df.withColumn('week_before',date_sub('curr_date',7)).display()
```

Purpose:
- Shows how to derive a date from the current date by subtracting days.

#### Cell 89 — Alternative Date Subtraction Example
Code:
```python
df = df.withColumn('week_before',date_add('curr_date',-7))
df.display()
```

Purpose:
- Demonstrates the same idea using date_add with a negative value.

#### Cell 90 — Markdown Heading
Title: "### Date Diff"

Purpose:
- Introduces the datediff function.

#### Cell 91 — Calculate the Difference Between Two Dates
Code:
```python
df = df.withColumn('datediff',datediff('week_after','curr_date'))
df.display()
```

Purpose:
- Computes the number of days between two date columns.

#### Cell 92 — Markdown Heading
Title: "### Date_Format()"

Purpose:
- Introduces date formatting.

#### Cell 93 — Format the Date Column
Code:
```python
df = df.withColumn('week_before',date_format('week_before','dd-MM-yyyy'))
df.display()
```

Purpose:
- Converts the date to a custom string format.

---

### Cells 94–113 — Handling Nulls, Splitting, and Exploding Data

#### Cell 94 — Markdown Heading
Title: "### Handling Nulls"

Purpose:
- Introduces techniques for dealing with missing values.

#### Cell 95 — Markdown Heading
Title: "#### Dropping Nulls"

Purpose:
- Introduces methods for removing rows with null values.

#### Cells 96–98 — Drop Rows with Nulls
Code:
```python
df.dropna('all').display()
df.dropna('any').display()
df.dropna(subset=['Outlet_Size']).display()
```

Purpose:
- Removes rows depending on whether all values are null, any value is null, or a specific column is null.

#### Cell 99 — Display the DataFrame Again
Code:
```python
df.display()
```

Purpose:
- Shows the DataFrame after the null-handling examples.

#### Cell 100 — Markdown Heading
Title: "#### Filling Nulls"

Purpose:
- Introduces filling missing values with a placeholder.

#### Cells 101–102 — Fill Missing Values
Code:
```python
df.fillna('NotAvailable').display()
df.fillna('NotAvailable',subset=['Outlet_Size']).display()
```

Purpose:
- Replaces missing values with the string NotAvailable.

#### Cell 103 — Markdown Heading
Title: "### SPLIT and Indexing"

Purpose:
- Introduces string splitting and indexing.

#### Cell 104 — Markdown Heading
Title: "#### SPLIT"

Purpose:
- Introduces the split function.

#### Cell 105 — Split the Outlet_Type Column
Code:
```python
df.withColumn('Outlet_Type',split('Outlet_Type',' ')).display()
```

Purpose:
- Splits the Outlet_Type values into arrays based on spaces.

#### Cell 106 — Markdown Heading
Title: "#### Indexing"

Purpose:
- Introduces accessing a specific element from a split array.

#### Cell 107 — Extract the Second Part of a Split Value
Code:
```python
df.withColumn('Outlet_Type',split('Outlet_Type',' ')[1]).display()
```

Purpose:
- Retrieves the second item from the split array.

#### Cell 108 — Markdown Heading
Title: "### Explode"

Purpose:
- Introduces the explode transformation for array values.

#### Cells 109–112 — Create and Explode an Array Column
Code:
```python
df_exp = df.withColumn('Outlet_Type',split('Outlet_Type',' '))
df_exp.display()
df_exp.withColumn('Outlet_Type',explode('Outlet_Type')).display()
df_exp.display()
df_exp.withColumn('Type1_flag',array_contains('Outlet_Type','Type1')).display()
```

Purpose:
- Shows how to split text into an array, explode it into multiple rows, and check whether an array contains a specific value.

---

### Cells 113–124 — GroupBy, Aggregations, Collect_List, and Pivot

#### Cell 113 — Markdown Heading
Title: "### GroupBY"

Purpose:
- Introduces grouping and aggregation.

#### Cells 114–120 — Aggregation Examples
Code:
```python
df.display()
df.groupBy('Item_Type').agg(sum('Item_MRP')).display()
df.groupBy('Item_Type').agg(avg('Item_MRP')).display()
df.groupBy('Item_Type','Outlet_Size').agg(sum('Item_MRP').alias('Total_MRP')).display()
df.groupBy('Item_Type','Outlet_Size').agg(sum('Item_MRP'),avg('Item_MRP')).display()
```

Purpose:
- Groups data by category and computes sums or averages.

#### Cell 121 — Markdown Heading
Title: "### Collect_List"

Purpose:
- Introduces collect_list for aggregating values into lists.

#### Cell 122 — Build a Book-User Example DataFrame
Code:
```python
data = [('user1','book1'),('user1','book2'),('user2','book2'),('user2','book4'),('user3','book1')]
schema = 'user string, book string'
df_book = spark.createDataFrame(data,schema)
df_book.display()
```

Purpose:
- Creates a small example DataFrame to demonstrate list aggregation.

#### Cell 123 — Aggregate Books per User
Code:
```python
df_book.groupBy('user').agg(collect_list('book')).display()
```

Purpose:
- Collects all book values for each user into a list.

#### Cell 124 — Select a Few Columns Before Pivoting
Code:
```python
df.select('Item_Type','Outlet_Size','Item_MRP').display()
```

Purpose:
- Prepares a smaller set of columns for the pivot example.

#### Cell 125 — Markdown Heading
Title: "### PIVOT"

Purpose:
- Introduces pivoting data for cross-tab type analysis.

#### Cell 126 — Create a Pivoted Summary
Code:
```python
df.groupBy('Item_Type').pivot('Outlet_Size').agg(avg('Item_MRP')).display()
```

Purpose:
- Reshapes the data so Outlet_Size becomes columns and average Item_MRP is shown inside them.

---

### Cells 127–135 — Conditional Logic with when/otherwise

#### Cell 127 — Markdown Heading
Title: "### When-Otherwise"

Purpose:
- Introduces conditional transformations.

#### Cell 128 — Markdown Heading
Title: "#### Scenario - 1"

Purpose:
- Introduces the first conditional example.

#### Cell 129 — Create a Category Column Based on Item_Type
Code:
```python
df = df.withColumn('veg_flag',when(col('Item_Type')=='Meat','Non-Veg').otherwise('Veg'))
```

Purpose:
- Converts Item_Type into a simpler binary category.

#### Cell 130 — Display the DataFrame
Code:
```python
df.display()
```

Purpose:
- Shows the DataFrame after creating the veg_flag column.

#### Cell 131 — Create a More Detailed Conditional Column
Code:
```python
df.withColumn('veg_exp_flag',when(((col('veg_flag')=='Veg') & (col('Item_MRP')<100)),'Veg_Inexpensive')\
                            .when((col('veg_flag')=='Veg') & (col('Item_MRP')>100),'Veg_Expensive')\
                            .otherwise('Non_Veg')).display()
```

Purpose:
- Applies multiple conditional branches to assign a label based on both category and price.

---

### Cells 136–147 — Joins, Window Functions, UDFs, Writing, and SQL

#### Cell 136 — Markdown Heading
Title: "### JOINS"

Purpose:
- Introduces the concept of combining DataFrames based on common keys.

#### Cells 137–140 — Create Sample DataFrames for Joins
Code:
```python
dataj1 = [('1','gaur','d01'),('2','kit','d02'),('3','sam','d03'),('4','tim','d03'),('5','aman','d05'),('6','nad','d06')]
schemaj1 = 'emp_id STRING, emp_name STRING, dept_id STRING'
df1 = spark.createDataFrame(dataj1,schemaj1)

dataj2 = [('d01','HR'),('d02','Marketing'),('d03','Accounts'),('d04','IT'),('d05','Finance')]
schemaj2 = 'dept_id STRING, department STRING'
df2 = spark.createDataFrame(dataj2,schemaj2)
```

Purpose:
- Creates two example DataFrames that can be joined on dept_id.

#### Cells 141–142 — Display the Join Inputs
Code:
```python
df1.display()
df2.display()
```

Purpose:
- Shows the left and right tables used for the join examples.

#### Cells 143–147 — Join Types
Code:
```python
df1.join(df2, df1['dept_id']==df2['dept_id'],'inner').display()
df1.join(df2,df1['dept_id']==df2['dept_id'],'left').display()
df1.join(df2,df1['dept_id']==df2['dept_id'],'right').display()
df1.join(df2,df1['dept_id']==df2['dept_id'],'anti').display()
```

Purpose:
- Demonstrates inner, left, right, and anti joins.

#### Cell 148 — Markdown Heading
Title: "### WINDOW FUNCTIONS"

Purpose:
- Introduces functions that operate over a sliding or ordered window of rows.

#### Cells 149–156 — Window Function Examples
Code:
```python
from pyspark.sql.window import Window

df.withColumn('rowCol',row_number().over(Window.orderBy('Item_Identifier'))).display()
df.withColumn('rank',rank().over(Window.orderBy(col('Item_Identifier').desc())))\
        .withColumn('denseRank',dense_rank().over(Window.orderBy(col('Item_Identifier').desc()))).display()
df.withColumn('dum',sum('Item_MRP').over(Window.orderBy('Item_Identifier').rowsBetween(Window.unboundedPreceding,Window.currentRow))).display()
df.withColumn('cumsum',sum('Item_MRP').over(Window.orderBy('Item_Type'))).display()
df.withColumn('cumsum',sum('Item_MRP').over(Window.orderBy('Item_Type').rowsBetween(Window.unboundedPreceding,Window.currentRow))).display()
df.withColumn('totalsum',sum('Item_MRP').over(Window.orderBy('Item_Type').rowsBetween(Window.unboundedPreceding,Window.unboundedFollowing))).display()
```

Purpose:
- Shows how to assign row numbers, ranks, and cumulative sums within ordered windows.

#### Cell 157 — Markdown Heading
Title: "### USER DEFINED FUNCTIONS (UDF)"

Purpose:
- Introduces custom functions that can be applied to DataFrame columns.

#### Cells 158–160 — Define and Apply a UDF
Code:
```python
def my_func(x):
    return x*x

my_udf = udf(my_func)
df.withColumn('mynewcol',my_udf('Item_MRP')).display()
```

Purpose:
- Defines a Python function and registers it as a UDF so it can be applied to a Spark DataFrame column.

#### Cell 161 — Markdown Heading
Title: "### DATA WRITING"

Purpose:
- Introduces writing DataFrames to external storage.

#### Cells 162–169 — Write DataFrames to CSV and Parquet
Code:
```python
df.write.format('csv').save('/FileStore/tables/CSV/data.csv')
df.write.format('csv').mode('append').save('/FileStore/tables/CSV/data.csv')
df.write.format('csv').mode('append').option('path','/FileStore/tables/CSV/data.csv').save()
df.write.format('csv').mode('overwrite').option('path','/FileStore/tables/CSV/data.csv').save()
df.write.format('csv').mode('error').option('path','/FileStore/tables/CSV/data.csv').save()
df.write.format('csv').mode('ignore').option('path','/FileStore/tables/CSV/data.csv').save()
df.write.format('parquet').mode('overwrite').option('path','/FileStore/tables/CSV/data.csv').save()
df.write.format('parquet').mode('overwrite').saveAsTable('my_table')
```

Purpose:
- Saves the DataFrame in CSV or Parquet format using different write modes such as append, overwrite, error, and ignore.

#### Cell 170 — Markdown Heading
Title: "### SPARK SQL"

Purpose:
- Introduces Spark SQL support for querying DataFrames as SQL tables.

#### Cells 171–175 — Create a Temp View and Query It with SQL
Code:
```python
df.createTempView('my_view')
%sql
select * from my_view where Item_Fat_Content = 'Lf'
df_sql = spark.sql("select * from my_view where Item_Fat_Content = 'Lf'")
df_sql.display()
```

Purpose:
- Registers the DataFrame as a temporary view and runs SQL queries against it.

#### Final Cell
Code:
```python

```

Purpose:
- This final empty cell is a placeholder and does not contain any code.
