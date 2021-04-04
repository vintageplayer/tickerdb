CREATE OR REPLACE FUNCTION config.f_setup_interval_tables()
    RETURNS trigger
    LANGUAGE plpgsql AS
    $$
    DECLARE
        _interval_unit TEXT := NEW.interval_unit;
        _interval_value TEXT := (NEW.interval_value)::TEXT;
    BEGIN
        EXECUTE 'SELECT config.f_setup_tick_tables(''' || _interval_unit || ''', ''' || _interval_value || ''')';
        RETURN NEW;
    end;

    $$



