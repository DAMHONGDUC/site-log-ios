// Figma sync: receives exported chunks from figx.js and writes them to the folder given as argv[2] (port 8766).
import http from 'node:http'; import fs from 'node:fs';
const dir = process.argv[2];
http.createServer((req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*'); res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS'); res.setHeader('Access-Control-Allow-Headers', '*');
  if (req.method === 'OPTIONS') { res.end(); return; }
  const name = new URL(req.url, 'http://x').searchParams.get('name').replace(/[^\w.-]/g, '_');
  let body = ''; req.on('data', c => body += c); req.on('end', () => { fs.writeFileSync(dir + '/' + name, body); res.end('ok ' + body.length); });
}).listen(8766, () => console.log('listening'));
