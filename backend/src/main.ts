import { loadEnv } from './config/env.schema';

// Validate — and, in local dev, load backend/.env into process.env — before
// anything else runs. This must happen before `AppModule` is imported: its
// `ConfigModule.forRoot()` call reads process.env synchronously the moment
// the module is loaded, via its own dotenv parsing (which mishandles a
// secret containing `$`, unlike this project's own loader). A static
// `import './bootstrap'` would be hoisted above this line by TypeScript
// regardless of source order, so the module is loaded dynamically instead,
// deferring it until this line has actually run.
loadEnv();

void import('./bootstrap').then(({ bootstrap }) => bootstrap());
