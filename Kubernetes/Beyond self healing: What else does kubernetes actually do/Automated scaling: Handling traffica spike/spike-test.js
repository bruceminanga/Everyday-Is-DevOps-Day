import http from 'k6/http';
export const options = {
  stages: [
    { duration: '30s', target: 20 },   // ramp
    { duration: '1m', target: 200 },   // spike
    { duration: '2m', target: 200 },   // sustain
    { duration: '30s', target: 0 },    // drop-off
  ],
};
export default function () {
  http.get('http://localhost:8080');
}