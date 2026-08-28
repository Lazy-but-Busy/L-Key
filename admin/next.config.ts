import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  reactStrictMode: true,
  // The design tokens are a workspace package of plain CSS and TS.
  transpilePackages: ['@lkey/design-tokens'],
};

export default nextConfig;
