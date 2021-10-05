CREATE VIEW block_n_tx_2021 AS
    SELECT 
        block.height,
        block.timestamp,
        CARDINALITY(block.transactions) AS n_tx
    FROM monero block
    WHERE 
        block.height >= 2264584 -- 2021-01-01 00:03:43
        AND block.height <= 2437999 -- 2021-08-29 22:03:16
    ORDER BY block.height ASC;