import { existsSync, readFileSync } from 'node:fs';
import { join } from 'node:path';

/**
 * Minimal `.env` loader: sets `process.env` from a dotenv-format file if one
 * exists, without overriding anything already set (so real deployment
 * environment variables always win over a stray local `.env`). No `dotenv`
 * dependency for four KEY=VALUE lines — and safe for secrets containing
 * shell metacharacters, unlike `source .env`.
 */
export function loadDotenv(path: string = join(process.cwd(), '.env')): void {
  if (!existsSync(path)) return;

  for (const line of readFileSync(path, 'utf8').split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq === -1) continue;
    const key = trimmed.slice(0, eq).trim();
    const value = trimmed.slice(eq + 1).trim();
    if (!(key in process.env)) process.env[key] = value;
  }
}
