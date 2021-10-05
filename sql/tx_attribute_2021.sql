CREATE VIEW flood_tx_attribute AS
    SELECT 
        block."height" AS block_height,
        block."timestamp" AS block_timestamp,
        tx.ordinality AS tx_index,
        tx."version" AS tx_version,
        tx.unlock_time AS tx_unlock_time,
        CARDINALITY(tx.vin) AS tx_n_vin,
        CARDINALITY(tx.vout) AS tx_n_vout,
        OCTET_LENGTH(tx.extra) AS tx_len_extra,
        tx.fee AS tx_fee
    FROM monero block,
    LATERAL unnest(block.transactions) WITH ORDINALITY tx(hash, version, unlock_time, vin, vout, extra, fee)
    WHERE 
        block.height >= 2264584 -- 2021-01-01 00:03:43
        AND block.height <= 2437999 -- 2021-08-29 22:03:16
        AND tx.version = 2 -- RingCT only
    ORDER BY block.height ASC, tx.ordinality ASC;