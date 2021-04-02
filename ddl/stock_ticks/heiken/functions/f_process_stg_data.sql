-- DROP FUNCTION heiken.f_process_stg_data(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION heiken.f_process_stg_data(_interval_unit TEXT, _interval_value TEXT)
    RETURNS bool
    LANGUAGE plpgsql AS
$$
    DECLARE
        _table_name TEXT := 'heiken_' || _interval_value || '_' || _interval_unit;
        _alias  TEXT := 'h' || _interval_value || LEFT(_interval_unit, 1) || 's';
        _insert_query   TEXT := 'INSERT INTO heiken.'|| _table_name ||' (tick_time, stock_ticker_code, ha_open, ha_high, ha_low, ha_close, volume, ticker_data_seq_num)' || CHR(10) ||
                                'SELECT' || CHR(10) ||
                                CHR(9) || _alias || '.tick_time,' || CHR(10) ||
                                CHR(9) || _alias || '.stock_ticker_code,' || CHR(10) ||
                                CHR(9) || _alias || '.ha_high,' || CHR(10) ||
                                CHR(9) || _alias || '.ha_open,' || CHR(10) ||
                                CHR(9) || _alias || '.ha_low,' || CHR(10) ||
                                CHR(9) || _alias || '.ha_close,' || CHR(10) ||
                                CHR(9) || _alias || '.volume,' || CHR(10) ||
                                CHR(9) || _alias || '.ticker_data_seq_num' || CHR(10) ||
                                'FROM' || CHR(10) ||
                                CHR(9) || 'heiken.' || _table_name || '_stg ' || _alias || ';';
        _complete_txn   TEXT := _insert_query;
    BEGIN
        EXECUTE _complete_txn;
        Return True;
    END;
$$