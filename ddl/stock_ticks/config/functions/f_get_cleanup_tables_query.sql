-- DROP FUNCTION config.f_get_cleanup_tables_query(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION config.f_get_cleanup_tables_query(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql
AS
    $$
    DECLARE
        _interval_name  TEXT := '_' || _interval_value || '_' || _interval_unit;
        _drop_heiken_complete_view_query    TEXT := 'DROP VIEW heiken.heiken' || _interval_name || '_complete;';
        _drop_heiken_stg_view_query    TEXT := 'DROP VIEW heiken.heiken' || _interval_name || '_stg;';
        _drop_heiken_data_table_query    TEXT := 'DROP TABLE heiken.heiken' || _interval_name || ';';
        _drop_data_complete_view_query  TEXT := 'DROP VIEW data.data' || _interval_name || '_complete;';
        _drop_data_stg_view_query  TEXT := 'DROP TABLE stg.data' || _interval_name || ';';
        _drop_data_table_query  TEXT := 'DROP TABLE data.data' || _interval_name || ';';
        _complete_cleanup_script    TEXT := _drop_heiken_complete_view_query || CHR(10) ||
                                            _drop_heiken_stg_view_query || CHR(10) ||
                                            _drop_heiken_data_table_query || CHR(10) ||
                                            _drop_data_complete_view_query || CHR(10) ||
                                            _drop_data_stg_view_query || CHR(10) ||
                                            _drop_data_table_query;
    BEGIN
        RETURN _complete_cleanup_script;
    END;
    $$
