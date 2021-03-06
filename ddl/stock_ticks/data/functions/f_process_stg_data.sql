-- DROP FUNCTION data.f_process_stg_data(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION data.f_process_stg_data(_interval_unit TEXT, _interval_value TEXT)
    RETURNS bool
    LANGUAGE plpgsql AS
$$
    DECLARE
        _table_name TEXT := 'data_' || _interval_value || '_' || _interval_unit;
        _alias  TEXT := 'd' || _interval_value || LEFT(_interval_unit, 1);
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
                                CHR(9) || CHR(9) ||  'SELECT COALESCE(max(d.ticker_data_seq_num),0)' || CHR(10) ||
                                CHR(9) || CHR(9) ||  'FROM data.' || _table_name ||' d' || CHR(10) ||
                                CHR(9) || CHR(9) ||  ') + ROW_NUMBER() OVER(ORDER BY tick_time)' || CHR(10) ||
                                'FROM' || CHR(10) ||
                                CHR(9) || 'stg.' || _table_name || ' ' || _alias || CHR(10) ||
                                'WHERE' || CHR(10) ||
                                CHR(9) || _alias || '.tick_time > (' || CHR(10) ||
                                CHR(9) ||    'SELECT COALESCE(max(tick_time), ''1970-01-01''::timestamp) FROM data.' || _table_name || CHR(10) ||
                                CHR(9) || ');';
        _delete_query   TEXT := 'DELETE FROM stg.' || _table_name || CHR(10) ||
                                'USING data.' || _table_name || ' d' || CHR(10) ||
                                'WHERE stg.' || _table_name || '.tick_time = d.tick_time' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.opening_price = d.opening_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.high_price = d.high_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.low_price = d.low_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.closing_price = d.closing_price' || CHR(10) ||
                                CHR(9) || 'AND stg.' || _table_name || '.volume = d.volume ;';
        _complete_txn   TEXT := _insert_query || CHR(10) || CHR(10) ||
                                _delete_query;
    BEGIN
        EXECUTE _complete_txn;
        Return True;
    END;
$$