-- -*- sql-product: postgres; -*-

select format('drop table if exists test_%1\$$s; create table if not exists test_%1\$$s (id uuid primary key default gen_random_uuid(), name text)', generate_series(1, :N));

\gexec

select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, repeat(md5(random()::text), 2) name) sample');

\gexec

select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, random()::text name) sample', generate_series(1, :N));

\gexec

-- echo "select format('drop table if exists test_%1\$$s; create table if not exists test_%1\$$s (id uuid primary key default gen_random_uuid(), name text)', generate_series(1, :N))" "\gexec" | psql -v N=10
-- echo "select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, repeat(md5(random()::text), 2) name) sample')" "\gexec" | psql -v N=10
-- echo "select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, random()::text name) sample', generate_series(1, :N))" "\gexec" | psql -v N=10
