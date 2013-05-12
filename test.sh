#!/bin/bash

(echo "select count(*) from pg_class where oid=0 "; for ((i=0;i<$1;++i)); do echo -n " and oid=$i"; done) 
