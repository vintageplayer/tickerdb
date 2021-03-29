CREATE OR REPLACE FUNCTION data.f_process_stg_data(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql AS
$$
    DECLARE
        _table_name TEXT := 'data_' || _interval_value || '_' || _interval_unit;
        _insert_query   TEXT := 'INSERT INTO data.'|| _table_name ||' (tick_time, stock_ticker_code, opening_price, high_price, low_price, closing_price, volume, ticker_data_seq_num)' || CHR(10) ||
                                'SELECT' || CHR(10) ||
                                CHR(9) ||   'tick_time,' || CHR(10) ||
                                CHR(9) ||   'stock_ticker_code,' || CHR(10) ||
                                CHR(9) ||   'opening_price,' || CHR(10) ||
                                CHR(9) ||   'high_price,' || CHR(10) ||
                                CHR(9) ||   'low_price,' || CHR(10) ||
                                CHR(9) ||   'closing_price,' || CHR(10) ||
                                CHR(9) ||   'volume,' || CHR(10) ||
                                CHR(9) ||   '(' || CHR(10) ||
                                CHR(9) || CHR(9) ||  'SELECT max(d.ticker_data_seq_num)' || CHR(10) ||
                                CHR(9) || CHR(9) ||  'FROM data.data_1_min d' || CHR(10) ||
                                CHR(9) || CHR(9) ||  ') + ROW_NUMBER() OVER(ORDER BY tick_time)' || CHR(10) ||
                                'FROM' || CHR(10) ||
                                CHR(9) || 'stg.data_1_min d1m' || CHR(10) ||
                                'WHERE' || CHR(10) ||
                                CHR(9) || 'd1m.tick_time > (' || CHR(10) ||
                                CHR(9) ||    'SELECT max(tick_time) FROM data.data_1_min' || CHR(10) ||
                                CHR(9) || ');';
        _delete_query   TEXT := 'DELETE FROM stg.' || _table_name || CHR(10) ||
                                'FROM data.' || _table_name || ' d' || CHR(10) ||
                                'WHERE stg.' || _table_name || '.tick_time = d.tick_time' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.opening_price = d.opening_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.high_price = d.high_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.low_price = d.low_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.closing_price = d.closing_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.volume = d.volume ;';
        _complete_txn   TEXT := 'BEGIN;' || CHR(10) || CHR(10) ||
                                _insert_query || CHR(10) || CHR(10) ||
                                _delete_query || CHR(10) || CHR(10) ||
                                'COMMIT;';
    BEGIN
--         EXECUTE _complete_txn;
--         Return True;
        RETURN _complete_txn;
    END;
$$