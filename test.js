import { sleep } from 'k6'
import http from 'k6/http'

export const options = {
  stages: [
    { duration: '10s', target: 1 },
  ],
  ext: {
    loadimpact: {
      distribution: {
        'amazon:us:ashburn': { loadZone: 'amazon:us:ashburn', percent: 100 },
      },
    },
  },
}

export default function main() {
  let response = http.get('http://127.0.0.1:8080/api/rest/abalance/10')
}
