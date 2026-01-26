# DBT SPICE

## Table of contents

- [Introduction](#intro)
- [Development](#development)
    - [Methodology](#methodology)
    - [Features](#features)
        - [Utils](#utils)
            - [Bigquery autocleaner](#bq-autocleaner)
        - [Numerical processing](#numerical-processing)
        - [String processing](#string-processing)
    - [Work in progress and backlog](#work-in-progress)
- [Contact](#contact)

## Introduction  <a name="intro"></a>

The aim of this repository is both to provide tools for **Heavy crunching data** (deep statistical analyses, Machine Learning methods refactored to DBT Jinja SQL, etc) and **Big Data best practices** with DBT (cleaners to run be triggered to maintain your datasets unpolluted, metadata crawlers for BigQuery, etc).

Currently focused on GCP work with BigQuery. 
Support to the mission & PRs are also accepted.

### How to use it

- Declare in `your_dbt_repo/packages.yml`:
```
packages:
  - git: "https://github.com/albertovpd/dbt_spice.git"
    revision: main
```

- Run `dbt deps` from your terminal


## Development  <a name="development"></a>

<p align="center">
    <img src="catstruction.png" width="150">
</p>


### Methodology  <a name="methodology"></a>

Data processing macros will be developed using dummy CSVs as DBT seeds. Then they will be run against massive columns. Processing rows and computing times will be added to the documentation

Currently working with `Python 3.11.9`. DBT/SQL libraries at `requirements.txt`

- Macros for data processing will be tested using CSVs as seeds to create the input and expected output

### Features  <a name="features"></a>

#### Utils  <a name="utils"></a>

##### BigQuery autocleaner <a name="bq-autocleaner"></a>

Description:

Helps to keep the BigQuery environment clean and organized. Automatically removes redundant objects in BigQuery (tables that are not needed anymore, tables that were renamed and the old versions still exist, etc)

Path: 

`macros/utils/bq_cleaner.sql`

#### Numerical processing  <a name="numerical-processing"></a>

...

#### String processing  <a name="string-processing"></a>

...

------------
------------

### Work in progress and backlog  <a name="work-in-progress"></a>

<details>
<summary>⚒️ In progress</summary>

**String Occurrence Count**


</details>

<details>
<summary>📋 TODO</summary>

```
If there is a specific functionality that you would like to cover with DBT, contact me. 
Also support and PRs are accepted
```

**TDF-IDF**

**Max-min Scaler**

**Z-score Scaler**

</details>


------------
------------



### Contact  <a name="contact"></a>

- [LinkedIn](https://www.linkedin.com/in/alberto-vargas-pina/)

