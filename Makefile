SHELL=bash

k6.log:
	pgbench -i -IdtGvpf -s100 -q
	echo "select format('drop table if exists test_%1\$$s; create table if not exists test_%1\$$s (id uuid primary key default gen_random_uuid(), name text)', generate_series(1, :N))" "\gexec" | psql -v N=10
	echo "select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, repeat(md5(random()::text), 2) name) sample')" "\gexec" | psql -v N=10
	echo "select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, random()::text name) sample', generate_series(1, :N))" "\gexec" | psql -v N=10
	docker run -d --net=host -e HASURA_GRAPHQL_DATABASE_URL=postgres://$${PGUSER}:$${PGPASSWORD}@$${PGHOST}:$${PGPORT}/$${PGDATABASE} -e HASURA_GRAPHQL_ENABLE_CONSOLE=true hasura/graphql-engine:latest
	sleep 10
	curl -s -H 'Content-type: application/json' --data-binary @config.json "http://127.0.0.1:8080/v1/metadata" | jq -r '.'
	k6 run -u 50 test.js --summary-export $@
