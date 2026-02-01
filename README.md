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

You can now use all macros from the `macros/` folder without adding them to your local repository.

### Current available methods:

- BigQuery autocleaner: 
```bash
dbt run-operation bq_cleaner --args '{"dry_run": true}'
```

- For all columns of a BigQuery table, create tables/views with the distinct values of those columns:
```bash
dbt run-operation generate_distinct_value_tables --args '{"source_table": "project.dataset.table", "destination_dataset": "my_dataset", "entity_type": "view","dry_run": true}'
```


## Methodology

For crunching-data macros, I initially planned to use CSV seeds for testing (input data, expected outputs, and validation). However, including seeds in a dbt package creates dependency conflicts for users consuming the package via `dbt deps`. This approach needs to be reconsidered for future macro development.

Currently working with `Python 3.11.9`. DBT/SQL libraries at `requirements.txt`

## Jump in

If there is a specific functionality that you would like to cover with DBT, contact me. 
Also support and PRs are accepted


## Contact

- [LinkedIn](https://www.linkedin.com/in/alberto-vargas-pina/)

