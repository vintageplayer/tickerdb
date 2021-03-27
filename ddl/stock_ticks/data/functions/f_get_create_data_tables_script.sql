CREATE OR REPLACE FUNCTION data.f_get_create_data_tables_script(_interval_unit text, _interval_value text)
    RETURNS text
    LANGUAGE plpgsql
AS
    $$
    DECLARE
    _data_table_name  TEXT := 'data_' || _interval_value || '_' || _interval_unit;
    _column_ddl TEXT := CHR(9) || 'id SERIAL' || CHR(10) ||
                        CHR(9) || ',tick_time timestamp WITH TIME ZONE NOT NULL' || CHR(10) ||
                        CHR(9) || ',stock_ticker_code TEXT NOT NULL' || CHR(10) ||
                        CHR(9) || ',opening_price FLOAT8' || CHR(10) ||
                        CHR(9) || ',high_price FLOAT8' || CHR(10) ||
                        CHR(9) || ',low_price FLOAT8' || CHR(10) ||
                        CHR(9) || ',closing_price FLOAT8' || CHR(10) ||
                        CHR(9) || ',volume BIGINT' || CHR(10) ||
                        CHR(9) || ',ticker_data_seq_num BIGINT' || CHR(10) ||
                        CHR(9) || ',created_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp())' || CHR(10) ||
                        CHR(9) || ',updated_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp())' || CHR(10) ||
                        CHR(9) || ',UNIQUE (stock_ticker_code, tick_time)' || CHR(10) ||
                        CHR(9) || ',UNIQUE (stock_ticker_code, ticker_data_seq_num)';
    _create_data_table_ddl TEXT := 'CREATE TABLE stg.' || _data_table_name || '(' ||CHR(10) ||
                                _column_ddl || CHR(10) ||
                                ');';
    _create_stg_table_ddl  TEXT := 'CREATE TABLE stg.' || _data_table_name || '(' ||CHR(10) ||
                                _column_ddl || CHR(10) ||
                                ');' || CHR(10) || CHR(10) ||
                                'ALTER TABLE stg.' || _data_table_name || CHR(10) ||
                                'DROP COLUMN ticker_data_seq_num;';
    _data_last_updated_trigger_ddl  TEXT :=  f_get_create_last_updated_at_trigger_script('data', _data_table_name);
    _stg_last_updated_trigger_ddl  TEXT :=  f_get_create_last_updated_at_trigger_script('stg', _data_table_name);

    _create_tables_script   TEXT := 'BEGIN;' || CHR(10) || CHR(10) ||
                                    '-- DROP TABLE data.' || _data_table_name || ';' || CHR(10) || CHR(10) ||
                                    _create_data_table_ddl || CHR(10) || CHR(10) ||
                                    _data_last_updated_trigger_ddl || CHR(10) || CHR(10) ||
                                    '-- DROP TABLE stg.' || _data_table_name || ';' || CHR(10) || CHR(10) ||
                                    _create_stg_table_ddl || CHR(10) || CHR(10) ||
                                    _stg_last_updated_trigger_ddl || CHR(10) || CHR(10) ||
                                    'COMMIT;';

    BEGIN
        RETURN _create_tables_script;
    end;
    $$