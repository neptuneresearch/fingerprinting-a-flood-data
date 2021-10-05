# Data from "Fingerprinting a flood"
For [our report on the mid-2021 Monero transaction volume anomaly](https://mitchellpkt.medium.com/fingerprinting-a-flood-forensic-statistical-analysis-of-the-mid-2021-monero-transaction-volume-a19cbf41ce60) [1], Monero blockchain data 
was extracted from a full node into a [PostgreSQL](https://www.postgresql.org) [2] database, then queried to produce data sets of block, transaction, and transaction input information for analysis. These data sets and their SQL queries are presented in this repository.

All data provided here is transparent on the blockchain and visible from a block explorer.


# Table of Contents
- [Data Overview](#Data-Overview)
- [Using Data Files](#Using-Data-Files)
  - [PostgreSQL data types](#PostgreSQL-data-types)
- [Data: blocks](#Data-blocks)
  - [block_n_out](#block_n_out)
  - [block_n_tx_2021](#block_n_tx_2021)
  - [block_stat_2021](#block_stat_2021)
- [Data: transactions](#Data-transactions)
  - [tx_attribute_2021](#tx_attribute_2021)
- [Data: ring members](#Data-ring-members)
  - [ringmember_height_2021](#ringmember_height_2021)
  - [ringmember_height_flood](#ringmember_height_flood)
- [Building Data Sets](#Building-Data-Sets)
- [References](#References)


# Data Overview

| Data Set                    | XZ size   | CSV size  | Rows      | Blockchain level  | Start height/date    | End height/date      | Source tables                 |
| -                           | -         | -         | -         | -                 | -                    | -                    | -                             |
| `block_n_out`               | 2.3 MB    | 15 MB     | 1485103   | Block             | 0 (2014-04-18)       | 2443799 (2021-09-06) | `monero`                      |
| `block_n_tx_2021`           | 608 KB    | 3.6 MB    | 173416    | Block             | 2264584 (2021-01-01) | 2437999 (2021-08-29) | `monero`                      |
| `block_stat_2021`           | 1.7 MB    | 6.1 MB    | 179216    | Block             | 2264584 (2021-01-01) | 2443799 (2021-09-06) | `monero`                      |
| `tx_attribute_2021`         | 14 MB     | 225 MB    | 5368703   | Transaction       | 2264584 (2021-01-01) | 2437999 (2021-08-29) | `monero`                      |
| `ringmember_height_2021`    | 351 MB    | 2.8 GB    | 127195926 | Transaction input | 2264584 (2021-01-01) | 2443799 (2021-09-06) | `monero, tx_ringmember_list`  |
| `ringmember_height_flood`   | 91 MB     | 779 MB    | 35293610  | Transaction input | 2345000 (2021-04-22) | 2443799 (2021-09-06) | `monero, tx_ringmember_list`  |

| Table               | Package               |
| -                   | -                     |
| `monero`            | `coinmetrics-export`  |
| `tx_ringmember_list`| `ring-membership-sql` |

Start heights were chosen based on the purpose of the data set: 

1. Compare trends of the current year 2021 to trends during the anomaly in mid-2021 (most data sets)

2. Focus on a specific transaction fingerprint in mid-2021 ([`ringmember_height_flood`](#ringmember_height_flood))

End heights were not chosen: data sets included all blocks after the start height that existed in the database when the CSV export was performed. These end heights have been added to the queries so they will reproduce the same data as their exported results.


# Using Data Files
- Data sets are in [CSV (Comma-separated Values) plaintext format](https://en.wikipedia.org/wiki/Comma-separated_values) [3], compressed in [XZIP](https://en.wikipedia.org/wiki/XZ_Utils) archives [4].
- The first line of the file is the header, a comma-separated list of column names.
- The remaining lines of the file are data, one row of comma-separated columns of data per line of file.
- All data values are base-10 numbers. No other characters are used besides numbers and the comma separators.
- Rows are ordered in ascending order of their primary key, which would be the first block height "`*height`" column and any index columns "`*_index`".

## PostgreSQL data types
| Type | Summary from [PostgreSQL documentation](https://www.postgresql.org/docs/13/datatype-numeric.html) [5]|
| - | - |
| BIGINT | 8 bytes storage size; large-range integer; -9223372036854775808 to +9223372036854775807 |
| NUMERIC | variable size; variable user-specified precision, exact up to 131072 digits before the decimal point; up to 16383 digits after the decimal point |


# Data: blocks

These data sets present a few block-level statistics.

## block_n_out
| Column              | Type      | Description                                                 | Source                      | 
| -                   | -         | -                                                           | -                           |
| `height`            | BIGINT    | Block height                                                | `monero.height`             |
| `sum_n_tx_out`      | BIGINT    | Number of transaction outputs across all user transactions  | `monero.transactions.vout`  |

Only includes blocks that have at least one user (non-coinbase) transaction.

## block_n_tx_2021
| Column              | Type      | Description                 | Source                |
| -                   | -         | -                           | -                     |
| `height`            | BIGINT    | Block height                | `monero.height`       |
| `timestamp`         | BIGINT    | Unix timestamp of block     | `monero.timestamp`    |
| `n_tx`              | BIGINT    | Number of user transactions | `monero.transactions` |

Block timestamps are in second-scale Unix format; they are reported by miners and have that quality of validity and accuracy.

## block_stat_2021
| Column              | Type      | Description                                                                 | Source              |
| -                   | -         | -                                                                           | -                   |
| `height`            | BIGINT    | Block height                                                                | `monero.height`     |
| `difficulty`        | BIGINT    | Block difficulty                                                            | `monero.difficulty` |
| `timestamp`         | BIGINT    | Unix timestamp of block                                                     | `monero.timestamp`  |
| `timestamp_delta`   | BIGINT    | Difference between timestamp of this block and timestamp of previous block  | Computed            |

Block timestamps are in second-scale Unix format; they are reported by miners and have that quality of validity and accuracy.

# Data: transactions

## tx_attribute_2021

| Column              | Type      | Description                                                                                             | Source                                      |
| -                   | -         | -                                                                                                       | -                                           |
| `block_height`      | BIGINT    | Block height                                                                                            | `monero.height`                             |
| `block_timestamp`   | BIGINT    | Unix timestamp of block                                                                                 | `monero.timestamp`                          |
| `tx_index`          | BIGINT    | Index of transaction in block                                                                           | `monero.transactions`                       |
| `tx_version`        | BIGINT    | Transaction version                                                                                     | `monero.transactions.version`               |
| `tx_unlock_time`    | NUMERIC   | Transaction unlock time                                                                                 | `monero.transactions.unlock_time`           |
| `tx_n_vin`          | BIGINT    | Number of transaction inputs                                                                            | `monero.transactions.vin`                   |
| `tx_n_vout`         | BIGINT    | Number of transaction outputs                                                                           | `monero.transactions.vout`                  |
| `tx_len_extra`      | BIGINT    | Byte length of `tx_extra` field                                                                         | `monero.transactions.extra`   |
| `tx_fee`            | BIGINT    | Transaction fee in [piconeros](https://web.getmonero.org/resources/moneropedia/denominations.html) [6]  | `monero.transactions.fee`                   |

A list of attributes for every transaction in 2021.

`tx_unlock_time` is `NUMERIC` because its maximum value is double that of `BIGINT`; it is never a decimal.

# Data: ring members

These data sets list ring member block heights for some subset of transactions.

The column prefix "`source_`" means "transaction input".

Note: column naming between these data sets and the source table differs because the previous version of `ring-membership-sql` was used to create this data set; the SQL file and this document reflect the current definition of `tx_ringmember_list`. 

## ringmember_height_2021

| Column              | Type      | Description                                             | Source                                          |
| -                   | -         | -                                                       | -                                               |
| `source_height`     | BIGINT    | Block height                                            | `tx_ringmember_list.tx_block_height`            |
| `source_tx_index`   | BIGINT    | Index of transaction in block                           | `tx_ringmember_list.tx_block_tx_index`          |
| `source_vin_index`  | BIGINT    | Index of transaction input in transaction               | `tx_ringmember_list.tx_vin_index`               |
| `ringmember_index`  | BIGINT    | Index of ring member in this transaction input's ring   | `tx_ringmember_list.tx_vin_ringmember_index`    |
| `ringmember_height` | BIGINT    | Block height of transaction output used as ring member  | `tx_ringmember_list.ringmember_block_height`    |

All transactions in 2021.

## ringmember_height_flood

| Column              | Type      | Description                                             | Source                                          |
| -                   | -         | -                                                       | -                                               |
| `source_height`     | BIGINT    | Block height                                            | `tx_ringmember_list.tx_block_height`            |
| `source_tx_index`   | BIGINT    | Index of transaction in block                           | `tx_ringmember_list.tx_block_tx_index`          |
| `source_vin_index`  | BIGINT    | Index of transaction input in transaction               | `tx_ringmember_list.tx_vin_index`               |
| `ringmember_index`  | BIGINT    | Index of ring member in this transaction input's ring   | `tx_ringmember_list.tx_vin_ringmember_index`    |
| `ringmember_height` | BIGINT    | Block height of transaction output used as ring member  | `tx_ringmember_list.ringmember_block_height`    |

Only includes transactions matching Isthmus's fingerprint for the transaction volume source, which is:
- Has 2 transaction outputs
- `fee` < 20000000
- `unlock_time` = 0
- `tx_extra` is 44 bytes (public key and encrypted payment id)
- RingCT (`transaction version = 2` and `transaction input amount = 0`)

Start height was chosen to be a month before the first transaction volume spike (2021-04-22, the spike being 2021-05-21).


# Building Data Sets
1. Setup a Monero full node and sync the entire blockchain.

2. Setup a PostgreSQL 13+ database.

3. Import the Monero blockchain into the PostgreSQL database with [`coinmetrics-export`](https://github.com/coinmetrics-io/haskell-tools) [[7, 8](#References)].

4. Install the package [`ring-membership-sql`](https://github.com/neptuneresearch/ring-membership-sql) [9].

5. Run the SQL files provided in this repository.

6. Export CSV files from the SQL views. Example command for [`psql`](https://www.postgresql.org/docs/13/app-psql.html) [10]:

    `\COPY (SELECT * FROM ringmember_height_flood) TO '~/ringmember_height_flood.csv' CSV HEADER;`


# References
[1] Isthmus (Mitchell P. Krawiec-Thayer), Neptune, Rucknium, Jberman, Carrington - Fingerprinting a flood: forensic statistical analysis of the mid-2021 Monero transaction volume anomaly. [https://mitchellpkt.medium.com/fingerprinting-a-flood-forensic-statistical-analysis-of-the-mid-2021-monero-transaction-volume-a19cbf41ce60](https://mitchellpkt.medium.com/fingerprinting-a-flood-forensic-statistical-analysis-of-the-mid-2021-monero-transaction-volume-a19cbf41ce60)

[2] PostgreSQL: The world's most advanced open source relational database. [https://www.postgresql.org](https://www.postgresql.org)

[3] Wikipedia - Comma-separated values. [https://en.wikipedia.org/wiki/Comma-separated_values](https://en.wikipedia.org/wiki/Comma-separated_values)

[4] Wikipedia - XZ Utils. [https://en.wikipedia.org/wiki/XZ_Utils](https://en.wikipedia.org/wiki/XZ_Utils)

[5] PostgreSQL 13 Documentation, Chapter 8. Data Types, 8.1 Numeric Types. [https://www.postgresql.org/docs/13/datatype-numeric.html](https://www.postgresql.org/docs/13/datatype-numeric.html)

[6] Moneropedia - Denominations. [https://web.getmonero.org/resources/moneropedia/denominations.html](https://web.getmonero.org/resources/moneropedia/denominations.html)

[7] GitHub - coinmetrics-io/haskell-tools: Tools for exporting blockchain data to analytical databases. [https://github.com/coinmetrics-io/haskell-tools](https://github.com/coinmetrics-io/haskell-tools)

[8] GitHub - Neptune Research - Monero Notes - coinmetrics-export. [https://github.com/neptuneresearch/monero-notes/blob/main/coinmetrics-export.md](https://github.com/neptuneresearch/monero-notes/blob/main/coinmetrics-export.md)

[9] GitHub - Neptune Research - Ring Membership SQL. [https://github.com/neptuneresearch/ring-membership-sql](https://github.com/neptuneresearch/ring-membership-sql)

[10] PostgreSQL 13 Documentation, Part VI. Reference, II. PostgreSQL Client Applications, psql. [https://www.postgresql.org/docs/13/app-psql.html](https://www.postgresql.org/docs/13/app-psql.html)