CREATE OR REPLACE FUNCTION heiken.f_get_create_heiken_stage_view_ddl(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql AS
    $$
    DECLARE
        _relation_name  TEXT := 'heiken_' || _interval_value || '_' || _interval_unit;
        _alias          TEXT := _interval_value || LEFT(_interval_unit, 1);
        _view_query     TEXT := 'with recursive heiken_data AS (' || CHR(10) ||
                                CHR(9) || 'SELECT' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd'|| _alias || '.tick_time,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd'|| _alias || '.stock_ticker_code,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'GREATEST(d'|| _alias || '.high_price, ((h'|| _alias || '.ha_open+h' || _alias || '.ha_close)/2), ((d'|| _alias || '.opening_price+d'|| _alias || '.high_price+d'|| _alias || '.low_price+d'|| _alias || '.closing_price)/4)) as ha_high,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'LEAST(d'|| _alias || '.low_price, ((h'|| _alias || '.ha_open+h'|| _alias || '.ha_close)/2), ((d'|| _alias || '.opening_price+d'|| _alias || '.high_price+d'|| _alias || '.low_price+d'|| _alias || '.closing_price)/4)) as ha_low,' || CHR(10) ||
                                CHR(9) || CHR(9) || '(h'|| _alias || '.ha_open+h'|| _alias || '.ha_close)/2 as ha_open,' || CHR(10) ||
                                CHR(9) || CHR(9) || '(d'|| _alias || '.opening_price+d'|| _alias || '.high_price+d'|| _alias || '.low_price+d'|| _alias || '.closing_price)/4 as ha_close,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd'|| _alias || '.volume,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd'|| _alias || '.ticker_data_seq_num' || CHR(10) ||
                                CHR(9) || 'FROM data.data_'|| _interval_value || '_' || _interval_unit ||'_complete d' || _alias || CHR(10) ||
                                CHR(9) || 'LEFT JOIN heiken.'|| _relation_name ||' h' || _alias || ' on d' || _alias || '.stock_ticker_code = h' || _alias || '.stock_ticker_code AND h' || _alias || '.ticker_data_seq_num = d' || _alias || '.ticker_data_seq_num-1' || CHR(10) ||
                                CHR(9) || 'WHERE d' || _alias || '.ticker_data_seq_num = (SELECT COALESCE(max(ticker_data_seq_num),0) FROM heiken.' || _relation_name ||' m) +1' || CHR(10) ||
                                CHR(9) || 'UNION ALL' || CHR(10) ||
                                CHR(9) || 'SELECT' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd'|| _alias || '_r.tick_time,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd' || _alias || '_r.stock_ticker_code,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'GREATEST(d' || _alias || '_r.high_price, ((h.ha_open+h.ha_close)/2), ((d' || _alias || '_r.opening_price+d' || _alias || '_r.high_price+d' || _alias || '_r.low_price+d' || _alias || '_r.closing_price)/4)) as ha_high,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'LEAST(d' || _alias || '_r.low_price, ((h.ha_open+h.ha_close)/2), ((d' || _alias || '_r.opening_price+d' || _alias || '_r.high_price+d' || _alias || '_r.low_price+d' || _alias || '_r.closing_price)/4)) as ha_low,' || CHR(10) ||
                                CHR(9) || CHR(9) || '(h.ha_open+h.ha_close)/2 as ha_open,' || CHR(10) ||
                                CHR(9) || CHR(9) || '(d' || _alias || '_r.opening_price+d' || _alias || '_r.high_price+d' || _alias || '_r.low_price+d' || _alias || '_r.closing_price)/4 as ha_close,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd' || _alias || '_r.volume,' || CHR(10) ||
                                CHR(9) || CHR(9) || 'd' || _alias || '_r.ticker_data_seq_num' || CHR(10) ||
                                CHR(9) || 'FROM data.data_' || _interval_value || '_' || _interval_unit || '_complete d' || _alias || '_r' || CHR(10) ||
                                CHR(9) || 'JOIN heiken_data h ON h.ticker_data_seq_num = d' || _alias || '_r.ticker_data_seq_num-1 and h.stock_ticker_code = d' || _alias || '_r.stock_ticker_code' || CHR(10) ||
                                ')' || CHR(10) ||
                                ' SELECT' || CHR(10) ||
                                CHR(9) || 'hd.tick_time,' || CHR(10) ||
                                CHR(9) || 'hd.stock_ticker_code,' || CHR(10) ||
                                CHR(9) || 'ROUND(hd.ha_open::NUMERIC,2) as ha_open,' || CHR(10) ||
                                CHR(9) || 'ROUND(hd.ha_high::NUMERIC,2) as ha_high,' || CHR(10) ||
                                CHR(9) || 'ROUND(hd.ha_low::NUMERIC,2) as ha_low,' || CHR(10) ||
                                CHR(9) || 'ROUND(hd.ha_close::NUMERIC,2) as ha_close,' || CHR(10) ||
                                CHR(9) || 'hd.volume,' || CHR(10) ||
                                CHR(9) || 'hd.ticker_data_seq_num' || CHR(10) ||
                                'FROM heiken_data hd' || CHR(10) ||
                                ';';
        _stg_view_ddl   TEXT := 'CREATE OR REPLACE VIEW heiken.' || _relation_name ||'_stg AS' || CHR(10) ||
                                _view_query;

    BEGIN
        RETURN _stg_view_ddl;
    end;
    $$