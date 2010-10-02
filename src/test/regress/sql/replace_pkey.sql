
CREATE TABLE rpi_test( a int , b varchar(10), c char);

-- add some data so that all tests have something to work with.

INSERT INTO rpi_test VALUES( 1, 2 );
INSERT INTO rpi_test VALUES( 3, 4 );
INSERT INTO rpi_test VALUES( 5, 6 );

CREATE INDEX rpi_idx1 ON rpi_test(a , b);

ALTER TABLE rpi_test ADD primary key(a, b) WITH (INDEX = 'rpi_idx1'); -- should fail; non-unique

CREATE UNIQUE INDEX rpi_idx2 ON rpi_test(a , b);

ALTER TABLE rpi_test ADD primary key(a, b) WITH (INDEX = 'rpi_idx2');

ALTER TABLE rpi_test DROP constraint rpi_idx2;

DROP INDEX rpi_idx2; -- should fail

ALTER TABLE rpi_test ADD primary key(a, b);

CREATE UNIQUE INDEX rpi_idx3 ON rpi_test(a, b);

ALTER TABLE rpi_test ADD PRIMARY KEY(a, b) WITH (INDEX = 'rpi_idx3');

CREATE UNIQUE INDEX rpi_idx4 ON rpi_test( a, b );

ALTER TABLE rpi_test ADD PRIMARY KEY(a, b) WITH (INDEX = 'rpi_idx4');

DROP INDEX rpi_idx3; -- should fail

CREATE UNIQUE INDEX rpi_idx5 ON rpi_test( a );
ALTER TABLE rpi_test ADD primary key(a) WITH (INDEX = 'rpi_idx5');

CREATE UNIQUE INDEX rpi_idx6 ON rpi_test( b );
ALTER TABLE rpi_test ADD primary key(b) WITH (INDEX = 'rpi_idx6');

CREATE UNIQUE INDEX rpi_idx7 ON rpi_test( b, a );
ALTER TABLE rpi_test ADD PRIMARY KEY(b, a) WITH (INDEX = 'rpi_idx7');

ALTER TABLE rpi_test ADD PRIMARY KEY(b, a) WITH (INDEX = 'rpi_idx_doesnt_exist');

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%';

DROP TABLE rpi_test;

SELECT relname, relkind FROM pg_class WHERE relname like E'rpi\\_%';

