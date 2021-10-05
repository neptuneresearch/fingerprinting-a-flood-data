-- vinindex_flood: Helper view to select transaction inputs from Isthmus's transaction source fingerprint in the block range.
CREATE VIEW vinindex_flood AS
    SELECT
        block.height AS height,
        tx.ordinality AS tx_index,
        vin.ordinality AS vin_index
    FROM monero AS block,
    LATERAL UNNEST(block.transactions) WITH ORDINALITY tx(hash, version, unlock_time, vin, vout, extra, fee),
    LATERAL UNNEST(tx.vin) WITH ORDINALITY vin
    WHERE 
        -- Block range
        block.height >= 2345000 -- 2021-04-22 15:23:11
        AND block.height <= 2443799 -- 2021-09-06 23:45:37
        -- unlock_filter
        AND tx.unlock_time = 0
        -- core_fees
        AND tx.fee < 20000000
        -- tx_extra_filter
        AND OCTET_LENGTH(tx.extra) = 44
        -- num_outputs
        AND CARDINALITY(tx.vout) = 2
        -- RingCT
        AND tx.version = 2 AND vin.amount = 0
    ORDER BY height ASC, tx_index ASC, vin_index ASC;

CREATE VIEW ringmember_height_flood AS
    SELECT 
        tx_block_height,
        tx_block_tx_index,
        tx_vin_index,
        tx_vin_ringmember_index,
        ringmember_block_height
    FROM tx_ringmember_list trl
    JOIN vinindex_flood vinflood ON vinflood.height = trl.tx_block_height AND vinflood.tx_index = trl.tx_block_tx_index AND vinflood.vin_index = trl.tx_vin_index
    ORDER BY tx_block_height ASC, tx_block_tx_index ASC, tx_vin_index ASC, tx_vin_ringmember_index ASC;