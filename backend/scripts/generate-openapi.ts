import { mkdir, writeFile } from "node:fs/promises";
import { fromTypes } from "@elysiajs/openapi";
import { createApp } from "~/app";

const outPath = process.env.OPENAPI_OUTPUT || "public/openapi.json";
const targetFilePath = process.env.OPENAPI_TARGET || "src/openapi-source.ts";
const instanceName = process.env.OPENAPI_INSTANCE || "openapiSourceApp";

const app = await createApp({
  openapiConfig: {
    provider: null,
    path: "/openapi",
    specPath: "/openapi/json",
    references: fromTypes(targetFilePath, {
      instanceName,
      tsconfigPath: "tsconfig.json",
      silent: true,
    }),
  },
});

const response = await app.handle(new Request("http://openapi.local/openapi/json"));

if (!response.ok) {
  throw new Error(`Failed to generate OpenAPI schema (${response.status})`);
}

const schema = await response.json();
const outDir = outPath.includes("/") ? outPath.slice(0, outPath.lastIndexOf("/")) : ".";

await mkdir(outDir, { recursive: true });
await writeFile(outPath, JSON.stringify(schema, null, 2) + "\n", "utf8");

console.log(`Saved generated OpenAPI schema to ${outPath}`);
