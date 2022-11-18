/*Copyright (C) 2022 Dremio Corporation 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.*/

{%- macro dremio__support_multiple_grantees_per_dcl_statement() -%}
    {{ return(False) }}
{%- endmacro -%}

{% macro dremio__get_show_grant_sql(relation) %}
    {%- if relation.type == 'table' -%}
        {%- set relation_without_double_quotes = target.datalake ~ '.' ~ target.root_path ~ '.' ~ relation.identifier-%}
    {%- else -%}
        {%- set relation_without_double_quotes = relation.database ~ '.' ~ relation.schema ~ '.' ~ relation.identifier-%}
    {%- endif %}

    SELECT privilege, grantee_id
        FROM sys.privileges 
        WHERE privileges.object_id='{{ relation_without_double_quotes }}'
{% endmacro %}

{%- macro dremio__get_grant_sql(relation, privilege, grantees) -%}
    grant {{ privilege }} on {{relation.type}} {{ relation }} to user {{ grantees | join(', ') }}
{%- endmacro -%}

{%- macro default__get_revoke_sql(relation, privilege, grantees) -%}
    revoke {{ privilege }} on {{ relation.type }} {{ relation }} from user {{ grantees | join(', ') }}
{%- endmacro -%}

{% macro dremio__call_dcl_statements(dcl_statement_list) %}
    {% for dcl_statement in dcl_statement_list %}
        {% call statement('grants') %}
            {{ dcl_statement }};
        {% endcall %}
    {% endfor %}
{% endmacro %}