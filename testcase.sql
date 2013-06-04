BEGIn;

CREATE TABLE atm( id SERIAL PRIMARY KEY, balance INT NOT NULL DEFAULT 0) WITH (fillfactor = 0);

INSERT INTO atm (balance) SELECT  1000 FROM generate_series(1, 1000);

select pg_size_pretty(pg_relation_size('atm')), pg_size_pretty(pg_total_relation_size('atm') );

COMMIT;
