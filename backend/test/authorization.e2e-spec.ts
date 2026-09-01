import { INestApplication } from '@nestjs/common';
import { AdminRole } from '@prisma/client';
import request from 'supertest';

import { PrismaService } from '../src/common/prisma/prisma.service';
import { resetDatabase } from './utils/db-reset';
import { createTestApp } from './utils/test-app';

describe('Authorization (e2e)', () => {
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

  async function registerAndLogin(email: string) {
    const server = app.getHttpServer();
    const res = await request(server)
      .post('/auth/register')
      .send({ email, password: 'password123' })
      .expect(201);
    return res.body.accessToken as string;
  }

  const newSong = {
    title: 'Test Song',
    artist: 'Someone',
    language: 'ENGLISH',
    key: 'C',
    bpm: 100,
    difficulty: 'BEGINNER',
    genre: 'Pop',
    sections: [],
    lyrics: 'la la la',
    chords: [],
  };

  it('rejects a plain registered user writing content (403)', async () => {
    const accessToken = await registerAndLogin('plain@lkey.test');

    await request(app.getHttpServer())
      .post('/songs')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(newSong)
      .expect(403);
  });

  it('allows a user with the EDITOR role to write content', async () => {
    const email = 'editor@lkey.test';
    let accessToken = await registerAndLogin(email);

    const prisma = app.get(PrismaService);
    await prisma.user.update({
      where: { email },
      data: { adminRole: AdminRole.EDITOR },
    });

    // The access token issued before the role change carries the old (no)
    // role; log in again so the token reflects the updated role.
    const loggedIn = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email, password: 'password123' })
      .expect(201);
    accessToken = loggedIn.body.accessToken;

    await request(app.getHttpServer())
      .post('/songs')
      .set('Authorization', `Bearer ${accessToken}`)
      .send(newSong)
      .expect(201);
  });

  it('rejects an unauthenticated request to a protected sync route (401)', async () => {
    await request(app.getHttpServer()).get('/sync/favorites').expect(401);
  });
});
