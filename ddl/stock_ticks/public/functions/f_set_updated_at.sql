CREATE FUNCTION f_set_updated_at() returns TRIGGER
    language plpgsql
as
$$
BEGIN
  NEW.updated_at := f_get_epochmillis(now());

  RETURN NEW;
END;
$$;
