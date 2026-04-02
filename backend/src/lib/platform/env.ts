import type { Env } from "cloudflare:workers";

const nullAsync = async () => null;
const voidAsync = async () => {};

const fallbackEnv = {
  DB: {} as D1Database,
  BUCKET: {
    head: nullAsync,
    get: nullAsync,
    put: voidAsync,
    delete: voidAsync,
    list: async () => ({ objects: [], truncated: false }),
    createMultipartUpload: async () =>
      ({
        uploadPart: voidAsync,
        abort: voidAsync,
        complete: async () => ({}) as any,
      }) as any,
    resumeMultipartUpload: () =>
      ({
        uploadPart: voidAsync,
        abort: voidAsync,
        complete: async () => ({}) as any,
      }) as any,
  } as unknown as R2Bucket,
  CACHE: {
    get: nullAsync,
    getWithMetadata: async () => null,
    put: voidAsync,
    delete: voidAsync,
    list: async () => ({ keys: [], list_complete: true, cursor: "" }),
  } as unknown as KVNamespace,
} satisfies Env;

const cloudflareModule = await import("cloudflare:workers").catch(() => null);

export const env = cloudflareModule?.env ?? fallbackEnv;
