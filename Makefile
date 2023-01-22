SHELL=bash

.ONESHELL:

k6.log:
	pgbench -i -IdtGvpf -s100 -q
	echo <EOF | psql -v N=10
	select format('create table test_%1\$$s (id uuid primary key default gen_random_uuid(), name text)', generate_series(1, :N));
	\gexec
	select format('insert into test_%s (name) select name from (select generate_series(1, :N) id, repeat(md5(random()::text), 2) name) sample');
	\gexec
	EOF
	docker run -d --net=host -e HASURA_GRAPHQL_DATABASE_URL=postgres://$${PGUSER}:$${PGPASSWORD}@$${PGHOST}:$${PGPORT}/$${PGDATABASE} -e HASURA_GRAPHQL_ENABLE_CONSOLE=true hasura/graphql-engine:latest
	sleep 10
	seq 10 | xargs -I{} curl -s -H 'Content-type: application/json' --data-binary '{"type":"pg_track_table","args":{"source":"default","table":"test_{}"}' "http://127.0.0.1:8080/v1/metadata" | jq -r '.'
	curl -s -H 'Content-type: application/json' --data-binary @config.json "http://127.0.0.1:8080/v1/metadata" | jq -r '.'
	k6 run -u 50 test.js --summary-export $@
