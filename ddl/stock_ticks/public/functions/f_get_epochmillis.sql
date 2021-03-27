CREATE FUNCTION f_get_epochmillis(_time timestamp with time zone) returns BIGINT
    language sql
AS
$$
SELECT (extract(epoch FROM _time)*1000)::BIGINT AS ts_msec
$$;
