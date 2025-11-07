# SQL Server Waits Explained – Cheatsheet

SQL Server _waits_ indicate what the SQL engine is waiting on before it can continue working. Analyzing waits is one of the most effective ways to identify performance bottlenecks such as:

- Slow disk
- High CPU usage
- Blocking queries
- TempDB contention
- Memory pressure
- Availability Group delays

Below is a clear and practical cheatsheet of the most important wait types, grouped by category.

---

## CPU Waits (SQL Server waiting for CPU time)

| Wait Type             | Meaning                          | Typical Cause             | What to Check                              |
| --------------------- | -------------------------------- | ------------------------- | ------------------------------------------ |
| `SOS_SCHEDULER_YIELD` | Query yields CPU due to pressure | High CPU usage            | Expensive queries, missing indexes, MAXDOP |
| `CXPACKET`            | Parallel workers synchronizing   | Excessive parallelism     | MAXDOP, Cost Threshold for Parallelism     |
| `CXCONSUMER`          | Normal parallelism wait          | Expected behavior         | Ignore                                     |
| `THREADPOOL`          | No worker threads available      | Too many concurrent tasks | Reduce concurrency, optimize queries       |

---

## I/O Waits (slow disk subsystem)

| Wait Type               | Meaning                          | Typical Cause      | What to Check                               |
| ----------------------- | -------------------------------- | ------------------ | ------------------------------------------- |
| `PAGEIOLATCH_SH` / `EX` | Waiting for data pages from disk | Slow storage       | Disk latency, missing indexes               |
| `ASYNC_IO_COMPLETION`   | Async IO taking too long         | SAN/storage delays | Storage diagnostics                         |
| `IO_COMPLETION`         | IO operations slow to complete   | Disk bottleneck    | Storage subsystem                           |
| `WRITELOG`              | Waiting for log writes           | Slow log disk      | Move log to fast disk, shorten transactions |

---

## Lock Waits (blocking between queries)

| Wait Type     | Meaning                        | Typical Cause          | Recommended Action             |
| ------------- | ------------------------------ | ---------------------- | ------------------------------ |
| `LCK_M_S`     | Waiting for Shared lock        | Long-running SELECTs   | Shorten transactions           |
| `LCK_M_U`     | Waiting for Update lock        | High write concurrency | Index improvements             |
| `LCK_M_X`     | Exclusive lock blocking others | Contention on writes   | Identify blockers              |
| `LCK_M_SCH_S` | Schema stability wait          | Schema changes         | Schedule maintenance off-hours |
| `LCK_M_SCH_M` | Schema modification lock       | Rebuild/reindex        | Use ONLINE = ON                |

---

## Latch Waits (internal structure contention)

| Wait Type                    | Meaning                       | Cause                     | Fix                                    |
| ---------------------------- | ----------------------------- | ------------------------- | -------------------------------------- |
| `PAGELATCH_SH` / `EX` / `UP` | Contention on in-memory pages | Hotspot inserts or TempDB | Increase TempDB files, reduce hotspots |
| `BUFIO`                      | Buffer management delays      | Memory pressure           | Monitor memory grants                  |

---

## TempDB Contention Waits

| Wait Type         | Meaning                        | Typical Cause      | Fix                   |
| ----------------- | ------------------------------ | ------------------ | --------------------- |
| `PAGELATCH_UP`    | Metadata allocation contention | Heavy TempDB usage | Increase TempDB files |
| `PAGELATCH_EX`    | Writes to same page            | Spills, sorts      | Optimize queries      |
| `ALLOCATE_EXTENT` | Extent allocation contention   | Too few files      | 1 file/core (up to 8) |

---

## Transaction Log Waits

| Wait Type   | Meaning               | Indicator     | What to Check               |
| ----------- | --------------------- | ------------- | --------------------------- |
| `WRITELOG`  | Waiting for log flush | Slow log IO   | Move log to SSD/NVMe        |
| `LOGPOOL_*` | Log buffer delays     | IO bottleneck | Check disk speed, VLF count |

---

## Network Waits

| Wait Type          | Meaning                             | Cause                      | Fix                               |
| ------------------ | ----------------------------------- | -------------------------- | --------------------------------- |
| `ASYNC_NETWORK_IO` | SQL waiting for client to read data | Application reading slowly | Increase fetch size; optimize app |

---

## Parallelism Waits

| Wait Type    | Meaning                           | When It Happens           | Fix         |
| ------------ | --------------------------------- | ------------------------- | ----------- |
| `CXPACKET`   | Workers waiting in parallel plans | Heavy parallel operations | Tune MAXDOP |
| `CXCONSUMER` | Normal parallelism wait           | Expected                  | Ignore      |

---

## Memory Waits

| Wait Type               | Meaning                   | Cause          | Remedy                         |
| ----------------------- | ------------------------- | -------------- | ------------------------------ |
| `RESOURCE_SEMAPHORE`    | Waiting for memory grants | Not enough RAM | Add RAM, stats and index fixes |
| `MEMORY_ALLOCATION_EXT` | Memory allocation delays  | Grant pressure | Monitor memory usage           |

---

## AlwaysOn Availability Group Waits

| Wait Type           | Meaning                       | Indicator      | What to Check |
| ------------------- | ----------------------------- | -------------- | ------------- |
| `HADR_SYNC_COMMIT`  | Waiting for secondary replica | Slow secondary | Network, IO   |
| `HADR_CLUSAPI_CALL` | Slow WSFC response            | Cluster issues | Cluster logs  |

---

## How to List All Wait Types

```sql
SELECT DISTINCT wait_type
FROM sys.dm_os_wait_stats
ORDER BY wait_type;
```

---

## How to Review Wait Stats

```sql
SELECT *
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC;
```

---

## Reset Wait Stats (do not use in production unless needed)

```sql
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR);
```

---

## Diagnostic Summary

| Symptom         | Likely Wait Types                       | Meaning                |
| --------------- | --------------------------------------- | ---------------------- |
| High CPU        | `SOS_SCHEDULER_YIELD`, `CXPACKET`       | CPU bottleneck         |
| Slow Disk       | `PAGEIOLATCH_XX`, `ASYNC_IO_COMPLETION` | Disk IO issue          |
| Blocking        | `LCK_M_XX`                              | Lock contention        |
| TempDB Issues   | `PAGELATCH_XX`                          | TempDB contention      |
| Memory Pressure | `RESOURCE_SEMAPHORE`                    | Memory grants too high |
