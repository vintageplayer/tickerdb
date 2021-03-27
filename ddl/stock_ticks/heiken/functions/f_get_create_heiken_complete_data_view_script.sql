CREATE OR REPLACE FUNCTION heiken.f_get_create_heiken_complete_data_view_script(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql AS $$
    DECLARE
        _relation_name  TEXT := 'heiken_' || _interval_value || '_' || _interval_unit;
        _data_alias   TEXT := 'h' || _interval_value || LEFT(_interval_unit, 1);
        _stg_alias   TEXT := _data_alias || 's';
        _col_list   TEXT := CHR(9) || '__alias__.tick_time' || CHR(10) ||
                            CHR(9) || ',__alias__.stock_ticker_code' || CHR(10) ||
                            CHR(9) || ',__alias__.ha_open' || CHR(10) ||
                            CHR(9) || ',__alias__.ha_high' || CHR(10) ||
                            CHR(9) || ',__alias__.ha_low' || CHR(10) ||
                            CHR(9) || ',__alias__.ha_close' || CHR(10) ||
                            CHR(9) || ',__alias__.volume' || CHR(10) ||
                            CHR(9) || ',__alias__.ticker_data_seq_num';
        _data_select_query TEXT := 'SELECT' || CHR(10) ||
                                          replace(_col_list, '__alias__', _data_alias) || CHR(10) ||
                                          'FROM heiken.' || _relation_name || ' ' || _data_alias;
        _stg_select_query TEXT := 'SELECT' || CHR(10) ||
                                          replace(_col_list, '__alias__', _stg_alias) || CHR(10) ||
                                          'FROM heiken.' || _relation_name || '_stg ' || _stg_alias;
        _complete_view_ddl  TEXT := 'BEGIN;' || CHR(10) || CHR(10) ||
                                    'CREATE OR REPLACE VIEW heiken.' || _relation_name || '_complete AS' || CHR(10) ||
                                    _data_select_query || CHR(10) ||
                                    'UNION' || CHR(10) ||
                                    _stg_select_query || CHR(10) || CHR(10) ||
                                    'COMMIT;';
    BEGIN
        RETURN _complete_view_ddl;
    end;
    $$