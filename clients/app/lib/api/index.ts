import createClient from 'openapi-fetch';
import type { paths } from './generated';

export const client = createClient<paths>({
  baseUrl: 'https://tiger.atnnn.com/',
});

// This is a client demo. Remove when succesfully demoed.
console.error('API server health:', await client.GET('/v1/health'));
