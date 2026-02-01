{% macro generate_distinct_value_tables(
    source_table,
    destination_dataset,
    location="EU",
    entity_type="table",
    dry_run=false
) %}
    {#
        Creates a table or view per column with its distinct values from the source table.
        
        Args:
            source_table: Fully qualified table name (project.dataset.table)
            destination_dataset: Dataset where entities will be created
            location: BigQuery location for the dataset (default: EU)
            entity_type: Type of entity to create - 'table' or 'view' (default: table).
                The output name of entity will be: destination_dataset.column_name_ + suffix
                    For entity_type = table, suffix = distinct
                    For entity_type = view, suffix = distinct_v
            dry_run: If true, only logs what would be done without executing (default: false)
        
        Usage:
            dbt run-operation generate_distinct_value_tables --args '{"source_table": "project.dataset.table", "destination_dataset": "my_dataset", "entity_type": "view","dry_run": true}'
    #}
    {% set get_columns_query %}
        SELECT column_name
        FROM `{{ source_table.split('.')[0] }}`.`{{ source_table.split('.')[1] }}`.INFORMATION_SCHEMA.COLUMNS
        WHERE table_name = '{{ source_table.split('.')[2] }}'
    {% endset %}

    {% set columns_result = run_query(get_columns_query) %}

    {% if execute %}
        {# Create destination dataset if it doesn't exist #}
        {% set create_dataset_sql %}
            CREATE SCHEMA IF NOT EXISTS `{{ destination_dataset }}`
            OPTIONS(location = '{{ location }}')
        {% endset %}

        {% if dry_run %}
            {{
                log(
                    "[DRY RUN] Would create dataset if not exists: "
                    ~ destination_dataset,
                    info=True,
                )
            }}
        {% else %}
            {{ log("Ensuring dataset exists: " ~ destination_dataset, info=True) }}
            {% do run_query(create_dataset_sql) %}
        {% endif %}
        {% for row in columns_result %}
            {% set column_name = row["column_name"] %}
            {% set suffix = "_distinct_v" if entity_type == "view" else "_distinct" %}
            {% set entity_name = destination_dataset ~ "." ~ column_name ~ suffix %}

            {% set create_entity_sql %}
                CREATE OR REPLACE {{ entity_type | upper }} `{{ entity_name }}` AS
                SELECT DISTINCT `{{ column_name }}` AS {{ column_name }}
                FROM `{{ source_table }}`
                ORDER BY 1
            {% endset %}

            {% if dry_run %}
                {{
                    log(
                        "[DRY RUN] Would create " ~ entity_type ~ ": " ~ entity_name,
                        info=True,
                    )
                }}
            {% else %}
                {{ log("Creating " ~ entity_type ~ ": " ~ entity_name, info=True) }}
                {% do run_query(create_entity_sql) %}
            {% endif %}
        {% endfor %}

        {% if dry_run %}
            {{
                log(
                    "[DRY RUN] Would create " ~ columns_result
                    | length ~ " " ~ entity_type ~ "s in " ~ destination_dataset,
                    info=True,
                )
            }}
        {% else %}
            {{
                log(
                    "Done. Created " ~ columns_result
                    | length ~ " " ~ entity_type ~ "s in " ~ destination_dataset,
                    info=True,
                )
            }}
        {% endif %}
    {% endif %}

{% endmacro %}


{% macro generate_distinct_value_stats(
    source_table,
    destination_dataset,
    location="EU",
    entity_type="table",
    dry_run=false
) %}
    {#
        Enhanced version: Creates statistical analysis tables per column with distinct values,
        frequencies, percentages, and other statistical measures.
        
        TODO: Implementation pending
    #}
    {{ log("Enhanced statistical version coming soon...", info=True) }}

{% endmacro %}
