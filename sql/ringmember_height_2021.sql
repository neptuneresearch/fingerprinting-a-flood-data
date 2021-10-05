-- ringctvinindex_2021: Helper view to select RingCT transaction inputs in the block range.
CREATE VIEW ringctvinindex_2021 AS
    SELECT
        block.height AS height,
        tx.ordinality AS tx_index,
        vin.ordinality AS vin_index
    FROM monero AS block,
    LATERAL UNNEST(block.transactions) WITH ORDINALITY tx(hash, version, unlock_time, vin, vout, extra, fee),
    LATERAL UNNEST(tx.vin) WITH ORDINALITY vin
    WHERE block.height >= 2264584 -- 2021-01-01 00:03:43
        AND block.height <= 2443799 -- 2021-09-06 23:45:37
        AND vin.amount = 0
    ORDER BY height, tx_index, vin_index;

CREATE VIEW ringmember_height_2021 AS 
    SELECT 
        tx_block_height,
        tx_block_tx_index,
        tx_vin_index,
        tx_vin_ringmember_index,
        ringmember_block_height
    FROM tx_ringmember_list trl
    JOIN ringctvinindex_2021 rct ON rct.height = trl.tx_block_height AND rct.tx_index = trl.tx_block_tx_index AND rct.vin_index = trl.tx_vin_index -- RingCT only
    ORDER BY tx_block_height ASC, tx_block_tx_index ASC, tx_vin_index ASC, tx_vin_ringmember_index ASC;