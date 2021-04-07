CREATE OR REPLACE FUNCTION heiken.f_get_create_heiken_data_table_ddl(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql AS
$$
    DECLARE
        _base_relation_name TEXT := 'heiken_' || _interval_value || '_' || _interval_unit;
        _drop_table_query   TEXT := '-- DROP TABLE hieken.' || _base_relation_name || ';';
        _data_table_ddl  TEXT := 'CREATE TABLE heiken.' || _base_relation_name || ' (' || CHR(10) ||
                                 CHR(9) || 'id SERIAL' || CHR(10) ||
                                 CHR(9) || ',tick_time timestamp WITH TIME ZONE NOT NULL' || CHR(10) ||
                                 CHR(9) || ',stock_ticker_code TEXT NOT NULL' || CHR(10) ||
                                 CHR(9) || ',ha_open FLOAT8' || CHR(10) ||
                                 CHR(9) || ',ha_high FLOAT8' || CHR(10) ||
                                 CHR(9) || ',ha_low FLOAT8' || CHR(10) ||
                                 CHR(9) || ',ha_close FLOAT8' || CHR(10) ||
                                 CHR(9) || ',volume BIGINT' || CHR(10) ||
                                 CHR(9) || ',ticker_data_seq_num BIGINT' || CHR(10) ||
                                 CHR(9) || ',created_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp())' || CHR(10) ||
                                 CHR(9) || ',updated_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp())' || CHR(10) ||
                                 CHR(9) || ',UNIQUE (stock_ticker_code, tick_time)' || CHR(10) ||
                                 CHR(9) || ',UNIQUE (stock_ticker_code, ticker_data_seq_num)' || CHR(10) ||
                                 CHR(9) || ',FOREIGN KEY (stock_ticker_code) REFERENCES config.ticker_information(ticker_code)' || CHR(10) ||
                                        ')';
        _heiken_ddl_script  TEXT := _drop_table_query || CHR(10) || CHR(10) ||
                                    _data_table_ddl || CHR(10) ||
                                    ';';
    BEGIN
        RETURN _heiken_ddl_script;
    end;
$$
