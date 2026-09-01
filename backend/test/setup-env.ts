import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

/**
 * Loads `backend/.env` for a local `npm run test:e2e`, without overriding
 * anything already set (CI sets DATABASE_URL/JWT_SECRET directly as job
 * env, so this is a no-op there). Deliberately minimal — no `dotenv`
 * dependency for four KEY=VALUE lines. Resolved from the working directory
 * (npm always runs package scripts with `backend/` as cwd) rather than
 * `__dirname`, which ESM modules don't have.
 */
const envPath = join(process.cwd(), '.env');
if (existsSync(envPath)) {
  for (const line of readFileSync(envPath, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim();
    if (!(key in process.env)) process.env[key] = value;
  }
}
