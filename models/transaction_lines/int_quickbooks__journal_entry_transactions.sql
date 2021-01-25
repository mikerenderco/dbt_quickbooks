--To disable this model, set the using_journal_entry variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_journal_entry', True)) }}

with journal_entries as (
    select *
    from {{ ref('stg_quickbooks__journal_entry') }}
),

journal_entry_lines as (
    select *
    from {{ ref('stg_quickbooks__journal_entry_line') }}
),

final as (
    select
        journal_entries.journal_entry_id as transaction_id,
        journal_entry_lines.index as transaction_line_id,
        'journal_entry' as transaction_type,
        journal_entries.transaction_date,
        -- cast(null as string) as item_id,
        -- cast(null as string) as item_quantity,
        -- cast(null as string) as item_unit_price,
        journal_entry_lines.account_id,
        journal_entry_lines.class_id,
        journal_entry_lines.department_id,
        journal_entry_lines.customer_id,
        journal_entry_lines.vendor_id,
        journal_entry_lines.billable_status as billable_status,
        journal_entry_lines.description,
        case when lower(journal_entry_lines.posting_type) = 'credit'
            then journal_entry_lines.amount * -1 
            else journal_entry_lines.amount 
                end as amount,
        journal_entries.total_amount
    from journal_entries

    inner join journal_entry_lines
        on journal_entries.journal_entry_id = journal_entry_lines.journal_entry_id
)

select *
from final