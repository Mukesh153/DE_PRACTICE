# Apache Spark Master Interview Documentation & Cheat Sheet

This master guide consolidates core PySpark and Apache Spark concepts derived from architectural diagrams, code execution plans, and notes across 20 structured modules. Designed specifically for rapid interview preparation and quick technical reference.

---

## Table of Contents
1. [Module 1: What is Apache Spark?](#module-1-what-is-apache-spark)
2. [Module 2: Apache Spark vs. Hadoop MapReduce](#module-2-apache-spark-vs-hadoop-mapreduce)
3. [Module 3: Apache Spark Architecture & Components](#module-3-apache-spark-architecture--components)
4. [Module 4: Application Master Container & Py4J Architecture](#module-4-application-master-container--py4j-architecture)
5. [Module 5: Spark Session & Spark Context](#module-5-spark-session--spark-context)
6. [Module 6: Lazy Evaluation & Actions](#module-6-lazy-evaluation--actions)
7. [Module 7: Spark Query Plans & Spark UI](#module-7-spark-query-plans--spark-ui)
8. [Module 8: Spark RDDs & Logical Partitions](#module-8-spark-rdds--logical-partitions)
9. [Module 9: Narrow vs. Wide Transformations](#module-9-narrow-vs-wide-transformations)
10. [Module 10: Repartition vs. Coalesce](#module-10-repartition-vs-coalesce)
11. [Module 11: Jobs, Stages, and Tasks Execution Lineage](#module-11-jobs-stages-and-tasks-execution-lineage)
12. [Module 12: Shuffle Joins (Sort-Merge & Shuffle Hash)](#module-12-shuffle-joins-sort-merge--shuffle-hash)
13. [Module 13: Broadcast Hash Joins](#module-13-broadcast-hash-joins)
14. [Module 14: Spark SQL Engine & Catalyst Optimizer](#module-14-spark-sql-engine--catalyst-optimizer)
15. [Module 15: Driver Memory Management & Driver OOM](#module-15-driver-memory-management--driver-oom)
16. [Module 16: Executor Memory Management Breakdown](#module-16-executor-memory-management-breakdown)
17. [Module 17: Unified Memory Management & LRU Eviction](#module-17-unified-memory-management--lru-eviction)
18. [Module 18: Data Spilling & Executor OOM](#module-18-data-spilling--executor-oom)
19. [Module 19: Handling Data Skewness via Salting in PySpark](#module-19-handling-data-skewness-via-salting-in-pyspark)
20. [Module 20: Caching, Persist, and Storage Levels](#module-20-caching-persist-and-storage-levels)
21. [Module 21: Edge Node vs. Client Node & Deployment Modes](#module-21-edge-node-vs-client-node--deployment-modes)
22. [Module 22: Dynamic Partition Pruning (DPP)](#module-22-dynamic-partition-pruning-dpp)
23. [Module 23: Adaptive Query Execution (AQE)](#module-23-adaptive-query-execution-aqe)

---

## Module 1: What is Apache Spark?

### Definition & Fundamentals
Apache Spark is an open-source, distributed general-purpose cluster-computing framework designed for large-scale data processing and analytics [cite: 1]. It utilizes in-memory processing to significantly accelerate computation compared to disk-bound frameworks.

### Monolithic vs. Distributed Systems
When processing scale increases, system architectures diverge into two paradigms:

| Feature | Monolithic System (Scale-Up) | Distributed System / Spark (Scale-Out) |
| :--- | :--- | :--- |
| **Scaling Approach** | **Vertical Scaling**: Adding more RAM, CPU Cores, or SSD storage to a single server. | **Horizontal Scaling**: Connecting additional commodity machines (nodes) to the cluster. |
| **Hardware Limits** | Bounded by the physical upper limit and exponential cost of high-end single-machine hardware. | Near-infinite elasticity; scale linearly by adding nodes. |
| **Availability & Fault Tolerance** | Single Point of Failure (SPOF). Machine crash halts the entire system. | **High Availability**: Built-in fault tolerance. Tasks on failed nodes are automatically reassigned. |

### Use-Case Scenario / Purpose
* **Unified Analytics**: Running batch ETL pipelines, streaming computations, interactive SQL queries, graph processing, and machine learning on a single engine.

---

## Module 2: Apache Spark vs. Hadoop MapReduce

### Definition & Fundamentals
While Hadoop MapReduce relies heavily on persistent disk reads and writes at every intermediate map-reduce stage, Apache Spark maintains state and intermediate outputs in RAM (In-Memory Processing).

### Architectural Breakdown
* **In-Memory Computation**: Up to 100x faster execution than MapReduce for iterative algorithms (e.g., Machine Learning, Graph Processing) because intermediate steps do not spill to disk unless memory limits are reached.
* **Unified Framework**: Offers streaming, interactive querying, and batch processing out of the box, eliminating the need to stitch together separate tools.

```
HADOOP MAPREDUCE:  [Input Disk] -> [Map] -> [Disk Write] -> [Reduce] -> [Output Disk]
APACHE SPARK:      [Input Disk] -> [RAM: Map -> Filter -> Aggregation] -> [Output Disk]
```

---

## Module 3: Apache Spark Architecture & Components

### Definition & Fundamentals
Spark operates under a **Master-Slave (Driver-Worker)** architecture coordinated by a centralized **Resource/Cluster Manager**.

### Key Architectural Components

```
                +-------------------+
                | Resource Manager  |
                | (YARN/K8s/Stand.) |
                +---------+---------+
                          |
             +------------+------------+
             |                         |
    +--------v--------+       +--------v--------+
    |   Driver Node   |       |   Worker Node   |
    | (SparkContext/  |-------> (Executors &   |
    |  SparkSession)  |       |     Tasks)      |
    +-----------------+       +-----------------+
```

1. **Driver Node**: The central master process that runs the `main()` application code, creates the `SparkContext`/`SparkSession`, generates logical and physical execution plans (DAGs), and schedules tasks.
2. **Resource / Cluster Manager**: Allocates cluster resources across applications (e.g., YARN, Kubernetes, Mesos, or Spark's Standalone Manager).
3. **Worker Node**: Physical slave machines in the cluster that host Executor processes.
4. **Executors**: Distributed worker processes running on Worker Nodes responsible for executing assigned tasks and storing cached data partitions in RAM/disk.

### Quick Interview Note
* `SparkContext` or `SparkSession` initiates the connection between the Driver program and the Cluster/Resource Manager.

---

## Module 4: Application Master Container & Py4J Architecture

### Definition & Fundamentals
When PySpark applications run, Python code must interact with Spark’s underlying Scala/JVM core engine. This is accomplished via a gateway bridge called **Py4J**.

### Internals Breakdown

```
DRIVER NODE (Application Master Container)
[ PySpark Main (Python) ]  --- Py4J Process --->  [ JVM Main (Spark Core) ]

WORKER NODE
[ Executor JVM ]  <--- Inter-Process Pipe --->  [ Python Interpreter ] (For Python UDFs)
```

1. **Driver Level**: The PySpark Driver launches a Python process and uses `Py4J` to send Java calls to the local JVM Driver process.
2. **Worker Level**: Executors run inside a JVM. If native PySpark DataFrame transformations are used, JVM processes execution directly. 
3. **Worker UDF Scenario**: If a custom Python **User-Defined Function (UDF)** is invoked, the Executor JVM must spawn a separate **Python Interpreter** on the Worker Node, serialize data to Python, execute the UDF, and serialize results back to the JVM.

---

## Module 5: Spark Session & Spark Context

### Definition & Fundamentals
* **`SparkContext` (Spark 1.x)**: The original entry point for Spark applications, providing access to low-level RDDs, cluster configurations, and task scheduling.
* **`SparkSession` (Spark 2.x+)**: A unified higher-level entry point that encapsulates `SparkContext`, `SQLContext`, `HiveContext`, and `StreamingContext` under a single API interface.

### PySpark Representation
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("InterviewPrep") \
    .getOrCreate()
```

---

## Module 6: Lazy Evaluation & Actions

### Definition & Fundamentals
Spark uses **Lazy Evaluation**: transformations on DataFrames or RDDs are not executed immediately when called. Instead, Spark records a lineage of requested operations as a Directed Acyclic Graph (**DAG**).

### Execution Mechanism
* **Transformations** (`filter`, `select`, `groupBy`): Define *what* logic to apply. They return a new transformed DataFrame and build up the execution DAG without running actual compute jobs.
* **Actions** (`show()`, `count()`, `collect()`, `write()`, `display()`): Act as the "switch" that triggers job execution. Calling an action prompts the Catalyst Optimizer to construct physical execution plans, compile jobs, and execute tasks across cluster workers.

---

## Module 7: Spark Query Plans & Spark UI

### Definition & Fundamentals
The Spark UI and `explain()` method provide visibility into how PySpark translates DataFrame code into physical execution tasks across worker nodes.

### Query Plan Inspection
Using `df.explain()` or `df.explain(True)` outputs physical execution details:
```python
df_filtered = df.filter(col("city") == "New York")
df_filtered.explain()
```
* **Sample Output Node**: `*(1) Filter (isnotnull(city#23) AND (city#23 = New York))`
* The `*(1)` asterisk denotes **WholeStageCodegen**, an optimization feature that fuses multiple operators (like scan, filter, project) into a single Java bytecode function to eliminate virtual function calls.

### DAG (Directed Acyclic Graph)
Visually displayed in the Spark UI as connected stages showing reading, exchange (shuffling), code generation, and collection steps.

---

## Module 8: Spark RDDs & Logical Partitions

### Definition & Fundamentals
An **RDD (Resilient Distributed Dataset)** is Spark's fundamental abstraction: an immutable, fault-tolerant collection of logical partitions distributed across cluster nodes containing executors.

### Key Concepts
1. **Partition**: A single chunk/slice of the complete dataset.
2. **Resilience**: If a node hosting an RDD partition crashes, Spark can rebuild that specific partition from scratch using the DAG lineage history without recomputing the entire dataset.
3. **Relation to DataFrame**: DataFrames and Datasets are high-level abstractions built on top of RDDs with schema information and Catalyst query optimization.

---

## Module 9: Narrow vs. Wide Transformations

### Definition & Fundamentals
Transformations are classified based on whether data must move across cluster network boundaries.

```
NARROW TRANSFORMATION (No Shuffle)
[Input Partition 1] ---> [Transformation] ---> [Output Partition 1]
[Input Partition 2] ---> [Transformation] ---> [Output Partition 2]

WIDE TRANSFORMATION (Requires Network Shuffle)
[Input Partition 1] ---\ /--- [Shuffle Exchange] ---> [Output Partition A]
[Input Partition 2] ---/ \--- [Shuffle Exchange] ---> [Output Partition B]
```

| Aspect | Narrow Transformation | Wide Transformation |
| :--- | :--- | :--- |
| **Data Reliance** | Each output partition depends on **only one** input partition. | Each output partition depends on data from **multiple** input partitions. |
| **Network Cost** | **Zero Network Shuffle**. Computed locally on worker nodes. | **Forces Network Shuffle** (`ShuffleExchange`). Transfers data across nodes. |
| **Stage Boundary** | Executed inside the **same Stage**. | Breaks execution and creates a **New Stage Boundary**. |
| **Examples** | `filter()`, `select()`, `map()`, `withColumn()` | `groupBy()`, `join()`, `distinct()`, `repartition()`, `orderBy()` |

---

## Module 10: Repartition vs. Coalesce

### Definition & Fundamentals
Both methods adjust the total number of partitions in a DataFrame, but they use different data movement strategies.

### Comparison

```
REPARTITION (Full Network Shuffle)
[Partition 1] ---\ /---> [Part A] [Part B]
[Partition 2] ---/ \---> [Part C] [Part D]

COALESCE (Local Partition Merging - No Shuffle)
[Node 1: Part 1 + Part 2] === Merged Locally ===> [Merged Partition A]
```

| Property | `repartition(n)` | `coalesce(n)` |
| :--- | :--- | :--- |
| **Partition Count** | Can **increase** or **decrease** partition count. | Only **decreases** partition count. |
| **Shuffle Behavior** | Performs a **full network shuffle** across all nodes. | **No network shuffle** (merges local adjacent partitions on nodes). |
| **Data Balance** | Rebalances data into **equal-sized** partitions. | Can result in **uneven/skewed** partition sizes. |
| **Use-Case** | Rebalancing skewed datasets or increasing parallelism. | Reducing output file count before writing (e.g., `df.coalesce(1).write.parquet()`). |

---

## Module 11: Jobs, Stages, and Tasks Execution Lineage

### Definition & Fundamentals
Spark structures execution hierarchically into **Jobs**, **Stages**, and **Tasks**.

```
[ ACTION ] ---> Triggers 1 SPARK JOB
                   |
     +-------------+-------------+
     |                           |
[ STAGE 0 ]                 [ STAGE 1 ]
(Narrow Transformations)    (After Wide Shuffle)
     |                           |
[Task 1] [Task 2]           [Task 1] [Task 2] ... [Task 200]
(1 Task per Partition)
```

1. **Job**: Created every time an Action (or data read triggering schema inference) is called.
2. **Stage**: A Job is split into Stages divided by **Wide Transformation boundaries** (`ShuffleExchange`). Narrow transformations are pipelined into the same stage.
3. **Task**: The smallest unit of work. **1 Partition = 1 Task**. A stage launches as many parallel tasks as there are partitions in that stage's DataFrame.

### Default Shuffle Behavior Note
* By default, wide transformations set `spark.sql.shuffle.partitions` to **200**.
* If a post-shuffle dataset requires fewer partitions, unused tasks are skipped or run empty unless Adaptive Query Execution (AQE) dynamically coalesces them.

---

## Module 12: Shuffle Joins (Sort-Merge & Shuffle Hash)

### Definition & Fundamentals
When joining two large DataFrames where neither fits into driver/executor memory, Spark performs a **Shuffle Join**.

### 1. Sort-Merge Join (SMJ) - *Default Fallback Engine*
* **Step 1 (Shuffle)**: Rows from both datasets are shuffled across nodes based on `hash(join_key)` so identical join keys land on the same worker node.
* **Step 2 (Sort)**: Each worker node locally sorts both partitions by the join key.
* **Step 3 (Merge)**: The worker iterates sequentially down both sorted partitions, matching keys.
* **Why Spark Uses It**: Extremely safe for massive datasets. If data exceeds RAM, it can spill sorted chunks to disk without crashing with Out Of Memory (OOM) errors.

### 2. Shuffle Hash Join (SHJ)
* **Mechanism**: Shuffles both datasets, but instead of sorting, it constructs an in-memory **Hash Table** for the smaller side per partition and probes it with the larger side.
* **Trigger**: Triggered when one dataset is smaller than the other, but too large to broadcast, and post-shuffle partitions fit safely in memory.

---

## Module 13: Broadcast Hash Joins

### Definition & Fundamentals
A **Broadcast Hash Join (BHJ)** eliminates network shuffling for the large table by copying the small table to every executor node in the cluster.

```
[ Driver Node ] ---> Copies Small Table (< 10 MB) ---> [ Executor 1 ] (Big Table Part 1)
                                                 ---> [ Executor 2 ] (Big Table Part 2)
```

### Key Properties
* **Threshold**: Triggered automatically if a table size is below `spark.sql.autoBroadcastJoinThreshold` (default: **10 MB**).
* **Explicit Hint**: `df_large.join(broadcast(df_small), "id")`
* **Performance**: Fastest join strategy in Spark because the large table remains entirely static on its home nodes.
* **Risk**: Broadcasting a table that exceeds available Driver or Executor JVM memory will trigger an **Out of Memory (OOM)** crash.

---

## Module 14: Spark SQL Engine & Catalyst Optimizer

### Definition & Fundamentals
The **Catalyst Optimizer** is Spark SQL's core engine that translates DataFrame/SQL operations into optimized physical bytecode executable by worker nodes.

### Compilation Pipeline

```
[ User Code / SQL ] 
        |
        v
[ Unresolved Logical Plan ] ---> Catalog Lookup (Resolves table/column names & types)
        |
        v
[ Resolved Logical Plan ]   ---> Rule-based Optimization (Predicate Pushdown, Column Pruning)
        |
        v
[ Optimized Logical Plan ]  ---> Cost-Based Model (Generates multiple physical plans & picks lowest cost)
        |
        v
[ Physical Plan ]           ---> WholeStageCodegen (Generates optimized Java Bytecode) ---> [ Executor Tasks ]
```

---

## Module 15: Driver Memory Management & Driver OOM

### Definition & Fundamentals
The Driver process requires memory to orchestrate execution, maintain DAG lineages, schedule tasks, and collect query results.

### Memory Layout

```
+-------------------------------------------------------------------+
|                        TOTAL DRIVER MEMORY                        |
| +-----------------------------------+ +-------------------------+ |
| |        JVM HEAP MEMORY            | |    OVERHEAD MEMORY      | |
| |  (spark.driver.memory = e.g. 10GB)| | (spark.driver.          | |
| |                                   | |  memoryOverhead = 1GB)  | |
| | - DAGs & RDD Lineages             | | - Non-heap JVM threads| |
| | - Task Scheduling Info            | | - Shared C/C++ libs   | |
| | - Broadcast Variables             | | - Off-heap Netty      | |
| +-----------------------------------+ +-------------------------+ |
+-------------------------------------------------------------------+
```

* **Overhead Formula**: Default is `max(10% of spark.driver.memory, 384 MB)`.

### Root Causes of Driver OOM
1. **Unwise `.collect()` Usage**: Calling `.collect()` brings *all* distributed partitions into the single Driver JVM memory. If total DataFrame size > Driver Heap, Driver crashes with OOM.
2. **Excessive Broadcast Variable Size**: Broadcasting a dataset larger than available Driver JVM Heap space causes memory exhaustion during broadcast creation.

---

## Module 16: Executor Memory Management Breakdown

### Definition & Fundamentals
Each Executor JVM divides its allocated Heap Memory (`spark.executor.memory`) into distinct logical memory pools.

```
+---------------------------------------------------------------------------+
|                    TOTAL EXECUTOR JVM HEAP MEMORY                         |
| +-------------------+ +-------------------------------------------------+ |
| | Reserved Memory   | |               usableMemory                      | |
| |   (Fixed 300MB)   | |         (spark.executor.memory - 300MB)         | |
| |                   | | +-----------------------+ +-------------------+ | |
| | - Internal Spark  | | |   Spark Memory Pool   | |    User Memory    | | |
| |   Engine usage    | | | (default 60% = 0.60)  | | (default 40%)   | | |
| +-------------------+ | |                       | | - UDF objects,  | | |
|                       | | - Execution Memory    | |   custom data   | | |
|                       | | - Storage Memory      | |   structures    | | |
|                       | +-----------------------+ +-------------------+ | |
|                       +-------------------------------------------------+ |
+---------------------------------------------------------------------------+
```

### Breakdown Parameters
1. **Reserved Memory**: Fixed 300 MB allocated for Spark system internals.
2. **User Memory (40%)**: Used for custom user data structures, metadata, and Python UDF execution variables.
3. **Spark Memory Pool (60%)**: Shared dynamically between **Execution Memory** (joins, aggregations, shuffles) and **Storage Memory** (cached DataFrames and broadcast tables).

---

## Module 17: Unified Memory Management & LRU Eviction

### Definition & Fundamentals
Since Spark 1.6, **Unified Memory Management** dynamically adjusts the boundary between Execution Memory and Storage Memory (`spark.memory.storageFraction`, default 0.5) based on runtime needs.

### Dynamic Boundary & Eviction Rules

```
[ EXECUTION MEMORY (Transformations) ] <====== (Dynamic Green Line) ======> [ STORAGE MEMORY (Caching) ]
```

1. **Borrowing Space**: If Execution Memory is idle, Storage Memory can expand into Execution space to cache more data, and vice versa.
2. **Execution Priority**: Execution Memory has absolute priority. If Execution needs memory currently borrowed by Storage, Storage space is evicted using the **LRU (Least Recently Used)** cache algorithm.
3. **No Forced Execution Eviction**: Storage Memory *cannot* forcibly evict active Execution Memory. If Storage requires space occupied by Execution, Storage must evict its own LRU cached blocks.

---

## Module 18: Data Spilling & Executor OOM

### Definition & Fundamentals
* **Data Spilling**: When an executor thread runs out of memory while performing a wide transformation (e.g., `groupBy`, `join`), it writes (spills) temporary partition data from RAM to local disk.
* **Partition Granularity**: Spark spills data at the **entire partition level**. It cannot spill half a partition.

### Root Cause of Executor OOM
```
DATA SKEW ---> Partition size grows larger than available Executor RAM 
          ---> Spilling to disk occurs 
          ---> Skew exceeds disk spill limits / single record size exceeds RAM limits 
          ---> EXECUTOR OUT OF MEMORY (OOM) CRASH
```

---

## Module 19: Handling Data Skewness via Salting in PySpark

### Definition & Fundamentals
**Data Skew** occurs when data is unevenly distributed across partitions (e.g., 80% of rows contain `ProductCategory = 'Food'`). This creates a long-tail straggler task where one executor gets overwhelmed while others sit idle.

### The Salting Technique
Salting breaks down heavy skew keys by appending a random integer ("salt") to the join or grouping key.

```
ORIGINAL SKEWED DATA:
ProductCategory: 'Food' (1.5 GB) ===> Fits into 1 Partition (Triggers OOM / Slow Straggler)

SALTED DATA (Salt Factor = 4, Random Numbers [0, 1, 2, 3]):
['Food', 0] ---> Partition 1 (375 MB)
['Food', 1] ---> Partition 2 (375 MB)
['Food', 2] ---> Partition 3 (375 MB)
['Food', 3] ---> Partition 4 (375 MB)
```

### PySpark Implementation Code
```python
import pyspark.sql.functions as F

# Step 1: Add a random salt column (0 to 3) to the skewed dataframe
salt_factor = 4
df_salted = df.withColumn("salt", F.concat(F.col("ProductCategory"), F.lit("_"), F.floor(F.rand() * salt_factor)))

# Step 2: Perform aggregate grouping on the salted key
df_grouped_salted = df_salted.groupBy("salt").agg(F.count("order_id").alias("cnt"))

# Step 3: Remove salt and do final aggregation
df_final = df_grouped_salted.withColumn("ProductCategory", F.split(F.col("salt"), "_")[0]) \
                            .groupBy("ProductCategory").agg(F.sum("cnt").alias("total_count"))
```

---

## Module 20: Caching, Persist, and Storage Levels

### Definition & Fundamentals
Caching stores DataFrame partitions in Storage Memory across executor nodes so subsequent queries do not recompute the execution DAG lineage from scratch.

### `cache()` vs. `persist()`
* **`df.cache()`**: Shorthand wrapper for `df.persist(StorageLevel.MEMORY_AND_DISK)`.
* **`df.persist(level)`**: Allows explicit specification of custom storage levels.

### Storage Levels Summary Table

| Storage Level | Stores In RAM? | Stores On Disk? | Deserialized? | Replication | Description |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`MEMORY_ONLY`** | Yes | No | Yes | 1x | Default for RDDs. Recomputes lost partitions on the fly. |
| **`MEMORY_AND_DISK`** | Yes (First) | Yes (Fallback) | Yes | 1x | Default for DataFrames (`cache()`). Spills to disk if RAM is full. |
| **`DISK_ONLY`** | No | Yes | No | 1x | Slowest option; saves RAM by persisting directly to local disk. |
| **`MEMORY_ONLY_2`** | Yes | No | Yes | **2x** | Replicates cached partitions on 2 separate worker nodes for high fault tolerance. |
| **`OFF_HEAP`** | Off-Heap | No | No | 1x | Uses off-heap memory outside JVM (requires `spark.memory.offHeap.enabled=true`). |

### Spark UI & Physical Plan Verification
When a DataFrame is cached, physical query plan outputs show an **`InMemoryTableScan`** node instead of scanning raw source data files.


---

## Module 21: Edge Node vs. Client Node & Deployment Modes

### Definition & Fundamentals
* **Edge Node (Gateway Node)**: A physical or virtual server sitting on the perimeter of the cluster network that serves as a secure entry point for users, hosting client tools (like Jupyter, Databricks notebooks, or Airflow schedulers).
* **Client Node**: A logical role denoting whichever machine hosts and runs the **Spark Driver** process to construct DAGs, request resources, and schedule tasks.

### Deploy Modes Comparison (`--deploy-mode`)
* **`client` Mode**: The Spark Driver runs directly on the submitting machine (e.g., your local machine or an Edge Node).
  * *Use-case*: Interactive debugging, local development, or notebooks where immediate console feedback is required.
* **`cluster` Mode**: The Spark Driver process is shipped into a worker container inside the cluster (managed by YARN/Kubernetes).
  * *Use-case*: Production batch jobs, preventing driver network disconnects if an edge machine goes offline.

---

## Module 22: Dynamic Partition Pruning (DPP)

### Definition & Fundamentals
**Dynamic Partition Pruning (DPP)** is a Spark 3.0+ optimization designed specifically for Star-Schema joins (joining a large partitioned **Fact table** with a small filtered **Dimension table**).

### How It Works
1. Normally, Spark reads *all* partitions of a Fact table before filtering.
2. With DPP, Spark evaluates the filter condition on the small Dimension table first (e.g., `DateTable.year = 2026`).
3. Spark creates a dynamic filter predicate at runtime and applies it directly to the file-scanning phase of the Fact table.

### Purpose & Benefits
* **Drastic I/O Reduction**: Prevents reading non-matching partitions from disk into memory.
* **Performance Gain**: Speeds up data warehouse queries on large partitioned tables without requiring explicit hardcoded partition filters in code.

---

## Module 23: Adaptive Query Execution (AQE)

### Definition & Fundamentals
Introduced in Spark 3.0 (and enabled by default in Spark 3.2+), **Adaptive Query Execution (AQE)** re-optimizes physical query execution plans at runtime using real-time statistics collected between stage boundaries.

### 3 Core Optimizations
1. **Dynamic Coalescing of Shuffle Partitions**: Automatically merges tiny post-shuffle partitions to prevent managing thousands of small tasks (fixes default 200 partition overhead).
2. **Dynamic Join Conversion**: Converts a Sort-Merge Join to a Broadcast Hash Join on the fly if runtime statistics show one side shrank below the broadcast threshold.
3. **Dynamic Skew Join Handling**: Automatically detects skewed partitions at runtime and splits them into smaller sub-partitions to balance executor workloads.

### When to Disable (`spark.sql.adaptive.enabled = false`)
* Micro-batch real-time streaming queries where re-planning overhead outweighs performance gains.
* Strict production benchmarking where exact deterministic query execution plans are strictly required across runs.
