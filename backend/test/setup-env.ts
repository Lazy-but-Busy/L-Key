import { loadDotenv } from '../src/config/load-dotenv';

/**
 * Loads `backend/.env` for a local `npm run test:e2e`, without overriding
 * anything already set (CI sets DATABASE_URL/JWT_SECRET directly as job
 * env, so this is a no-op there). Resolved from the working directory (npm
 * always runs package scripts with `backend/` as cwd) rather than
 * `__dirname`, which ESM modules don't have.
 */
loadDotenv();
