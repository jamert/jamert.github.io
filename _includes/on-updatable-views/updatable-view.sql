/* create schema beforehand, to contain our new layer of abstraction */
CREATE SCHEMA model;

/* type for our service record */
CREATE TYPE model.provided_service_t AS
(
  service service_t,
  sla     sla_t
);

/* basic view
   in practice some joins are necessary if data is any complex */
CREATE OR REPLACE VIEW model.account AS
  SELECT
      a.public_id AS id,
      a.name AS name,
      ARRAY(SELECT
                ROW(s.service, s.sla)::model.provided_service_t
              FROM account_service s
              WHERE s.account = a.id) AS services,
      a.registered AS registered
    FROM account a
    ORDER BY 1;

/* triggers that will make our view updatable */

CREATE OR REPLACE FUNCTION model.account_insert() RETURNS TRIGGER AS $$
DECLARE
  db_id integer;
BEGIN
  -- make account
  INSERT INTO account(name) VALUES (NEW.name)
    RETURNING id INTO db_id;
  -- add all services
  INSERT INTO account_service(account, service, sla)
    SELECT db_id, ps.service, ps.sla
      FROM unnest(NEW.services) AS ps;
  -- we need to update our value with generated public id
  -- because it is primary key of our view
  -- you'll see later, when we set up SQLAlchemy mappings
  SELECT public_id INTO NEW.id
    FROM account
    WHERE id = db_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

/* make notice of 'INSTEAD OF INSERT' */
CREATE TRIGGER account_insert INSTEAD OF INSERT ON model.account
  FOR EACH ROW EXECUTE PROCEDURE model.account_insert();

/* doing the same thing for UPDATE and DELETE */
CREATE OR REPLACE FUNCTION model.account_update() RETURNS TRIGGER AS $$
DECLARE
  db_id integer;
  ps    model.provided_service_t;
BEGIN
  SELECT id INTO db_id
    FROM account
    WHERE public_id = NEW.id;

  /* this is just to show another technique
     to deal with changes in array fields
     if you can, then I'd recomment to write simple query
     without special PL/PGSQL loop constructs */
  -- add new services
  FOREACH ps IN ARRAY NEW.services LOOP
    IF NOT (ps = ANY(OLD.services)) THEN
      INSERT INTO account_service(account, service, sla) VALUES
        (db_id, ps.service, ps.sla);
    END IF;
  END LOOP;

  -- delete removed services
  FOREACH ps IN ARRAY OLD.services LOOP
    IF NOT (ps = ANY(NEW.services)) THEN
      DELETE FROM account_service
        WHERE account = db_id
          AND service = ps.service
          AND sla = ps.sla;
    END IF;
  END LOOP;

  -- 'registered field' is read only, so just skip it
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_update INSTEAD OF UPDATE ON model.account
  FOR EACH ROW EXECUTE PROCEDURE model.account_update();


CREATE OR REPLACE FUNCTION model.account_delete() RETURNS TRIGGER AS $$
DECLARE
  db_id integer;
BEGIN
  /* may be use cascaded deletes? */
  SELECT id INTO db_id
    FROM account
    WHERE public_id = OLD.id;

  DELETE FROM account_service
    WHERE account = db_id;

  DELETE FROM account
    WHERE id = db_id;

  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER account_delete INSTEAD OF DELETE ON model.account
  FOR EACH ROW EXECUTE PROCEDURE model.account_delete();
