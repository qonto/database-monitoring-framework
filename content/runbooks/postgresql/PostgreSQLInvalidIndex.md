---
title: Invalid index
---

# PostgreSQLInvalidIndex

## Meaning

Alert is triggered when an index is in *invalid* state for a while.

## Impact

- PostgreSQL does not use the index for query execution, which could degrade query performances.

## Diagnosis

- If an error occurred during index creation:

    1. If the index is `UNIQUE` and created with `CONCURRENTLY` option, data unicity was likely violated during index creation

        <details>
        <summary>More</summary>

        When a `UNIQUE` index is created with `CONCURRENTLY` option, PostgreSQL proceeds in 2 steps:
        1. Process all data to create the index
        2. Process modified data during index creation

        If `UNIQUE` constraint is violated between step 1 and step 2, PostgreSQL will mark the index as invalid.

        Example:

        {{% sql "sql/create-index-concurrently.sql" %}}
        </details>

    1. Check if the query to create the index did not complete

        Look at PostgreSQL logs to have the index creation error message.

        If the query was killed or canceled (e.g. due to statement timeout), it will be reported in PostgreSQL logs.

- If the error occurred on an existing index:

    1. Check if there are rows with more than 8191 bytes

        <details>
        <summary>Why?</summary>
        PostgreSQL limits index column size to 8191 bytes.

        If you try to index larger data, the index will be marked as invalid since it cannot contain all data.
        </details>

        <details>
        <summary>How?</summary>

        Find rows with a column larger than 8191 bytes:

        {{% sql "sql/find-too-large-columns.sql" %}}

        </details>

## Mitigation

PostgreSQL doesn't use the invalid index.

1. Delete the index

1. Recreate index

## Additional resources

<details>
<summary>Production experiences</summary>

- The index is still in creation. This alert is triggered after 1 hour. If the index is still being created, it is expected its state is `invalid`.

- An index has been corrupted because the query that created it was killed due to `statement_timeout`.

</details>

- <https://www-footcow-com.translate.goog/index.php/post/2020/05/17/D-o%C3%B9-provienne-les-index-INVALID?_x_tr_sl=fr&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=wapp>
