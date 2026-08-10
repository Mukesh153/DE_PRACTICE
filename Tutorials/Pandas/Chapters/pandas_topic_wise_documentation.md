# Pandas Topic-wise Documentation

> **Generated from all Jupyter notebooks under `py/pandas/` folder**
> Each section corresponds to a topic directory with code snippets, explanations, and concepts covered.

---

## Table of Contents

1. [1 - Pandas Introduction](#1---pandas-introduction)
2. [2 - DataFrame Basics](#2---dataframe-basics)
3. [3 - Different Ways of Creating DataFrame](#3---different-ways-of-creating-dataframe)
4. [4 - Read/Write CSV and Excel](#4---readwrite-csv-and-excel)
5. [5 - Handling Missing Data - fillna, interpolate, dropna](#5---handling-missing-data---fillna-interpolate-dropna)
6. [6 - Handling Missing Data - replace](#6---handling-missing-data---replace)
7. [7 - Group By](#7---group-by)
8. [8 - Concatenate](#8---concatenate)
9. [9 - Merge](#9---merge)
10. [10 - Pivot](#10---pivot)
11. [11 - Melt](#11---melt)
12. [12 - Stack/Unstack](#12---stackunstack)
13. [13 - Crosstab](#13---crosstab)
14. [14 - Time Series: DateTimeIndex](#14---time-series-datetimeindex)
15. [15 - Time Series: date_range](#15---time-series-date_range)
16. [16 - Time Series: Handling Holidays](#16---time-series-handling-holidays)
17. [17 - Time Series: to_datetime](#17---time-series-to_datetime)
18. [18 - Time Series: Period and PeriodIndex](#18---time-series-period-and-periodindex)
19. [19 - Time Series: Handling Time Zones](#19---time-series-handling-time-zones)
20. [20 - Shift and Lag](#20---shift-and-lag)
21. [21 - SQL and MySQL Database](#21---sql-and-mysql-database)

---

## 1 - Pandas Introduction

**Folder:** `1_intro/`
**Notebook:** `Pandas_introduction.ipynb`

What is Pandas? Pandas is a powerful data manipulation library for Python. This section introduces basic reading of CSV data and simple operations.

### Concepts Covered:
- Reading CSV files into a DataFrame
- Finding maximum values in a column
- Filtering rows based on conditions
- Filling missing values with 0
- Calculating mean of a column

### Code Snippets:

```python
import pandas as pd

# Read CSV data
df = pd.read_csv('nyc_weather.csv')

# Basic operations
df['Temperature'].max()          # Find max temperature
df['EST'][df['Events']=='Rain']   # Filter EST column where event is Rain
df.fillna(0, inplace=True)        # Fill NaN values with 0
df['WindSpeedMPH'].mean()         # Calculate mean wind speed
```

---

## 2 - DataFrame Basics

**Folder:** `2_dataframe_basics/`
**Notebook:** `dataframe_basics.ipynb`

DataFrame is the most commonly used object in pandas. It is a table-like data structure containing rows and columns, similar to an Excel spreadsheet.

### Concepts Covered:
- Creating DataFrame from dictionary
- Reading from CSV
- Shape, head, tail operations
- Column selection and operations
- Conditional selection (SQL-like queries)
- Statistical operations: max, mean, std, describe
- set_index and loc for label-based access
- reset_index

### Code Snippets:

```python
import pandas as pd

# Creating a DataFrame from dictionary
weather_data = {
    'day': ['1/1/2017','1/2/2017','1/3/2017','1/4/2017','1/5/2017','1/6/2017'],
    'temperature': [32,35,28,24,32,31],
    'windspeed': [6,7,2,7,4,2],
    'event': ['Rain', 'Sunny', 'Snow','Snow','Rain', 'Sunny']
}
df = pd.DataFrame(weather_data)

# Reading from CSV
df = pd.read_csv("weather_data.csv")

# Basic inspection
df.shape               # (rows, columns)
df.head()              # First 5 rows
df.tail()              # Last 5 rows
df[1:3]                # Slicing rows

# Column operations
df.columns             # List all columns
df['day']              # Select single column (or df.day)
df[['day','temperature']]  # Select multiple columns

# Operations on DataFrame
df['temperature'].max()
df[df['temperature']>32]    # Conditional filtering
df['day'][df['temperature'] == df['temperature'].max()]  # SQL-like query
df['temperature'].std()
df['event'].max()           # Max on string column (alphabetical)
df.describe()               # Statistical summary

# set_index and loc
df.set_index('day', inplace=True)  # Set index to 'day' column
df.loc['1/2/2017']                 # Label-based access
df.reset_index(inplace=True)       # Reset back to default index
```

> **Reference:** [Pandas Series Documentation](http://pandas.pydata.org/pandas-docs/stable/generated/pandas.Series.html)

---

## 3 - Different Ways of Creating DataFrame

**Folder:** `3_different_ways_of_creating_dataframe/`
**Notebook:** `pandas_different_ways_of_creating_dataframe.ipynb`

### Concepts Covered:
1. **Using CSV** - `pd.read_csv()`
2. **Using Excel** - `pd.read_excel()`
3. **Using Dictionary** - `pd.DataFrame(dict)`
4. **Using Tuples List** - `pd.DataFrame(data=tuples, columns=...)`
5. **Using List of Dictionaries** - `pd.DataFrame(data=dict_list, columns=...)`

### Code Snippets:

```python
# Using csv
df = pd.read_csv("weather_data.csv")

# Using excel
df = pd.read_excel("weather_data.xlsx", "Sheet1")

# Using dictionary
weather_data = {
    'day': ['1/1/2017','1/2/2017','1/3/2017'],
    'temperature': [32,35,28],
    'windspeed': [6,7,2],
    'event': ['Rain', 'Sunny', 'Snow']
}
df = pd.DataFrame(weather_data)

# Using tuples list
weather_data = [
    ('1/1/2017',32,6,'Rain'),
    ('1/2/2017',35,7,'Sunny'),
    ('1/3/2017',28,2,'Snow')
]
df = pd.DataFrame(data=weather_data, columns=['day','temperature','windspeed','event'])

# Using list of dictionaries
weather_data = [
    {'day': '1/1/2017', 'temperature': 32, 'windspeed': 6, 'event': 'Rain'},
    {'day': '1/2/2017', 'temperature': 35, 'windspeed': 7, 'event': 'Sunny'},
    {'day': '1/3/2017', 'temperature': 28, 'windspeed': 2, 'event': 'Snow'},
]
df = pd.DataFrame(data=weather_data, columns=['day','temperature','windspeed','event'])
```

---

## 4 - Read/Write CSV and Excel

**Folder:** `4_read_write_to_excel/`
**Notebook:** `read_write_csv_excel.ipynb`

### Concepts Covered:
- **Read CSV:** header, skiprows, nrows, na_values, converters, custom NA handling per column
- **Write CSV:** index, columns selection, header options
- **Read Excel:** sheet name, converters
- **Write Excel:** sheet name, startrow, startcol
- **Multiple sheets to single Excel file** using `pd.ExcelWriter`

### Code Snippets:

#### Reading CSV
```python
import pandas as pd

# Basic read
df = pd.read_csv("stock_data.csv")

# Skip header and provide custom column names
df = pd.read_csv("stock_data.csv", header=None, names=["ticker","eps","revenue","person"])

# Read only first n rows
df = pd.read_csv("stock_data.csv", nrows=5)

# Replace specific strings with NaN
df = pd.read_csv("stock_data.csv", na_values=["n.a.", "not available"])

# Column-specific NA values
df = pd.read_csv("stock_data.csv", na_values={
    'eps': ['not available', -1.00],
    'revenue': [-1],
    'person': ['not available','n.a.']
})
```

#### Writing CSV
```python
df.to_csv("new.csv", index=False)
df.to_csv("new.csv", header=False)
df.to_csv("new.csv", columns=["tickers","price"], index=False)
```

#### Reading Excel with Converters
```python
def convert_people_cell(cell):
    if cell == "n.a.":
        return 'Sam Walton'
    return cell

def convert_price_cell(cell):
    if cell == "n.a.":
        return 50
    return cell

df = pd.read_excel("stock_data.xlsx", "Sheet1", converters={
    'people': convert_people_cell,
    'price': convert_price_cell
})
```

#### Writing Excel - Multiple Sheets
```python
df_stocks = pd.DataFrame({
    'tickers': ['GOOGL', 'WMT', 'MSFT'],
    'price': [845, 65, 64],
    'pe': [30.37, 14.26, 30.97],
    'eps': [27.82, 4.61, 2.12]
})
df_weather = pd.DataFrame({
    'day': ['1/1/2017','1/2/2017','1/3/2017'],
    'temperature': [32,35,28],
    'event': ['Rain', 'Sunny', 'Snow']
})

with pd.ExcelWriter('stocks_weather.xlsx') as writer:
    df_stocks.to_excel(writer, sheet_name="stocks", index=False)
    df_weather.to_excel(writer, sheet_name="weather", index=False)
```

---

## 5 - Handling Missing Data - fillna, interpolate, dropna

**Folder:** `5_handling_missing_data_fillna_dropna_interpolate/`
**Notebook:** `handling_missing_data_fillna_dropna_interpolate.ipynb`

### Concepts Covered:
- **fillna:** Fill NaN with a specific value, column-specific dict, forward fill (ffill), backward fill (bfill), axis parameter, limit parameter
- **interpolate:** Linear interpolation, time-based interpolation (other methods: quadratic, cubic, piecewise_polynomial)
- **dropna:** Drop rows with any NaN, how='all' to drop fully empty rows, thresh parameter
- **Insert missing dates** using reindex with DatetimeIndex

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("weather_data.csv", parse_dates=['day'])
df.set_index('day', inplace=True)

# ---- fillna ----
# Fill all NaN with one value
new_df = df.fillna(0)

# Fill using column-specific values (dict)
new_df = df.fillna({
    'temperature': 0,
    'windspeed': 0,
    'event': 'No Event'
})

# Forward fill
new_df = df.ffill()          # or df.fillna(method="ffill")

# Backward fill
new_df = df.bfill()          # or df.fillna(method="bfill")

# Backward fill across columns
new_df = df.bfill(axis="columns")

# Limit consecutive fills
new_df = df.ffill(limit=1)

# ---- interpolate ----
# Linear interpolation (numeric columns only)
new_df = df[["temperature","windspeed"]].interpolate()

# Time-based interpolation
new_df = df[["temperature","windspeed"]].interpolate(method="time")

# ---- dropna ----
# Drop rows with any NaN
new_df = df.dropna()

# Drop rows where ALL values are NaN
new_df = df.dropna(how='all')

# Drop rows with at least thresh non-NaN values
new_df = df.dropna(thresh=1)

# ---- Inserting Missing Dates ----
dt = pd.date_range("01-01-2017", "01-11-2017")
idx = pd.DatetimeIndex(dt)
df.reindex(idx)
```

> **Note:** Other interpolation methods available: quadratic, piecewise_polynomial, cubic, etc. See [pandas interpolate documentation](https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.interpolate.html).

---

## 6 - Handling Missing Data - replace

**Folder:** `6_handling_missing_data_replace/`
**Notebook:** `handling_missing_data_replace.ipynb`

### Concepts Covered:
- Replacing a single value with another value
- Replacing a list of values with a single value
- Column-specific replacements using dict
- Mapping values using dict (replace by mapping)
- Regex-based replacement
- Replacing a list with another list

### Code Snippets:

```python
import pandas as pd
import numpy as np

df = pd.read_csv("weather_data.csv")

# Replace single value
new_df = df.replace(-99999, value=np.nan)

# Replace list with single value
new_df = df.replace(to_replace=[-99999, -88888], value=0)

# Replace per column
new_df = df.replace({
    'temperature': -99999,
    'windspeed': -99999,
    'event': '0'
}, np.nan)

# Replace by mapping
new_df = df.replace({
    -99999: np.nan,
    'no event': 'Sunny',
})

# Regex replacement
new_df = df.replace({
    'temperature': '[A-Za-z]',
    'windspeed': '[a-z]'
}, '', regex=True)

# Replace list with another list
df = pd.DataFrame({
    'score': ['exceptional','average', 'good', 'poor', 'average', 'exceptional'],
    'student': ['rob', 'maya', 'parthiv', 'tom', 'julian', 'erica']
})
df.replace(['poor', 'average', 'good', 'exceptional'], [1, 2, 3, 4])
```

---

## 7 - Group By

**Folder:** `7_group_by/`
**Notebook:** `pandas_group_by.ipynb`

Split-Apply-Combine pattern. Group data by a column and apply aggregation functions.

### Concepts Covered:
- **DataFrameGroupBy object** - intermediate object
- **Iterating over groups** - for city, data in g
- **get_group()** - extract specific group
- **Aggregations:** max, mean, min, describe, size, count
- **Custom grouping function** using lambda

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("weather_by_cities.csv")

# Create groupby object
g = df.groupby("city")

# Iterate over groups
for city, data in g:
    print("city:", city)
    print("data:", data)

# Get specific group
g.get_group('mumbai')

# Aggregations
g.max()        # Maximum per group
g.mean()       # Average per group
g.min()        # Minimum per group
g.describe()   # Statistical summary per group
g.size()       # Row count per group
g.count()      # Non-null count per group

# Plot grouped data
%matplotlib inline
g.plot()

# Custom grouping function
def grouper(df, idx, col):
    if 80 <= df[col].loc[idx] <= 90:
        return '80-90'
    elif 50 <= df[col].loc[idx] <= 60:
        return '50-60'
    else:
        return 'others'

g = df.groupby(lambda x: grouper(df, x, 'temperature'))
for key, d in g:
    print("Group by Key: {}\n".format(key))
    print(d)
```

**Diagram: Split-Apply-Combine**
```
DataFrame → Split (by city) → Apply (max/min/mean) → Combine (results)
```

---

## 8 - Concatenate

**Folder:** `8_concat/`
**Notebook:** `pandas_concat.ipynb`

### Concepts Covered:
- **Basic Concatenation** - stacking DataFrames vertically (axis=0)
- **Ignore Index** - reset index after concatenation
- **Concatenation with Keys** - hierarchical index labeling source data
- **Column-wise Concatenation** - using axis=1
- **Concatenating DataFrame with Series**

### Code Snippets:

```python
import pandas as pd

# Sample DataFrames
india_weather = pd.DataFrame({
    "city": ["mumbai","delhi","banglore"],
    "temperature": [32,45,30],
    "humidity": [80, 60, 78]
})

us_weather = pd.DataFrame({
    "city": ["new york","chicago","orlando"],
    "temperature": [21,14,35],
    "humidity": [68, 65, 75]
})

# Basic concatenation (vertical)
df = pd.concat([india_weather, us_weather])

# Ignore index
df = pd.concat([india_weather, us_weather], ignore_index=True)

# With keys (hierarchical index)
df = pd.concat([india_weather, us_weather], keys=["india", "us"])
df.loc["us"]    # Access US rows
df.loc["india"] # Access India rows

# Column-wise concatenation (axis=1)
temperature_df = pd.DataFrame({
    "city": ["mumbai","delhi","banglore"],
    "temperature": [32,45,30],
}, index=[0,1,2])

windspeed_df = pd.DataFrame({
    "city": ["delhi","mumbai"],
    "windspeed": [7,12],
}, index=[1,0])

df = pd.concat([temperature_df, windspeed_df], axis=1)

# Concatenate DataFrame with Series
s = pd.Series(["Humid","Dry","Rain"], name="event")
df = pd.concat([temperature_df, s], axis=1)
```

---

## 9 - Merge

**Folder:** `9_merge/`
**Notebook:** `pandas_merge.ipynb`

### Concepts Covered:
- **Basic Merge** on a common column
- **Join Types:** inner, outer, left, right
- **indicator flag** to show merge source
- **suffixes** for overlapping column names
- **join** method for index-based merging

### Code Snippets:

```python
import pandas as pd

df1 = pd.DataFrame({
    "city": ["new york","chicago","orlando", "baltimore"],
    "temperature": [21,14,35,38],
})
df2 = pd.DataFrame({
    "city": ["chicago","new york","san diego"],
    "humidity": [65,68,71],
})

# Inner join (default)
df3 = pd.merge(df1, df2, on="city", how="inner")

# Outer join - all cities from both
df3 = pd.merge(df1, df2, on="city", how="outer")

# Left join - keep all rows from df1
df3 = pd.merge(df1, df2, on="city", how="left")

# Right join - keep all rows from df2
df3 = pd.merge(df1, df2, on="city", how="right")

# Indicator flag
df3 = pd.merge(df1, df2, on="city", how="outer", indicator=True)

# Suffixes for overlapping columns
df1 = pd.DataFrame({
    "city": ["new york","chicago","orlando", "baltimore"],
    "temperature": [21,14,35,38],
    "humidity": [65,68,71,75]
})
df2 = pd.DataFrame({
    "city": ["chicago","new york","san diego"],
    "temperature": [21,14,35],
    "humidity": [65,68,71]
})
df3 = pd.merge(df1, df2, on="city", how="outer", suffixes=('_first', '_second'))

# Join (index-based)
df1 = pd.DataFrame({
    "city": ["new york","chicago","orlando"],
    "temperature": [21,14,35],
})
df1.set_index('city', inplace=True)

df2 = pd.DataFrame({
    "city": ["chicago","new york","orlando"],
    "humidity": [65,68,75],
})
df2.set_index('city', inplace=True)

df1.join(df2, lsuffix='_l', rsuffix='_r')
```

**Diagram: SQL-style Joins**
```
INNER  → Only matching keys from both
LEFT   → All keys from left, only matching from right
RIGHT  → All keys from right, only matching from left
OUTER  → All keys from both
```

---

## 10 - Pivot

**Folder:** `10_pivot/`
**Notebook:** `pandas_pivot.ipynb`

### Concepts Covered:
- **pivot()** - reshape data (index, columns, values)
- **pivot_table()** - pivot with aggregation (handles duplicates)
- **margins** - add row/column totals
- **Grouper** - time-based grouping in pivot tables

### Code Snippets:

```python
import pandas as pd
import numpy as np

# Basic pivot
df = pd.read_csv("weather.csv")
df.pivot(index='city', columns='date')
df.pivot(index='city', columns='date', values="humidity")
df.pivot(index='date', columns='city')

# Pivot Table (handles duplicate entries with aggregation)
df = pd.read_csv("weather2.csv")
df.pivot_table(index="city", columns="date")

# Pivot Table with margins
df.pivot_table(index="city", columns="date", margins=True, aggfunc=np.sum)

# Grouper - time-based pivot
df = pd.read_csv("weather3.csv")
df['date'] = pd.to_datetime(df['date'])
df.pivot_table(index=pd.Grouper(freq='M', key='date'), columns='city')
```

---

## 11 - Melt

**Folder:** `11_melt/`
**Notebook:** `pandas_melt_tutorial.ipynb`

Melt is used to reshape a DataFrame from wide format to long format (unpivot).

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("weather.csv")
# day    chicago  ...  paris
# 1/1/2017  32    ...   45

# Melt: wide → long format
melted = pd.melt(df, id_vars=["day"], var_name='city', value_name='temperature')
# day       city    temperature
# 1/1/2017  chicago  32
# 1/1/2017  paris    45
# ...
```

---

## 12 - Stack/Unstack

**Folder:** `12_stack/`
**Notebook:** `12_pandas_stack.ipynb`

Reshape DataFrames with multi-level column headers.

### Concepts Covered:
- **stack()** - pivot columns into rows (makes DataFrame taller)
- **unstack()** - pivot rows into columns (makes DataFrame wider)
- **Level parameter** - specify which level to stack/unstack
- **3 levels of column headers**

### Code Snippets:

```python
import pandas as pd

# Two levels of column headers
df = pd.read_excel("stocks.xlsx", header=[0,1])
df.stack()               # Stack innermost column level
df.stack(level=0)        # Stack first column level

# Stack and unstack
df_stacked = df.stack()
df_stacked.unstack()     # Reverse the stacking

# Three levels of column headers
df2 = pd.read_excel("stocks_3_levels.xlsx", header=[0,1,2])
df2.stack()              # Stack innermost level
df2.stack(level=0)       # Stack first level
df2.stack(level=1)       # Stack second level
```

---

## 13 - Crosstab

**Folder:** `13_crosstab/`
**Notebook:** `pandas_crosstab.ipynb`

Cross-tabulation (frequency tables) for two or more factors.

### Concepts Covered:
- Basic crosstab (frequency counts)
- Margins (totals)
- MultiIndex columns and rows
- Normalization (row proportions)
- Aggregation with values and aggfunc

### Code Snippets:

```python
import pandas as pd
import numpy as np

df = pd.read_excel("survey.xls")

# Basic crosstab
pd.crosstab(df.Nationality, df.Handedness)
pd.crosstab(df.Sex, df.Handedness)

# With margins (totals)
pd.crosstab(df.Sex, df.Handedness, margins=True)

# MultiIndex columns
pd.crosstab(df.Sex, [df.Handedness, df.Nationality], margins=True)

# MultiIndex rows
pd.crosstab([df.Nationality, df.Sex], [df.Handedness], margins=True)

# Normalize (row proportions)
pd.crosstab(df.Sex, df.Handedness, normalize='index')

# With aggregation and values
pd.crosstab(df.Sex, df.Handedness, values=df.Age, aggfunc=np.average)
```

---

## 14 - Time Series: DateTimeIndex

**Folder:** `14_ts_datetimeindex/`
**Notebook:** `pandas_ts_datetime_index.ipynb`

### Concepts Covered:
- **Creating DateTimeIndex** from a date column
- **Benefits:** Partial date selection, date range slicing
- **Resampling** - aggregate data to a different frequency (e.g., monthly)
- **Plotting** time series data

### Code Snippets:

```python
from pathlib import Path
import pandas as pd

# Read and set up DatetimeIndex
df = pd.read_csv("aapl.csv")
df["Date"] = pd.to_datetime(df["Date"], format="%d-%b-%y")
df = df.set_index("Date").sort_index()

# Partial Date Indexing
df.loc['2017-06-30']           # Single date
df.loc['2017-01']              # Entire month January 2017
df.loc['2017-06'].head()       # June 2017
df.loc['2017'].head(2)         # Year 2017

# Average closing price for a specific month
df.loc['2017-06', 'Close'].mean()

# Date range selection
df.loc['2017-01-08':'2017-01-03']  # Slice between dates

# Resampling
df['Close'].resample('ME').mean().head()  # Monthly resample

# Plotting
%matplotlib inline
df['Close'].plot()
df['Close'].resample('ME').mean().plot(kind='bar')
```

---

## 15 - Time Series: date_range

**Folder:** `15_ts_date_range/`
**Notebook:** `pandas_ts_date_range.ipynb`

### Concepts Covered:
- **pd.date_range()** - generating date ranges with various frequencies
- **Frequency aliases:** 'B' (business day), 'D' (daily), 'W' (weekly), 'h' (hourly)
- **Finding missing dates** using difference()
- **asfreq()** - convert to a different frequency with fill method
- **periods argument** for generating fixed-length date ranges

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("aapl_no_dates.csv")

# Create business day date range
rng = pd.date_range(start="6/1/2016", end="6/30/2016", freq='B')
df.set_index(rng, inplace=True)

# Finding missing dates
daily_index = pd.date_range(start="6/1/2016", end="6/30/2016", freq='D')
missing = daily_index.difference(df.index)

# asfreq - convert to different frequency
df.asfreq('D', method='pad')   # Daily, forward fill
df.asfreq('W', method='pad')   # Weekly, forward fill
df.asfreq('h', method='pad')   # Hourly, forward fill

# Using periods argument
rng = pd.date_range('1/1/2011', periods=72, freq='h')
ts = pd.Series(np.random.randint(0, 10, len(rng)), index=rng)
ts.head(20)
```

---

## 16 - Time Series: Handling Holidays

**Folder:** `16_ts_holidays/`
**Notebook:** `pandas_ts_holidays_custombusinessday.ipynb`

### Concepts Covered:
- **USFederalHolidayCalendar** - built-in US holiday calendar
- **CustomBusinessDay** - custom business day frequency
- **AbstractHolidayCalendar** - defining custom holiday calendars
- **Weekmask** - defining custom work weeks (e.g., Egypt: Sun-Thu)
- **Mathematical operations** with business day offsets

### Code Snippets:

```python
import pandas as pd
from pandas.tseries.holiday import USFederalHolidayCalendar, AbstractHolidayCalendar, Holiday
from pandas.tseries.offsets import CustomBusinessDay

df = pd.read_csv("aapl_no_dates.csv")

# Using USFederalHolidayCalendar
us_cal = CustomBusinessDay(calendar=USFederalHolidayCalendar())
rng = pd.date_range(start="7/1/2017", end="7/23/2017", freq=us_cal)
df.set_index(rng, inplace=True)

# Custom holiday calendar
class myCalendar(AbstractHolidayCalendar):
    rules = [
        Holiday('My Birth Day', month=4, day=15),
    ]

my_bday = CustomBusinessDay(calendar=myCalendar())
pd.date_range('4/1/2017', '4/30/2017', freq=my_bday)

# Custom weekmask (Egypt weekend: Fri-Sat)
egypt_weekdays = "Sun Mon Tue Wed Thu"
b = CustomBusinessDay(weekmask=egypt_weekdays)
pd.date_range(start="7/1/2017", periods=20, freq=b)

# Custom business day with holidays + weekmask
b = CustomBusinessDay(holidays=['2017-07-04', '2017-07-10'], weekmask=egypt_weekdays)
pd.date_range(start="7/1/2017", periods=20, freq=b)

# Mathematical operations
from datetime import datetime
dt = datetime(2017, 7, 9)
dt + 1 * b   # Add one custom business day
```

---

## 17 - Time Series: to_datetime

**Folder:** `17_ts_to_date_time/`
**Notebook:** `pandas_ts_to_date_time.ipynb`

### Concepts Covered:
- **Parsing various date formats** - automatic mixed format parsing
- **Day-first parsing** for European style dates
- **Custom date format** with strftime patterns
- **Handling invalid dates** using errors='coerce'
- **Epoch/Unix timestamps** - converting seconds/milliseconds since 1970-01-01

### Code Snippets:

```python
import pandas as pd

# Various date formats (automatic parsing)
dates = ['2017-01-05', 'Jan 5, 2017', '01/05/2017', '2017.01.05', '2017/01/05', '20170105']
pd.to_datetime(dates, format='mixed')

# Dates with times
dt = ['2017-01-05 2:30:00 PM', 'Jan 5, 2017 14:30:00', '01/05/2016']
pd.to_datetime(dt)

# European style (day first)
pd.to_datetime('5-1-2016', dayfirst=True)

# Custom format
pd.to_datetime('2017$01$05', format='%Y$%m$%d')
pd.to_datetime('2017#01#05', format='%Y#%m#%d')

# Handling invalid dates (coerce to NaT)
pd.to_datetime(['2017-01-05', 'Jan 6, 2017', 'abc'], errors='coerce')

# Epoch / Unix time
current_epoch = 1501324478
pd.to_datetime(current_epoch, unit='s')        # seconds
pd.to_datetime(current_epoch * 1000, unit='ms')  # milliseconds
t = pd.to_datetime([current_epoch], unit='s')
t.view('int64')  # View underlying integer representation
```

---

## 18 - Time Series: Period and PeriodIndex

**Folder:** `18_ts_period/`
**Notebook:** `pandas_ts_period.ipynb`

### Concepts Covered:
- **Period objects:** yearly, monthly, daily, hourly, quarterly, weekly
- **Period properties:** start_time, end_time, is_leap_year
- **Period arithmetic** - adding/subtracting periods
- **asfreq()** - converting between period frequencies (start/end of period)
- **period_range()** - generating PeriodIndex
- **PeriodIndex** - for fiscal year analysis
- **Walmart financials** - real-world example with fiscal quarters ending in January

### Code Snippets:

```python
import pandas as pd
import numpy as np

# Yearly period
y = pd.Period('2016')
y.start_time      # 2016-01-01
y.end_time        # 2016-12-31
y.is_leap_year

# Monthly period
m = pd.Period('2017-12')
m.start_time
m.end_time
m + 1             # Add one month

# Daily period
d = pd.Period('2016-02-28', freq='D')
d + 1

# Hourly period
h = pd.Period('2017-08-15 23:00:00', freq='h')
h + 1
h + pd.offsets.Hour(1)

# Quarterly period
q1 = pd.Period('2017Q1', freq='Q-JAN')  # Fiscal year ends Jan
q1.asfreq('M', how='start')            # First month of quarter
q1.asfreq('M', how='end')              # Last month of quarter

# Weekly periods
w = pd.Period('2017-07-05', freq='W')
w - 1              # Subtract one week
w2 - w             # Difference in weeks

# Period range
r = pd.period_range('2011', '2017', freq='Q')
r[0].start_time    # 2011-01-01
r[0].end_time      # 2011-03-31

# Fiscal quarters (Jan year-end)
r = pd.period_range('2011', '2017', freq='Q-JAN')

# PeriodIndex with custom frequency
r = pd.period_range(start='2016-01', periods=10, freq='3M')

# Series with PeriodIndex
idx = pd.period_range('2011', '2018', freq='Q')
ps = pd.Series(np.random.randn(len(idx)), idx)
ps['2016']                    # Partial indexing by year
ps['2016':'2017']             # Range indexing

# Convert between Period and Timestamp
pst = ps.to_timestamp()       # Period → Timestamp
ps = pst.to_period()          # Timestamp → Period

# Walmart financials example
df = pd.read_csv("wmt.csv")
df.set_index("Line Item", inplace=True)
df = df.T
df.index = pd.PeriodIndex(df.index, freq="Q-JAN")

# Add start/end date columns
df["Start Date"] = df.index.map(lambda x: x.start_time)
df["End Date"] = df.index.map(lambda x: x.end_time)
```

---

## 19 - Time Series: Handling Time Zones

**Folder:** `19_ts_timezone/`
**Notebook:** `pandas_timezone_handling.ipynb`

### Concepts Covered:
- **Naive vs. Timezone-aware** datetimes
- **tz_localize()** - assign timezone to naive datetime index
- **tz_convert()** - convert between timezones
- **pytz timezones** - list of all available timezones
- **dateutil timezones** - OS timezone support
- **Timezones in date_range()** - using tz parameter
- **Arithmetic between different timezones** - pandas aligns to UTC

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("msft.csv", header=1, index_col='Date Time', parse_dates=True)

# tz_localize - make naive datetime timezone-aware
df.index = df.index.tz_localize(tz='US/Eastern')

# tz_convert - convert to another timezone
df = df.tz_convert('Europe/Berlin')

# Convert to Mumbai time (Asia/Calcutta)
df.index = df.index.tz_convert('Asia/Calcutta')

# Timezone in date_range with pytz
london = pd.date_range('3/6/2012 00:09:00', periods=10, freq='h', tz='Europe/London')

# Timezone in date_range with dateutil
td = pd.date_range('3/6/2012 00:00', periods=10, freq='h', tz='dateutil/Europe/London')

# Arithmetic between different timezones
rng = pd.date_range(start="2017-08-22 09:00:00", periods=10, freq='30min')
s = pd.Series(range(10), index=rng)
b = s.tz_localize(tz="Europe/Berlin")
m = s.tz_localize(tz="Asia/Calcutta")
b + m   # pandas converts both to UTC before arithmetic
```

> **Note:** pytz vs dateutil - pytz provides a programmatic list of timezones, while dateutil uses the OS timezone database. For common zones, the names are the same.

---

## 20 - Shift and Lag

**Folder:** `20_shift_lag/`
**Notebook:** `pandas_shift_lag.ipynb`

### Concepts Covered:
- **shift()** - shift values forward (positive) or backward (negative)
- **Previous day price** calculation using shift
- **Price change** calculation (difference from previous row)
- **Multi-day returns** using shift with larger periods
- **tshift()** - shift the DatetimeIndex (deprecated in newer pandas, use shift with freq instead)

### Code Snippets:

```python
import pandas as pd

df = pd.read_csv("fb.csv", parse_dates=['Date'], index_col='Date')

# Shift values
df.shift(1)       # Shift forward by 1 period (previous values move down)
df.shift(-1)      # Shift backward by 1 period (next values move up)

# Previous day price
df['Prev Day Price'] = df['Price'].shift(1)

# Price change calculation
df['Price Change'] = df['Price'] - df['Prev Day Price']

# 5-day return percentage
df['5 day return'] = (df['Price'] - df['Price'].shift(5)) * 100 / df['Price'].shift(5)

# tshift - shift the time index
df.index = pd.date_range(start='2017-08-15', periods=10, freq='B')
df.tshift(1)  # Shift all timestamps forward by 1 business day
```

---

## 21 - SQL and MySQL Database

**Folder:** `21_sql/`
**Notebook:** `pandas_sql.ipynb`

### Concepts Covered:
- **SQLAlchemy engine** creation with connection string
- **read_sql_table()** - read entire table or selected columns
- **read_sql_query()** - execute SQL queries, including JOINs
- **read_sql()** - wrapper around both functions
- **to_sql()** - write DataFrame to MySQL table with append/replace
- **chunksize** parameter for large DataFrames

### Code Snippets:

```python
import pandas as pd
import sqlalchemy

# Create database engine
engine = sqlalchemy.create_engine('mysql+pymysql://root:@localhost:3306/application')
# Format: mysql+pymysql://username:password@host:port/database_name

# Read entire table
df = pd.read_sql_table('customers', engine)

# Read specific columns
df = pd.read_sql_table('customers', engine, columns=["name"])

# Read with SQL query
df = pd.read_sql_query("select id, name from customers", engine)

# Read with JOIN query
query = '''
 SELECT customers.name, customers.phone_number, orders.name, orders.amount
 FROM customers INNER JOIN orders
 ON customers.id = orders.customer_id
'''
df = pd.read_sql_query(query, engine)

# read_sql - wrapper
pd.read_sql(query, engine)
pd.read_sql("customers", engine)

# Write DataFrame to SQL
df = pd.read_csv("customers.csv")
df.rename(columns={
    'Customer Name': 'name',
    'Customer Phone': 'phone_number'
}, inplace=True)
df.to_sql(
    name='customers',
    con=engine,
    if_exists='append',
    index=False
)
```

> **Note:** `to_sql()` has a `chunksize` parameter that allows writing data in chunks, which is useful when the DataFrame is very large.

---

## Appendix: Folder Structure Overview

```
pandas/
├── contents.txt
├── 1_intro/                          → Pandas Introduction
├── 2_dataframe_basics/               → DataFrame Basics
├── 3_different_ways_of_creating_dataframe/  → Creating DataFrames
├── 4_read_write_to_excel/            → CSV/Excel IO
├── 5_handling_missing_data_fillna_dropna_interpolate/  → fillna, dropna, interpolate
├── 6_handling_missing_data_replace/  → replace method
├── 7_group_by/                       → Group By
├── 8_concat/                         → Concatenation
├── 9_merge/                          → Merge/Join
├── 10_pivot/                         → Pivot Tables
├── 11_melt/                          → Melt (unpivot)
├── 12_stack/                         → Stack/Unstack
├── 13_crosstab/                      → Cross-tabulation
├── 14_ts_datetimeindex/              → DateTimeIndex
├── 15_ts_date_range/                 → date_range
├── 16_ts_holidays/                   → Holidays & CustomBusinessDay
├── 17_ts_to_date_time/               → to_datetime
├── 18_ts_period/                     → Period & PeriodIndex
├── 19_ts_timezone/                   → Time Zone Handling
├── 20_shift_lag/                     → Shift & Lag
└── 21_sql/                           → SQL/MySQL Integration
```

---

> **Document generated from Jupyter notebooks in `py/pandas/` directory.**
> Each topic folder contains the notebook (.ipynb) along with associated data files (.csv, .xlsx, images).
