BEGIN;

-- DROP TABLE config.interval_config;

CREATE TABLE config.interval_config (
	id SERIAL,
	interval_unit TEXT NOT NULL,
	interval_value INT NOT NULL,
	duration_in_seconds BIGINT NOT NULL DEFAULT 0,
	is_enabled BOOLEAN NOT NULL DEFAULT False,
	update_frequency_in_seconds BIGINT NOT NULL DEFAULT 0,
	created_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp()),
	updated_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp()),
	CONSTRAINT config_interval_tick_config_unique_interval_unit_interval_value UNIQUE(interval_unit, interval_value)
);

CREATE TRIGGER t_set_lastupdated_at
    BEFORE UPDATE
    ON config.interval_config
    FOR EACH ROW
EXECUTE PROCEDURE f_set_updated_at();

CREATE TRIGGER t_setup_interval_tables
    BEFORE INSERT
    ON config.interval_config
    FOR EACH ROW
EXECUTE PROCEDURE config.f_setup_interval_tables();

CREATE TRIGGER t_delete_interval_tables
    BEFORE DELETE
    ON config.interval_config
    FOR EACH ROW
    EXECUTE PROCEDURE config.f_cleanup_interval_tables();

COMMIT;