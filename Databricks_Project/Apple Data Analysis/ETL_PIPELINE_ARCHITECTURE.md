# Apple Data Analysis ETL Pipeline - Technical Documentation

## Table of Contents
1. [Overview](#overview)
2. [Architecture Diagram](#architecture-diagram)
3. [Design Patterns](#design-patterns)
4. [Notebook Structure](#notebook-structure)
5. [Data Flow](#data-flow)
6. [Component Details](#component-details)
7. [Workflow Orchestration](#workflow-orchestration)
8. [Best Practices](#best-practices)

---

## Overview

This ETL (Extract, Transform, Load) pipeline analyzes Apple product purchase patterns by identifying:
- **Workflow 1**: Customers who bought AirPods immediately after buying an iPhone
- **Workflow 2**: Customers who bought ONLY iPhone and AirPods (no other products)

The pipeline is built using **PySpark** on **Databricks** and follows clean software engineering principles with multiple design patterns.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                   Apple__Data_Analysis (Orchestrator)               │
│  ┌──────────────────┐        ┌──────────────────┐                 │
│  │ FirstWorkFlow    │        │ SecondWorkFlow   │                 │
│  └──────────────────┘        └──────────────────┘                 │
│           │                           │                             │
│           └───────────────────────┬───────┘                             │
│                           │                                         │
│              ┌────────────▼────────────┐                           │
│              │  WorkFlowRunner         │                           │
│              │  (Strategy Selector)    │                           │
│              └─────────────────────────┘                           │
└─────────────────────────────────────────────────────────────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
         ▼                 ▼                 ▼
┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│   extractor    │ │  transformer   │ │     loader     │
│   (Extract)    │ │  (Transform)   │ │    (Load)      │
└────────────────┘ └────────────────┘ └────────────────┘
         │                 │                 │
         ▼                 ▼                 ▼
┌────────────────┐ ┌────────────────┐ ┌────────────────┐
│reader_factory  │ │ PySpark Logic  │ │loader_factory  │
│(Factory)       │ │ (Window Funcs) │ │(Factory)       │
└────────────────┘ └────────────────┘ └────────────────┘
         │                                   │
         ▼                                   ▼
┌────────────────┐                  ┌────────────────┐
│ Data Sources:  │                  │ Data Sinks:    │
│ • CSV Files    │                  │ • DBFS         │
│ • Delta Tables │                  │ • Delta Tables │
└────────────────┘                  └────────────────┘
```

---

## Design Patterns

### 1. **Factory Pattern** ✨
**Purpose**: Create objects without specifying exact classes

**Implementation**:

#### a) Reader Factory (`reader_factory` notebook)
- **Abstract Class**: `Datasource`
- **Concrete Classes**: `Json`, `CSV`, `Parquet`, `Delta`
- **Factory Function**: `get_data_frame(path)`
  
```python
# Auto-detects file type and returns appropriate reader
df = get_data_frame("/Volumes/workspace/default/megamart/data.csv")  # Returns CSV reader
df = get_data_frame("workspace.default.customer_delta_table")        # Returns Delta reader
```

**Why it's useful**: The calling code doesn't need to know file formats - the factory decides!

#### b) Loader Factory (`loader_factory` notebook)
- **Abstract Class**: `DataSink`
- **Concrete Classes**: `LoadToDBFS`, `LoadToDBFSWithPartition`, `LoadToDeltaTable`
- **Factory Function**: `get_sink_source(sink_type, df, path, method, params)`

```python
# Auto-selects the right loader based on sink_type
get_sink_source("delta", df, "my_table", "overwrite").load_data_frame()
```

---

### 2. **Strategy Pattern** 🎯
**Purpose**: Define family of algorithms, encapsulate each, and make them interchangeable

**Implementation**: 
- **Context**: `WorkFlowRunner`
- **Strategies**: `FirstWorkFlow`, `SecondWorkFlow`

```python
class WorkFlowRunner:
    def runner(self):
        if self.name == "firstWorkFlow":
            return FirstWorkFlow().runner()  # Strategy 1
        elif self.name == "secondWorkFlow":
            return SecondWorkFlow().runner()  # Strategy 2
```

**Why it's useful**: You can switch between workflows by just changing the `name` parameter!

---

### 3. **Template Method Pattern** 📋
**Purpose**: Define skeleton of algorithm, let subclasses override specific steps

**Implementation**:
- **Template**: ETL steps (Extract → Transform → Load)
- **Concrete Implementations**: `FirstWorkFlow`, `SecondWorkFlow`

Both workflows follow the same 3-step template:
```python
def runner(self):
    # Step 1: Extract
    inputDFs = Extractor().extract()
    
    # Step 2: Transform
    transformedDF = Transformer().transform(inputDFs)
    
    # Step 3: Load
    Loader(transformedDF).sink()
```

---

### 4. **Abstract Base Class Pattern** 🏛️
**Purpose**: Define common interface for related classes

**Implementations**:
- `Extractor` (abstract) → `AirpodsAfterIphoneExtractor`
- `Transformer` (abstract) → `AirpodsAfterIphoneTransformer`, `OnlyAirpodsAndIphone`
- `AbstractLoader` (abstract) → `AirPodsAfterIphoneLoader`, `OnlyAirpodsAndIPhoneLoader`

---

## Notebook Structure

### Notebook Interconnections

```
Apple__Data_Analysis.ipynb (Main Orchestrator)
├── %run "./extractor"          → Imports extractor notebook
│   └── %run "./reader_factory" → Imports reader_factory
│
├── %run "./transformer"        → Imports transformer notebook
│
└── %run "./loader"             → Imports loader notebook
    └── %run "./loader_factory" → Imports loader_factory
```

**Key Point**: `%run` command imports ALL classes and functions from referenced notebooks into the current namespace!

---

## Component Details

### 1. reader_factory.ipynb
**Purpose**: Unified data reading interface

**Classes**:
- `Datasource` (Abstract): Base class with `get_data_frame()` method
- `Json`: Reads JSON files
- `CSV`: Reads CSV files with headers
- `Parquet`: Reads Parquet files
- `Delta`: Reads Delta tables

---

### 2. loader_factory.ipynb
**Purpose**: Unified data writing interface

**Classes**:
- `DataSink` (Abstract): Base class with `load_data_frame()` method
- `LoadToDBFS`: Simple write to DBFS
- `LoadToDBFSWithPartition`: Write to DBFS with partitioning
- `LoadToDeltaTable`: Write to Delta table format

---

### 3. extractor.ipynb
**Purpose**: Extract data from various sources

**Classes**:
- `Extractor` (Abstract): Base class
- `AirpodsAfterIphoneExtractor`: Extracts transaction + customer data

---

### 4. transformer.ipynb
**Purpose**: Apply business logic transformations

**Classes**:
- `Transformer` (Abstract): Base class
- `AirpodsAfterIphoneTransformer`: Uses Window Functions with `lead()`
- `OnlyAirpodsAndIphone`: Uses group by with `collect_set()`

**PySpark Techniques**:
- Window functions: `Window.partitionBy().orderBy()`
- Lead function: `lead(col("product_name")).over(WindowSpec)`
- Array functions: `array_contains()`, `size()`
- Broadcast join: `F.broadcast(customerDF)`

---

### 5. loader.ipynb
**Purpose**: Load transformed data to destination

**Classes**:
- `AbstractLoader` (Abstract): Base class with abstract `sink()` method
- `AirPodsAfterIphoneLoader`: Implements dual-sink strategy
- `OnlyAirpodsAndIPhoneLoader`: Implements dual-sink strategy

**Why two sinks?**
- **DBFS**: Fast file-based storage, good for downstream file consumers
- **Delta Table**: ACID transactions, time travel, better for SQL queries

---

### 6. Apple__Data_Analysis.ipynb
**Purpose**: Main orchestrator notebook

---

## Workflow Orchestration

### How `.sink()` Executes Multiple Operations

**Question**: "How does calling `.sink()` once execute multiple `get_sink_source()` calls?"

**Answer**:

1. **Definition**: The `.sink()` method is defined in loader classes with MULTIPLE statements:
   ```python
   def sink(self):
       get_sink_source(...).load_data_frame()  # Call 1
       get_sink_source(...).load_data_frame()  # Call 2
   ```

2. **Execution**: When you call `.sink()` ONCE, Python executes ALL statements inside:
   ```python
   OnlyAirpodsAndIPhoneLoader(df).sink()  # One call triggers both sinks!
   ```

3. **Analogy**: It's like a recipe:
   - **Recipe book**: `%run "./loader"` (bring the cookbook)
   - **Recipe**: `.sink()` method (the complete instructions)
   - **Cooking**: One command "make the dish" executes all recipe steps

---

## Best Practices

### ✅ What This Pipeline Does Well

1. **Separation of Concerns** - Each notebook has ONE responsibility
2. **Code Reusability** - Factory patterns eliminate duplicate code
3. **Flexibility** - Easy to add new file formats or workflows
4. **Performance Optimization** - Uses broadcast joins and partitioning
5. **Multiple Sink Strategy** - Serves different downstream consumers

### 🔧 Design Patterns Summary

| Pattern | Purpose | Implementation |
|---------|---------|----------------|
| **Factory** | Object creation | `reader_factory`, `loader_factory` |
| **Strategy** | Algorithm selection | `WorkFlowRunner` |
| **Template Method** | Algorithm skeleton | ETL workflow structure |
| **Abstract Base Class** | Common interface | All base classes |

---

## Conclusion

This ETL pipeline demonstrates **enterprise-grade software engineering** principles:
- **Modular design** with clear separation of concerns
- **Design patterns** for maintainability and extensibility
- **PySpark optimization** with window functions and broadcast joins
- **Dual-sink strategy** for flexibility
- **Abstract interfaces** for consistency

---

**Created**: 2026-08-22  
**Author**: Apple Data Analysis Team  
**Pipeline**: Apple Product Purchase Pattern Analysis
