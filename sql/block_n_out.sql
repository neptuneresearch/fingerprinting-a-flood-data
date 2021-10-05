CREATE VIEW block_n_out AS
    SELECT 
        block.height,
        SUM(CARDINALITY(tx.vout)) AS sum_n_tx_out
    FROM monero block,
    LATERAL unnest(block.transactions) WITH ORDINALITY tx(hash, version, unlock_time, vin, vout, extra, fee)
    WHERE block.height <= 2443799 -- 2021-09-06 23:45:37
    GROUP BY block.height
    ORDER BY block.height ASC;