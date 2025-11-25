import { type RouteConfig, index, route } from '@react-router/dev/routes';

export default [
  index('routes/home.tsx'),
  route('api', 'routes/api.tsx'),
  route('resources', 'routes/resources/resources.tsx'),
  route('/users/sign_up', 'routes/signup/signup.tsx'),
  route('/users/sign_in', 'routes/signin/signin.tsx'),
] satisfies RouteConfig;
