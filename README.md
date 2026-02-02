# DBT SPICE

A production-ready dbt package to provide advanced data engineering utilities for BigQuery environments, focusing on data quality, metadata management, and analytical operations at scale.

Support to the mission & PRs are accepted.

### How to use it

- Declare in `your_dbt_repo/packages.yml`:
```yml
packages:
  - git: "https://github.com/albertovpd/dbt_spice.git"
    revision: main
```

- Run `dbt deps` from your terminal

You can now use all the macros without copying them to your project.

## Available Macros

### BigQuery AutoCleaner
[`macros/utils/bq_cleaner.sql`](macros/utils/bq_cleaner.sql)

Automatically removes redundant BigQuery objects (tables/views) that exist in your datasets but are not defined in your current dbt project.

**Arguments:**
- `dry_run` *(boolean, default: false)*: When `true`, only logs what would be done without executing the actual drops

**Usage:**
```bash
# Preview what will be cleaned
dbt run-operation bq_cleaner --args '{"dry_run": true}'

# Execute the cleanup
dbt run-operation bq_cleaner
```

---

### Distinct Value Tables Generator
[`macros/utils/distinct_value_generator.sql`](macros/utils/distinct_value_generator.sql)

Creates individual tables or views containing the distinct values for each column of a source table. Useful for data profiling and quality assessment.

**Arguments:**
- `source_table` *(string, required)*: Fully qualified table name in format `project.dataset.table`
- `destination_dataset` *(string, required)*: BigQuery dataset where the distinct value tables/views will be created
- `location` *(string, default: "EU")*: BigQuery location for the destination dataset
- `entity_type` *(string, default: "table")*: Type of entity to create - either `"table"` or `"view"`
  - Tables get suffix: `_distinct`
  - Views get suffix: `_distinct_v`
- `dry_run` *(boolean, default: false)*: When `true`, only logs what would be created without execution

**Usage:**
```bash
# Preview what will be created
dbt run-operation generate_distinct_value_tables --args '{"source_table": "project.dataset.table", "destination_dataset": "my_dataset", "entity_type": "view", "dry_run": true}'

# Create the distinct value views
dbt run-operation generate_distinct_value_tables --args '{"source_table": "project.dataset.table", "destination_dataset": "my_dataset", "entity_type": "view"}'
```

---

*More macros coming soon...*

### Jump in

If there is a specific functionality that you would like to cover with DBT, contact me. 
Also support and PRs are accepted

## Methodology

For crunching-data macros, I initially planned to use CSV seeds for testing (input data, expected outputs, and validation). However, including seeds in a dbt package creates dependency conflicts for users consuming the package via `dbt deps`. This approach needs to be reconsidered for future macro development.

Currently working with `Python 3.11.9`. DBT/SQL libraries at `requirements.txt`

## Contact

- [LinkedIn](https://www.linkedin.com/in/alberto-vargas-pina/)

