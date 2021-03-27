CREATE OR REPLACE FUNCTION public.f_get_create_last_updated_at_trigger_script(_schema_name text, _table_name text)
    RETURNS text
    LANGUAGE plpgsql
AS
    $$
    DECLARE
    _create_data_table_ddl TEXT := 'CREATE TRIGGER t_set_lastupdated_at' || CHR(10) ||
                                   'before UPDATE' || CHR(10) ||
                                   'ON ' || _schema_name || '.' || _table_name || CHR(10) ||
                                   'FOR EACH ROW' || CHR(10) ||
                                   'EXECUTE PROCEDURE f_set_updated_at();';

    BEGIN
        RETURN _create_data_table_ddl;
    end;
    $$