/* contrib/pg_prewarm/pg_prewarm--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION pg_prewarm" to load this file. \quit

-- Register the function.
CREATE FUNCTION pg_prewarm(regclass, text, text, int8, int8)
RETURNS int8
AS 'MODULE_PATHNAME', 'pg_prewarm'
LANGUAGE C;
