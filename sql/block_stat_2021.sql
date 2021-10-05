CREATE VIEW block_stat_2021 AS
    SELECT 
        block."height" AS height,
        block.difficulty,
        block."timestamp" AS "timestamp",
        (block."timestamp" - block_previous."timestamp") AS timestamp_delta
    FROM monero block
    JOIN monero block_previous ON block_previous."height" = block."height" - 1
    WHERE 
        block.height >= 2264584 -- 2021-01-01 00:03:43
        AND block.height <= 2443799 -- 2021-09-06 23:45:37
    ORDER BY block.height ASC;