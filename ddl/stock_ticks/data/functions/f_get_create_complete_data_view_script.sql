CREATE OR REPLACE FUNCTION data.f_get_create_complete_data_view_script(_interval_unit TEXT, _interval_value TEXT)
RETURNS text
LANGUAGE plpgsql AS
$$
    DECLARE
        _relation_name  TEXT := 'data_' || _interval_value || '_' || _interval_unit;
        _common_select_columns  TEXT := CHR(9) || 'tick_time' || CHR(10) ||
                                        CHR(9) || ',stock_ticker_code' || CHR(10) ||
                                        CHR(9) || ',opening_price' || CHR(10) ||
                                        CHR(9) || ',high_price' || CHR(10) ||
                                        CHR(9) || ',low_price' || CHR(10) ||
                                        CHR(9) || ',closing_price' || CHR(10) ||
                                        CHR(9) || ',volume';
        _data_table_select_query    TEXT := 'SELECT' || CHR(10) ||
                                            _common_select_columns || CHR(10) ||
                                            CHR(9) || ',ticker_data_seq_num' || CHR(10) ||
                                            'FROM' || CHR(10) ||
                                            CHR(9) || 'data.' || _relation_name || ' dd2m';
        _stg_table_select_query    TEXT := 'SELECT' || CHR(10) ||
                                           _common_select_columns || CHR(10) ||
                                           CHR(9) || ',(' || CHR(10) ||
                                           CHR(9) || CHR(9) || 'SELECT max(d.ticker_data_seq_num)' || CHR(10) ||
                                           CHR(9) || CHR(9) || 'FROM data.' || _relation_name || ' d' || CHR(10) ||
                                           CHR(9) || ') + ROW_NUMBER() OVER(ORDER BY tick_time)' || CHR(10) ||
                                           'FROM' || CHR(10) ||
                                           CHR(9) || 'stg.' || _relation_name || ' sd2m';
        _stg_table_where_clause    TEXT := 'WHERE' || CHR(10) ||
                                           CHR(9) || 'sd2m.tick_time > (' || CHR(10) ||
                                           CHR(9) || CHR(9) || 'SELECT max(tick_time) FROM data.' || _relation_name || CHR(10) ||
                                           CHR(9) || ')';
        _create_view_dll    TEXT := 'CREATE VIEW data.' || _relation_name || '_complete AS' || CHR(10) ||
                                    _data_table_select_query || CHR(10) ||
                                    'UNION' || CHR(10) ||
                                    _stg_table_select_query || CHR(10) ||
                                    _stg_table_where_clause || CHR(10) ||
                                    ';';
    BEGIN
        RETURN _create_view_dll;
    end;
$$