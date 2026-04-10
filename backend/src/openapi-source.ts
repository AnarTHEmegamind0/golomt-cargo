import { cors } from "@elysiajs/cors";
import { Elysia } from "elysia";
import { CloudflareAdapter } from "elysia/adapter/cloudflare-worker";
import { database } from "./ctx/database";
import { cfBindings } from "~/ctx/cf-bindings";
import { betterAuth } from "~/ctx/better-auth";
import { apiRoutes } from "~/routes";

export const openapiSourceApp = new Elysia({
  adapter: CloudflareAdapter,
})
  .use(
    cors({
      origin: "*",
      methods: ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
      credentials: true,
      allowedHeaders: ["Content-Type", "Authorization"],
    })
  )
  .use(cfBindings)
  .use(betterAuth)
  .use(database)
  .use(apiRoutes)
  .get("/", () => "Hello from cargo-back CI deploy test v2.");
