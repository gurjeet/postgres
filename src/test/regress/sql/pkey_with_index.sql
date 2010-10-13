
CREATE TABLE rpi_test( a int , b varchar(10), c char);

-- add some data so that all tests have something to work with.

INSERT INTO rpi_test VALUES( 1, 2 );
INSERT INTO rpi_test VALUES( 3, 4 );
INSERT INTO rpi_test VALUES( 5, 6 );

CREATE UNIQUE INDEX rpi_uniq_idx ON rpi_test(a , b);
ALTER TABLE rpi_test ADD primary key(a, b) WITH (INDEX = 'rpi_uniq_idx');

CREATE UNIQUE INDEX rpi_uniq2_idx ON rpi_test(b , a);
ALTER TABLE rpi_test DROP CONSTRAINT rpi_test_pkey, ADD primary key(b, a) WITH (INDEX = 'rpi_uniq2_idx');

DROP INDEX rpi_uniq_idx;
DROP INDEX rpi_uniq2_idx;

CREATE UNIQUE INDEX rpi_uniq_idx ON rpi_test(a , b);
ALTER TABLE rpi_test ADD UNIQUE(a, b) WITH (INDEX = 'rpi_uniq_idx');



ALTER TABLE rpi_test ADD PRIMARY KEY (a, b) WITH ( INDEX = 3 );
ALTER TABLE rpi_test ADD PRIMARY KEY (a, b) WITH ( INDEX = del );
ALTER TABLE rpi_test ADD PRIMARY KEY(b, a) WITH (INDEX = 'rpi_idx_doesnt_exist');

ALTER TABLE rpi_test ADD UNIQUE (a);
ALTER TABLE rpi_test ADD PRIMARY KEY(a) WITH (INDEX = 'rpi_test_a_key');

CREATE INDEX rpi_idx1 ON rpi_test(a , b);

ALTER TABLE rpi_test ADD primary key(a, b) WITH (INDEX = 'rpi_idx1'); -- should fail; non-unique

CREATE UNIQUE INDEX rpi_idx2 ON rpi_test(a , b);

-- should fail; WITH INDEX option specified more than once.
ALTER TABLE rpi_test ADD PRIMARY KEY (a, b) WITH ( INDEX = 'rpi_idx2', INDEX = 'rpi_idx2' );

ALTER TABLE rpi_test ADD primary key(a, b) WITH (INDEX = 'rpi_idx2');

ALTER TABLE rpi_test DROP CONSTRAINT rpi_test_pkey;

ALTER TABLE rpi_test ADD primary key(a, b);

CREATE UNIQUE INDEX rpi_idx3 ON rpi_test(a);

ALTER TABLE rpi_test DROP CONSTRAINT rpi_test_pkey, ADD PRIMARY KEY(a, b) WITH (INDEX = 'rpi_idx3'); -- should fail

DROP INDEX rpi_idx3;

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%' ORDER BY relkind DESC, relname ASC;

DROP TABLE rpi_test;

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%';

