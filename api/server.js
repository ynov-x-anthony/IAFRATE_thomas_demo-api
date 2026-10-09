'use strict';

const express = require('express');
const db = require('./db');

const PORT = Number(process.env.PORT || 3000);
const VERSION = process.env.VERSION || 'dev';

const app = express();
app.use(express.json());

app.use((req, res, next) => {
  const t0 = Date.now();

  res.on('finish', () => {
    console.log(JSON.stringify({
      level: 'info',
      method: req.method,
      path: req.path,
      status: res.statusCode,
      ms: Date.now() - t0,
    }));
  });

  next();
});

app.get('/', (req, res) => {
  res.json({
    ok: true,
    app: 'demo-api',
    version: VERSION
  });
});

app.get('/version', (req, res) => {
  res.json({ version: VERSION });
});

app.get('/health', (req, res) => {
  res.json({ status: 'UP' });
});

app.get('/ready', async (req, res) => {
  try {
    await db.ping();
    res.json({ status: 'READY' });
  } catch (err) {
    res.status(503).json({
      status: 'NOT_READY',
      err: err.message
    });
  }
});

app.get('/products', async (req, res) => {
  try {
    res.json(await db.listProducts());
  } catch (err) {
    res.status(503).json({
      error: 'db_unavailable',
      detail: err.message
    });
  }
});

app.post('/products', async (req, res) => {
  const name = (req.body && req.body.name || '').trim();
  const priceCents = Number(req.body && req.body.price_cents);

  if (!name || !Number.isInteger(priceCents) || priceCents < 0) {
    return res.status(400).json({
      error: 'name (string) et price_cents (entier >= 0) requis'
    });
  }

  try {
    const product = await db.addProduct(name, priceCents);

    res.status(201).json(product);

    fetch(`http://notifier:${process.env.NOTIFIER_PORT || 4000}/notify`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        name: product.name
      }),
      signal: AbortSignal.timeout(3000)
    }).catch((err) => {
      console.error('[api] notify failed:', err.message);
    });

  } catch (err) {
    console.error('[api] db error:', err.message);

    if (!res.headersSent) {
      res.status(503).json({
        error: 'db_unavailable',
        detail: err.message
      });
    }
  }
});

const server = app.listen(PORT, () => {
  console.log(JSON.stringify({
    level: 'info',
    msg: 'demo-api started',
    port: PORT,
    version: VERSION
  }));
});

function shutdown(sig) {
  console.log(JSON.stringify({
    level: 'info',
    msg: 'shutting down',
    sig
  }));

  server.close(() => {
    db.pool.end().then(() => process.exit(0));
  });

  setTimeout(() => process.exit(1), 8000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
