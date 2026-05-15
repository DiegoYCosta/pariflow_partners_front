const http = require('http');
const https = require('https');

const target = process.env.PARIFLOW_PROXY_TARGET || 'https://pariflowpartners.com.br';
const port = Number(process.env.PARIFLOW_PROXY_PORT || 3002);
const host = process.env.PARIFLOW_PROXY_HOST || '127.0.0.1';

const server = http.createServer((req, res) => {
  const origin = req.headers.origin || '*';
  res.setHeader('Access-Control-Allow-Origin', origin);
  res.setHeader('Vary', 'Origin, Access-Control-Request-Headers');
  res.setHeader('Access-Control-Allow-Credentials', 'true');
  res.setHeader(
    'Access-Control-Allow-Methods',
    'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  );
  res.setHeader(
    'Access-Control-Allow-Headers',
    req.headers['access-control-request-headers'] || 'authorization,content-type',
  );

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  const upstream = new URL(req.url, target);
  const headers = { ...req.headers, host: upstream.host };
  delete headers.origin;
  const transport = upstream.protocol === 'https:' ? https : http;

  const proxyReq = transport.request(
    upstream,
    { method: req.method, headers },
    (proxyRes) => {
      for (const [key, value] of Object.entries(proxyRes.headers)) {
        if (!key.toLowerCase().startsWith('access-control-')) {
          res.setHeader(key, value);
        }
      }
      res.writeHead(proxyRes.statusCode || 502);
      proxyRes.pipe(res);
    },
  );

  proxyReq.on('error', (error) => {
    res.writeHead(502, { 'content-type': 'application/json' });
    res.end(
      JSON.stringify({
        error: { code: 'DEV_PROXY_ERROR', message: error.message },
      }),
    );
  });

  req.pipe(proxyReq);
});

server.listen(port, host, () => {
  console.log(`dev api proxy http://${host}:${port} -> ${target}`);
});
