import http from 'k6/http';
import { sleep } from 'k6';
const query = `query {test_${__ENV.N} {name}}`;
const headers = {'Content-Type': 'application/json'};
const res = http.post('http://127.0.0.1/v1/graphql', JSON.stringify({query: query}), {headers: headers});
