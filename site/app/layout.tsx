import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'GiroCall',
  description: 'Spin the Giro. Make the Call. Stay Connected.',
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body style={{ fontFamily: 'system-ui, sans-serif', margin: 0, padding: '2rem' }}>
        {children}
      </body>
    </html>
  );
}