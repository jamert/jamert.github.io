/* write here all data that are not supseptible to duplication */
CREATE TABLE account
(
  id          serial,
  public_id   integer NOT NULL,
  name        text NOT NULL CHECK(name <> ''),
  registered  timestamptz DEFAULT now(),

  PRIMARY KEY (id)
);

/* add trigger for generation of public_id, will use simple function,
   based on xor operation */
CREATE OR REPLACE FUNCTION generate_public_id() RETURNS TRIGGER AS $$
BEGIN
  NEW.public_id := (NEW.id * 443) # 23537;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER generate_public_id BEFORE INSERT ON account
  FOR EACH ROW EXECUTE PROCEDURE generate_public_id();

/* usually I would make separate tables with id and name,
   use those id everywere and force additional foreign keys,
   (manual enums, I suppose)
   but here I try to keep things simple */
CREATE TYPE service_t AS ENUM ('basement', 'dugout', 'castle');
CREATE TYPE sla_t AS ENUM ('normal', 'vip');

/* our many-to-one relationship */
CREATE TABLE account_service
(
  account  integer NOT NULL,
  service  service_t NOT NULL,
  sla      sla_t NOT NULL,

  FOREIGN KEY (account) REFERENCES account(id)
);
