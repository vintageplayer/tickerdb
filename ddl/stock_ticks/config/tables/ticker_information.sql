BEGIN;

-- DROP TABLE config.ticker_information;

CREATE TABLE config.ticker_information (
	id SERIAL,
	ticker_code TEXT NOT NULL UNIQUE ,
	stock_name TEXT NOT NULL UNIQUE ,
    is_enabled BOOLEAN NOT NULL DEFAULT False,
	classification TEXT,
	sector TEXT,
	latest_data_time BIGINT NOT NULL DEFAULT 0,
	created_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp()),
	updated_at BIGINT NOT NULL DEFAULT f_get_epochmillis(clock_timestamp())
);

CREATE TRIGGER t_set_lastupdated_at
    BEFORE UPDATE
    ON config.ticker_information
    FOR EACH ROW
EXECUTE PROCEDURE f_set_updated_at();

COMMIT;