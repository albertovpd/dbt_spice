{% macro bq_cleaner(dry_run=False) %}

    /*
    For each database (gcp project) and schema (gcp dataset) present in the current dbt project
        it inspects information_schema.tables. 
    Then any table/view/etc not included in the current dbt project is considered redundant.
    It logs the drop statements and optionally executes them depending on the dry_run flag.
    
    ========================================================================================
    It will clean JUST the dataset/s related to the DBT project from where you're running it
    ========================================================================================

    How to:
        - preview what it's going to be done:
            dbt run-operation bq_cleaner --args '{"dry_run": true}'
        - execute it:
            dbt run-operation bq_cleaner
    */

    {% do log("""
        === BQ CLEANER ===
            """, info=True) %}

    -- gather all current model locations by database and schema
    {% if execute %}
        {% set model_locations = {} %}
        {% for node in graph.nodes.values() 
            | selectattr("resource_type", "in", ["model", "seed", "snapshot"]) %}

            {% set db = node.database %}
            {% set schema = node.schema %}
            {% set table = node.alias if node.alias else node.name %}

            {% if db not in model_locations %}
                {% do model_locations.update({db: {}}) %}
            {% endif %}

            {% if schema not in model_locations[db] %}
                {% do model_locations[db].update({schema: []}) %}
            {% endif %}

            {% do model_locations[db][schema].append(table) %}
        {% endfor %}
    {% endif %}

    -- stop if there are no models in the dbt project
    {% if model_locations | length == 0 %}
        {% do log("""
        - There are no DBT models in the project to compare with the entities at the database
        """, info=True) %}
    {% else %}

        -- construct sql to find tables not present in current run
        {% set cleanup_sql %}
            with models_to_drop as (
                {% for db in model_locations %}
                    {% for schema, tables in model_locations[db].items() %}
                        {% if not loop.first %}union all{% endif %}
                        select
                            table_type,
                            table_catalog,
                            table_schema,
                            table_name,
                            case 
                                when table_type = 'BASE TABLE' then 'TABLE'
                                when table_type = 'VIEW' then 'VIEW'
                            end as relation_type,
                            array_to_string([table_catalog, table_schema, table_name], '.') as relation_name
                        from {{ schema }}.INFORMATION_SCHEMA.TABLES
                        where not table_name in (
                            {% if tables | length > 0 %}
                                {{ tables | map('tojson') | join(', ') }}
                            {% else %}
                                '___empty___'
                            {% endif %}
                        )
                    {% endfor %}
                {% endfor %}
            ),
            drop_commands as (
                select 'drop ' || relation_type || ' `' || relation_name || '`;' as command
                from models_to_drop
            )
            select command from drop_commands
            where command is not null
        {% endset %}

        -- execute or print drop statements
        {% set commands = run_query(cleanup_sql).columns[0].values() %}
        {% if commands %}

            {% do log("\n", info=True) %}
            
            {% for cmd in commands %}
                {% do log(cmd, info=True) %}
                {% if not dry_run | as_bool %}
                    {% do run_query(cmd) %}
                {% endif %}
            {% endfor %}
        {% else %}

            {% do log("""
        - No redundant objects to remove
            """, info=True) %}
        
        {% endif %}
    {% endif %}

    {% do log("""
        === END MACRO ===
            """, info=True) %}

{% endmacro %}
