{% macro edge_weight_scaler(
  input_object, 
  col1, col2, 
  X, X_alias, 
  min_range, max_range, outlier_ceiling
  ) %}
  /*
  Knowledge Graph Edge Weight Scaler: 
  Scales the relationship weights between 2 nodes up to the given max_range and min_range.
  Refactor of the sklearn MinMaxScaler https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MinMaxScaler.html

  Parameters:
    @input_object: the table/view/model to process
    @col1: node1
    @col2: node2
    @X: weight of the relationship between node 1 and node2
    @X_alias: alias for the scaled new column
    @outlier_ceiling: OPTIONAL. Maximum value allowed for the weight X, in case we want to avoid the effect of outliers)
    @min_range: desired minimum value for the new scaled column
    @max_range: desired maximum value for the new scaled column
 

-- to standarize a concrete weight X in an unidirectional relationship between 2 nodes 
-- https://scikit-learn.org/stable/modules/generated/sklearn.preprocessing.MinMaxScaler.html
-- => input table: must contain col1, col2, X
-- => col1: Node1
-- => col2: Node2
-- => X: Weight, a numeric value to measure. After processing X will belong to [min_range, max_range]
-- => outlier_ceiling: OPTIONAL. Maximum value allowed for X (in order to avoid the effect of outliers in our
-- [min_range, max_range])
-- stablish max and min global limits
*/
{% if outlier_ceiling %}

max_min_pubs as (
    select
        if(max({{ X }}) >{{ outlier_ceiling }}, {{ outlier_ceiling }}, max({{ X }})) as max_pubs, min({{ X }}) as min_pubs
    from {{ input_object }}
),
-- process outliers to make them less important
with_without_outliers as (
    select {{ col1 }}, {{ col2 }}, if({{ X }}>{{ outlier_ceiling }}, {{ outlier_ceiling }}, {{ X }}) as {{ X }}
    from {{ input_object }}
)

{% else %}

max_min_pubs as (select max({{ X }}) as max_pubs, min({{ X }}) as min_pubs from {{ input_object }}),
-- no outliers processing
with_without_outliers as (select {{ col1 }}, {{ col2 }}, {{ X }} from {{ input_object }})

{% endif %}

-- {{ col1 }},
-- {{ col2 }},
select *
except
    ({{ X }}),
    (
        (sum({{ X }}) - (select min_pubs from max_min_pubs)) / (
            (select max_pubs from max_min_pubs) - (select min_pubs from max_min_pubs)
        ) * ({{ max_range }} - {{ min_range }}) + {{ min_range }}
    ) as {{ X_alias }}

from with_without_outliers
where {{ col1 }} > {{ col2 }}
group by {{ col1 }}, {{ col2 }}

{% endmacro %}


    {% macro normalise_col(col, name) %}
    -- this macro normalises the values of a column between 0 and 1
    ({{ col }} - min({{ col }}) over ()) / (max({{ col }}) over () - min({{ col }}) over ()) as {{ name }}
    {% endmacro %}
