import type { ElysiaOpenAPIConfig } from "@elysiajs/openapi";
import { openapi } from "@elysiajs/openapi";
import { cors } from "@elysiajs/cors";
import { Elysia } from "elysia";
import { CloudflareAdapter } from "elysia/adapter/cloudflare-worker";
import { database } from "./ctx/database";
import { cfBindings } from "~/ctx/cf-bindings";
import { betterAuth } from "~/ctx/better-auth";
import { OpenAPI } from "./lib/auth";
import { openApiSecuritySchemes, openApiTags } from "~/lib/openapi";
import {
  attachResponseLog,
  beginRequestLog,
  completeRequestLog,
  logRequestError,
} from "~/lib/runtime-logging";
import { apiRoutes } from "~/routes";

type AppOpenAPIConfig = Partial<ElysiaOpenAPIConfig<boolean, string>>;

type AppOptions = {
  openapiConfig?: false | AppOpenAPIConfig;
};

const defaultOpenAPIConfig = {
  provider: "scalar",
} satisfies AppOpenAPIConfig;

export const createApp = async ({ openapiConfig = defaultOpenAPIConfig }: AppOptions = {}) => {
  let app = new Elysia({
    adapter: CloudflareAdapter,
  })
    .onRequest((ctx: any) => {
      beginRequestLog(ctx);
    })
    .onAfterHandle((ctx: any) => {
      attachResponseLog(ctx, ctx.response ?? null);
    })
    .onError((ctx: any) => {
      logRequestError(ctx, ctx.error, ctx.code);
    })
    .onAfterResponse((ctx: any) => {
      completeRequestLog(ctx);
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
    .use(apiRoutes);

  if (openapiConfig !== false) {
    const authComponents = await OpenAPI.components;

    app = app.use(
      openapi({
        ...openapiConfig,
        documentation: {
          ...(openapiConfig.documentation ?? {}),
          info: {
            title: "Cargo API",
            version: "1.0.0",
            description:
              "Customer-facing and operational cargo API. The OpenAPI spec documents two bearer token contexts: customer bearer tokens for customer accounts, and staff/admin bearer tokens for admin, china_staff, and mongolia_staff accounts.",
          },
          tags: openApiTags,
          components: {
            ...authComponents,
            securitySchemes: {
              ...(authComponents?.securitySchemes ?? {}),
              ...openApiSecuritySchemes,
            },
          },
          paths: await OpenAPI.getPaths(),
        },
      })
    );
  }

  return app.get("/", () => "Hello, Elysia on Cloudflare Workers!").compile();
};
