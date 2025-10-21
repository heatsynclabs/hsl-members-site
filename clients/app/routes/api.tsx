import type { Route } from "./+types/api";

export function loader() {
  return { text: "butt" };
}

export async function action({ request }: Route.ActionArgs) {
  let formData = await request.formData();
  let text = formData.get("text");
  return { text, yes: true, num: 1 };
}
