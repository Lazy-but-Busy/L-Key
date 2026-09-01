import { INestApplication } from '@nestjs/common';
import request from 'supertest';

import { resetDatabase } from './utils/db-reset';
import { createTestApp } from './utils/test-app';

describe('Sync (e2e)', () => {
  let app: INestApplication;
  let accessToken: string;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterEach(async () => {
    await resetDatabase(app);
  });

  afterAll(async () => {
    await app.close();
  });

  beforeEach(async () => {
    const server = app.getHttpServer();
    const registered = await request(server)
      .post('/auth/register')
      .send({ email: `sync-${Date.now()}@lkey.test`, password: 'password123' })
      .expect(201);
    accessToken = registered.body.accessToken;
  });

  it('adding the same favorite twice is idempotent, and listing/removing works', async () => {
    const server = app.getHttpServer();
    const auth = { Authorization: `Bearer ${accessToken}` };

    const first = await request(server)
      .post('/sync/favorites')
      .set(auth)
      .send({ targetType: 'SONG', targetId: 'song-1' })
      .expect(201);

    const second = await request(server)
      .post('/sync/favorites')
      .set(auth)
      .send({ targetType: 'SONG', targetId: 'song-1' })
      .expect(201);
    expect(second.body.id).toBe(first.body.id);

    const list = await request(server)
      .get('/sync/favorites')
      .set(auth)
      .expect(200);
    expect(list.body).toHaveLength(1);

    await request(server)
      .delete('/sync/favorites/SONG/song-1')
      .set(auth)
      .expect(204);

    // Removing an already-removed favorite is still a no-op success.
    await request(server)
      .delete('/sync/favorites/SONG/song-1')
      .set(auth)
      .expect(204);

    const listAfterRemove = await request(server)
      .get('/sync/favorites')
      .set(auth)
      .expect(200);
    expect(listAfterRemove.body).toHaveLength(0);
  });

  it('round-trips preferences as a whole-row replace', async () => {
    const server = app.getHttpServer();
    const auth = { Authorization: `Bearer ${accessToken}` };

    const defaults = await request(server)
      .get('/sync/preferences')
      .set(auth)
      .expect(200);
    expect(defaults.body.themeMode).toBe('SYSTEM');
    expect(defaults.body.referencePitchHz).toBe(440);

    const updated = await request(server)
      .put('/sync/preferences')
      .set(auth)
      .send({ locale: 'my', themeMode: 'DARK', referencePitchHz: 442 })
      .expect(200);
    expect(updated.body).toEqual({
      locale: 'my',
      themeMode: 'DARK',
      referencePitchHz: 442,
    });

    const fetched = await request(server)
      .get('/sync/preferences')
      .set(auth)
      .expect(200);
    expect(fetched.body).toEqual(updated.body);

    // Out of the tuner's offered reference range (415-445).
    await request(server)
      .put('/sync/preferences')
      .set(auth)
      .send({ themeMode: 'LIGHT', referencePitchHz: 500 })
      .expect(400);
  });

  it('requires authentication for every sync route', async () => {
    const server = app.getHttpServer();
    await request(server).get('/sync/favorites').expect(401);
    await request(server).get('/sync/preferences').expect(401);
  });
});
