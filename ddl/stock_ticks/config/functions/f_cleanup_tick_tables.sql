-- DROP FUNCTION config.f_cleanup_tick_tables(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION config.f_cleanup_tick_tables(_interval_unit TEXT, _interval_value TEXT)
    RETURNS bool
    LANGUAGE plpgsql
AS
    $$
    DECLARE
        _complete_table_cleanup_script    TEXT := (SELECT config.f_get_cleanup_tables_query(_interval_unit, _interval_value));
    BEGIN
        EXECUTE _complete_table_cleanup_script;
        RETURN true;
    END;
    $$
