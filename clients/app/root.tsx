import { Outlet } from 'react-router';
import type { Route } from './+types/root';
import './styles.css';

export default function App() {
  return <Outlet />;
}

export { Layout } from '~/Layout';

export { ErrorBoundary } from '~/ErrorBoundary';

export const links: Route.LinksFunction = () => [
  {
    rel: 'icon',
    href: '/favicon.svg',
    type: 'image/svg+xml',
  },
  { rel: 'preconnect', href: 'https://fonts.googleapis.com' },
  {
    rel: 'preconnect',
    href: 'https://fonts.gstatic.com',
    crossOrigin: 'anonymous',
  },
  {
    rel: 'stylesheet',
    href: 'https://fonts.googleapis.com/css2?family=Radio+Canada+Big:ital,wght@0,400..700;1,400..700&display=swap',
  },
];
