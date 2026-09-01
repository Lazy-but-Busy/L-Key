import { INestApplication } from '@nestjs/common';
import request from 'supertest';

import { createTestApp } from './utils/test-app';
import { resetDatabase } from './utils/db-reset';

describe('Auth (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterEach(async () => {
    await resetDatabase(app);
  });

  afterAll(async () => {
    await app.close();
  });

  const credentials = { email: 'e2e@lkey.test', password: 'password123' };

  it('registers, logs in, refreshes, and logs out', async () => {
    const server = app.getHttpServer();

    const registered = await request(server)
      .post('/auth/register')
      .send({ ...credentials, displayName: 'E2E Tester' })
      .expect(201);
    expect(registered.body.accessToken).toEqual(expect.any(String));
    expect(registered.body.refreshToken).toEqual(expect.any(String));
    expect(registered.body.user.email).toBe(credentials.email);

    // Registering the same email twice is rejected.
    await request(server).post('/auth/register').send(credentials).expect(409);

    const loggedIn = await request(server)
      .post('/auth/login')
      .send(credentials)
      .expect(201);

    await request(server)
      .get('/auth/me')
      .set('Authorization', `Bearer ${loggedIn.body.accessToken}`)
      .expect(200)
      .expect((res) => {
        expect(res.body.email).toBe(credentials.email);
      });

    // Wrong password is rejected.
    await request(server)
      .post('/auth/login')
      .send({ ...credentials, password: 'wrong' })
      .expect(401);

    const refreshed = await request(server)
      .post('/auth/refresh')
      .send({ refreshToken: loggedIn.body.refreshToken })
      .expect(201);
    expect(refreshed.body.refreshToken).not.toBe(loggedIn.body.refreshToken);

    await request(server)
      .post('/auth/logout')
      .set('Authorization', `Bearer ${refreshed.body.accessToken}`)
      .send({ refreshToken: refreshed.body.refreshToken })
      .expect(204);

    // The now-logged-out refresh token can no longer mint a new pair.
    await request(server)
      .post('/auth/refresh')
      .send({ refreshToken: refreshed.body.refreshToken })
      .expect(401);
  });

  it('rejects /auth/me without a token', async () => {
    await request(app.getHttpServer()).get('/auth/me').expect(401);
  });
});
