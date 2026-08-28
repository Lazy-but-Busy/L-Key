import { defineConfig, env } from 'prisma/config';

/**
 * Prisma CLI configuration.
 *
 * Prisma 7 removed `url` from the schema's datasource block, so migration and
 * introspection commands read the connection string from here instead. This
 * file is CLI-only — it is never bundled into the running application, and
 * the URL is still supplied by the environment rather than committed.
 */
export default defineConfig({
  schema: 'prisma/schema.prisma',
  datasource: {
    url: env('DATABASE_URL'),
  },
});
