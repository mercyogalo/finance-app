import mongoose from 'mongoose';
import { MongoMemoryServer } from 'mongodb-memory-server';
import request from 'supertest';
import { createApp } from '../src/app';
import { disconnectDatabase } from '../src/services/database';

describe('HTTP API', () => {
  const app = createApp({ rateLimitMax: 100, rateLimitWindowMs: 60_000 });

  afterAll(async () => {
    await disconnectDatabase();
  });

  it('returns liveness without a database', async () => {
    const response = await request(app).get('/health');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ok' });
    expect(response.headers['x-request-id']).toEqual(expect.any(String));
  });

  it('echoes a valid request id', async () => {
    const response = await request(app).get('/health').set('X-Request-Id', 'req_123');

    expect(response.headers['x-request-id']).toBe('req_123');
  });

  it('replaces an invalid request id', async () => {
    const response = await request(app).get('/health').set('X-Request-Id', 'bad id with spaces');

    expect(response.headers['x-request-id']).not.toBe('bad id with spaces');
    expect(response.headers['x-request-id']).toEqual(expect.any(String));
  });

  it('returns the shared error shape for unknown routes', async () => {
    const response = await request(app).get('/missing');

    expect(response.status).toBe(404);
    expect(response.body).toEqual({
      error: { code: 'NOT_FOUND', message: 'Route not found: GET /missing' },
    });
  });

  it('rejects malformed JSON', async () => {
    const response = await request(app)
      .post('/health')
      .set('Content-Type', 'application/json')
      .send('{');

    expect(response.status).toBe(400);
    expect(response.body).toEqual({
      error: { code: 'INVALID_JSON', message: 'Request body must be valid JSON' },
    });
  });

  it('rejects origins that are not on the allowlist', async () => {
    const response = await request(app).get('/health').set('Origin', 'https://evil.example');

    expect(response.status).toBe(403);
    expect(response.body).toEqual({
      error: { code: 'CORS_FORBIDDEN', message: 'Origin is not allowed' },
    });
  });

  it('allows a listed origin', async () => {
    const response = await request(app).get('/health').set('Origin', 'http://localhost:3000');

    expect(response.status).toBe(200);
    expect(response.headers['access-control-allow-origin']).toBe('http://localhost:3000');
  });

  it('rate limits repeated requests and skips health checks', async () => {
    const limited = createApp({ rateLimitMax: 2, rateLimitWindowMs: 60_000 });
    const first = await request(limited).get('/limited-one');
    const second = await request(limited).get('/limited-two');
    const third = await request(limited).get('/limited-three');
    const health = await request(limited).get('/health');

    expect(first.status).toBe(404);
    expect(second.status).toBe(404);
    expect(third.status).toBe(429);
    expect(third.body).toEqual({
      error: { code: 'RATE_LIMITED', message: 'Too many requests' },
    });
    expect(health.status).toBe(200);
  });
});

describe('readiness', () => {
  let mongo: MongoMemoryServer | undefined;

  afterEach(async () => {
    await disconnectDatabase();
  });

  afterAll(async () => {
    if (mongo) {
      await mongo.stop();
    }
  });

  it('returns 503 when MongoDB is not connected', async () => {
    const response = await request(createApp()).get('/ready');

    expect(response.status).toBe(503);
    expect(response.body).toEqual({
      error: { code: 'NOT_READY', message: 'Database is unavailable' },
    });
  });

  it('returns 200 after a successful MongoDB ping', async () => {
    mongo = await MongoMemoryServer.create({ binary: { version: '7.0.14' } });
    await mongoose.connect(mongo.getUri());

    const response = await request(createApp()).get('/ready');

    expect(response.status).toBe(200);
    expect(response.body).toEqual({ status: 'ready' });
  });
});
