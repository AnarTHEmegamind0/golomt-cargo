import { drizzle } from "drizzle-orm/d1";
import { env } from "~/lib/platform/env";
import * as schema from "~/db/schema";

export const db = drizzle(env.DB, {
  schema,
});
