-- TODO turn into macro
with
    get_id_for_row as (
        select string_column, row_number() over () as row_id
        from {{ ref("dummy_single_string_column") }}
    ),

    get_tokens as (
        select row_id, lower(string_column_parsed) as word
        from
            get_id_for_row,
            unnest(
                text_analyze(
                    trim(cast(string_column as string)), analyzer => 'LOG_ANALYZER'
                )
            ) as string_column_parsed
    )

select row_id, word, count(*) as occurrences
from get_tokens
group by row_id, word
