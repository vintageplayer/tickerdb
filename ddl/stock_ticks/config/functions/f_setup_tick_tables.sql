-- DROP FUNCTION config.f_setup_tick_tables(_interval_unit TEXT, _interval_value TEXT);

CREATE OR REPLACE FUNCTION config.f_setup_tick_tables(_interval_unit TEXT, _interval_value TEXT)
    RETURNS bool
    LANGUAGE plpgsql
AS
    $$
    DECLARE
        _complete_table_setup_script    TEXT := (SELECT config.f_get_table_setup_script(_interval_unit, _interval_value));
    BEGIN
        EXECUTE _complete_table_setup_script;
        RETURN true;
    END;
    $$
