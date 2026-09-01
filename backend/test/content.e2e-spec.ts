import { INestApplication } from '@nestjs/common';
import { AdminRole } from '@prisma/client';
import request from 'supertest';

import { PrismaService } from '../src/common/prisma/prisma.service';
import { resetDatabase } from './utils/db-reset';
import { createTestApp } from './utils/test-app';

describe('Content (e2e)', () => {
  let app: INestApplication;
  let editorToken: string;

  beforeAll(async () => {
    app = await createTestApp();
  });

  afterEach(async () => {
    await resetDatabase(app);
  });

  afterAll(async () => {
    await app.close();
  });

  async function asEditor(email: string): Promise<string> {
    const server = app.getHttpServer();
    await request(server)
      .post('/auth/register')
      .send({ email, password: 'password123' })
      .expect(201);
    await app.get(PrismaService).user.update({
      where: { email },
      data: { adminRole: AdminRole.EDITOR },
    });
    const loggedIn = await request(server)
      .post('/auth/login')
      .send({ email, password: 'password123' })
      .expect(201);
    return loggedIn.body.accessToken;
  }

  beforeEach(async () => {
    editorToken = await asEditor(`editor-${Date.now()}@lkey.test`);
  });

  it('walks a song through draft -> public-hidden -> published -> public-visible -> archived', async () => {
    const server = app.getHttpServer();

    const created = await request(server)
      .post('/songs')
      .set('Authorization', `Bearer ${editorToken}`)
      .send({
        title: 'Amazing Grace',
        artist: 'Traditional',
        language: 'ENGLISH',
        key: 'G',
        bpm: 80,
        difficulty: 'BEGINNER',
        genre: 'Worship',
        sections: [{ name: 'Verse 1', lines: ['Amazing grace'] }],
        lyrics: 'Amazing grace how sweet the sound',
        chords: ['G', 'C', 'D'],
      })
      .expect(201);
    expect(created.body.status).toBe('DRAFT');
    const id = created.body.id;

    // A draft never appears in the public list, and 404s by id rather than
    // exposing its existence with a 403.
    const publicList = await request(server).get('/songs').expect(200);
    expect(publicList.body.items).toHaveLength(0);
    await request(server).get(`/songs/${id}`).expect(404);

    // An editor can still see it.
    await request(server)
      .get(`/songs/${id}`)
      .set('Authorization', `Bearer ${editorToken}`)
      .expect(200);

    await request(server)
      .post(`/songs/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'IN_REVIEW' })
      .expect(201);

    await request(server)
      .post(`/songs/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'PUBLISHED' })
      .expect(201);

    const publicListAfterPublish = await request(server)
      .get('/songs')
      .expect(200);
    expect(publicListAfterPublish.body.items).toHaveLength(1);
    await request(server).get(`/songs/${id}`).expect(200);

    // Archiving is a status transition, never a row deletion.
    await request(server)
      .post(`/songs/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'ARCHIVED' })
      .expect(201);
    await request(server).get(`/songs/${id}`).expect(404);
    await request(server)
      .get(`/songs/${id}`)
      .set('Authorization', `Bearer ${editorToken}`)
      .expect(200)
      .expect((res) => expect(res.body.status).toBe('ARCHIVED'));

    // An invalid transition (ARCHIVED is terminal) is rejected.
    await request(server)
      .post(`/songs/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'PUBLISHED' })
      .expect(400);
  });

  it('walks a chord through the same draft -> published lifecycle', async () => {
    const server = app.getHttpServer();

    const created = await request(server)
      .post('/chords')
      .set('Authorization', `Bearer ${editorToken}`)
      .send({
        name: 'Cmaj7',
        root: 'C',
        quality: 'maj7',
        formula: ['1', '3', '5', '7'],
        voicings: [{ tuning: 'standard', frets: [0, 3, 2, 0, 0, 0] }],
      })
      .expect(201);
    const id = created.body.id;

    await request(server).get('/chords').expect(200).expect((res) => {
      expect(res.body.items).toHaveLength(0);
    });

    await request(server)
      .post(`/chords/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'IN_REVIEW' })
      .expect(201);
    await request(server)
      .post(`/chords/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'PUBLISHED' })
      .expect(201);

    await request(server).get('/chords').expect(200).expect((res) => {
      expect(res.body.items).toHaveLength(1);
    });
  });

  it('walks a scale through the same draft -> published lifecycle', async () => {
    const server = app.getHttpServer();

    const created = await request(server)
      .post('/scales')
      .set('Authorization', `Bearer ${editorToken}`)
      .send({
        name: 'Major Pentatonic',
        category: 'pentatonic',
        formula: ['1', '2', '3', '5', '6'],
        patterns: [{ box: 1, positions: [] }],
      })
      .expect(201);
    const id = created.body.id;

    await request(server)
      .post(`/scales/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'IN_REVIEW' })
      .expect(201);
    await request(server)
      .post(`/scales/${id}/status`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ status: 'PUBLISHED' })
      .expect(201);

    await request(server).get('/scales').expect(200).expect((res) => {
      expect(res.body.items).toHaveLength(1);
    });
  });
});
