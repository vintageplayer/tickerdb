-- DROP FUNCTION config.f_get_table_setup_script(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION config.f_get_table_setup_script(_interval_unit TEXT, _interval_value TEXT)
    RETURNS text
    LANGUAGE plpgsql
AS
    $$
    DECLARE
        _create_data_table_script   TEXT := ( SELECT data.f_get_create_data_tables_script( _interval_unit,  _interval_value) );
        _create_complete_data_view_script   TEXT := ( SELECT data.f_get_create_complete_data_view_script( _interval_unit,  _interval_value) );
        _create_heiken_data_table_script    TEXT := ( SELECT heiken.f_get_create_heiken_data_table_ddl( _interval_unit,  _interval_value) );
        _create_heiken_stg_view_script  TEXT := ( SELECT heiken.f_get_create_heiken_stage_view_ddl( _interval_unit,  _interval_value) );
        _create_heiken_complete_data_view_script    TEXT := ( SELECT heiken.f_get_create_heiken_complete_data_view_script( _interval_unit,  _interval_value) );
        _complete_table_setup_script    TEXT := _create_data_table_script || CHR(10) || CHR(10) ||
                                                _create_complete_data_view_script || CHR(10) || CHR(10) ||
                                                _create_heiken_data_table_script || CHR(10) || CHR(10) ||
                                                _create_heiken_stg_view_script || CHR(10) || CHR(10) ||
                                                _create_heiken_complete_data_view_script;

    BEGIN
        RETURN _complete_table_setup_script;
    END;
    $$