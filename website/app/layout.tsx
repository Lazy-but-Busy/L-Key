import type { Metadata, Viewport } from 'next';

import './globals.css';

export const metadata: Metadata = {
  title: 'L Key — Everything Your Guitar Needs',
  description:
    'Tune, learn, practise and play. A Myanmar-first guitar companion for iOS and Android.',
};

// The design review found the marketing kit pinned to 1280px with no viewport
// meta, so the site selling a mobile app did not work on a phone. Both are
// fixed here at the root.
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
