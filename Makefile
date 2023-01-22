SHELL=bash

k6.log:
	pgbench -i -IdtGvpf -s100 -q
	psql -f N=10 -f init.sql
	docker run -d --net=host -e HASURA_GRAPHQL_DATABASE_URL=postgres://$${PGUSER}:$${PGPASSWORD}@$${PGHOST}:$${PGPORT}/$${PGDATABASE} -e HASURA_GRAPHQL_ENABLE_CONSOLE=true hasura/graphql-engine:latest
	sleep 10
	seq 10 | xargs -I{} curl -s -H 'Content-type: application/json' --data-binary '{"type":"pg_track_table","args":{"source":"default","table":"test_{}"}' "http://127.0.0.1:8080/v1/metadata" | jq -r '.'
	curl -s -H 'Content-type: application/json' --data-binary @config.json "http://127.0.0.1:8080/v1/metadata" | jq -r '.'
	k6 run -u 50 test.js --summary-export $@
