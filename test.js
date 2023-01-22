import http from 'k6/http';
import { sleep } from 'k6';
export default function () {
    const query = `query {test_${Math.floor(Math.random()*__ENV.N)+1} {name}}`;
    const headers = {'Content-Type': 'application/json'};
    const res = http.post('http://127.0.0.1:8080/v1/graphql', JSON.stringify({query: query}), {headers: headers});
    console.error(res.status);
    console.error(JSON.stringify(res.request.body));
}
