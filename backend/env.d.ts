import "cloudflare:workers";
import "elysia";

type CloudflareBindings = {
  DB: D1Database;
  BUCKET: R2Bucket;
  CACHE: KVNamespace;
};

declare module "cloudflare:workers" {
  interface Env extends CloudflareBindings {}
}

declare module "elysia" {
  interface Context {
    cf: {
      env: CloudflareBindings;
      bindings: CloudflareBindings;
    };
  }
}

export {};
