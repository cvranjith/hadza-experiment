# Hadza Experiment — Thin vs Fat Packaging (Spring Boot Classloading Benchmark)

## Overview

This is a simple experiment to demonstrate the impact of **fat-WAR** vs **thin-WAR** packaging when deploying multiple Spring Boot applications into a shared Tomcat JVM.

The experiment helps observe:
- Classloading behavior differences
- Startup time differences
- Reduction of redundant library loads when using a shared library setup

---

## Project Structure


Both `app1` and `app2` are:
- Simple Spring Boot REST applications exposing a test API.
- Using basic dependencies: `spring-boot-starter-web` and `jdbc`.

The **only difference** between `provided` and `included` is:
- In `provided/`: Dependencies like Spring are marked as `<scope>provided</scope>` (externalized).
- In `included/`: They are packaged into the WAR file (fat WAR).

---

## `benchmark.sh` 

The `benchmark.sh` automates:
1. Cleaning and deploying the apps into Tomcat.
2. (Re)Starting Tomcat.
3. Measuring:
   - JVM startup time.
   - Number of classloading events.
   - Number of distinct classes.
   - Source-level classload duplication (which jars are loading the most classes).
4. Saving logs into `benchmark_logs/`

Usage:
```bash
sh benchmark.sh included   # Tests fat WAR setup
sh benchmark.sh provided   # Tests thin WAR setup
```

Sample Output
```
--------------------------------------------
📊 Benchmark Summary for mode: included
Startup Time      : 8273 ms
Total Class Loads : 10844
Distinct Classes  : 1221
--------------------------------------------

--------------------------------------------
📊 Benchmark Summary for mode: provided
Startup Time      : 5200 ms
Total Class Loads : 7198
Distinct Classes  : 1221
--------------------------------------------
```

## Notes:

This experiment is designed to highlight classloader efficiency and startup improvement, not direct heap/metaspace savings, which may require larger setups to become evident.
