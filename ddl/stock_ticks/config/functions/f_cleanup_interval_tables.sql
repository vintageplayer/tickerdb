-- DROP FUNCTION config.f_cleanup_interval_tables();

CREATE OR REPLACE FUNCTION config.f_cleanup_interval_tables()
    RETURNS trigger
    LANGUAGE plpgsql AS
    $$
    DECLARE
        _interval_unit TEXT := OLD.interval_unit;
        _interval_value TEXT := (OLD.interval_value)::TEXT;
    BEGIN
        EXECUTE 'SELECT config.f_cleanup_tick_tables(''' || _interval_unit || ''', ''' || _interval_value || ''')';
        RETURN OLD;
    end;

    $$



