import { type RouteConfig, index, route } from "@react-router/dev/routes";

export default [
  index("routes/home.tsx"),
  route('resources', 'routes/resources/resources.tsx')
] satisfies RouteConfig;
