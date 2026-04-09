type LogLevel = "info" | "warn" | "error";

type RuntimeLogState = {
  requestId: string;
  startTime: number;
  completed?: boolean;
  request?: Record<string, unknown>;
  response?: Record<string, unknown>;
};

const runtimeLogKey = "__runtimeLog";
const maxStringLength = 2000;
const maxObjectEntries = 40;
const sensitiveKeyPattern =
  /password|token|authorization|cookie|secret|key|credential|bearer|session/i;

const getLogState = (ctx: any): RuntimeLogState | undefined => ctx?.[runtimeLogKey];

const setLogState = (ctx: any, state: RuntimeLogState) => {
  ctx[runtimeLogKey] = state;
  return state;
};

const getStatusCode = (ctx: any) => {
  const status = ctx?.set?.status;

  if (typeof status === "number") return status;
  if (typeof ctx?.response?.status === "number") return ctx.response.status;

  return 200;
};

const getPathname = (request: Request) => {
  try {
    return new URL(request.url).pathname;
  } catch {
    return request.url;
  }
};

const getQuerySnapshot = (request: Request) => {
  try {
    const url = new URL(request.url);
    const query = Object.fromEntries(url.searchParams.entries());
    return sanitizeValue(query);
  } catch {
    return {};
  }
};

const sanitizeValue = (value: unknown, keyHint?: string, depth = 0): unknown => {
  if (value == null) return value;

  if (keyHint && sensitiveKeyPattern.test(keyHint)) {
    return "[REDACTED]";
  }

  if (depth > 4) {
    return "[MAX_DEPTH]";
  }

  if (typeof value === "string") {
    if (sensitiveKeyPattern.test(keyHint ?? "")) {
      return "[REDACTED]";
    }
    return value.length > maxStringLength
      ? `${value.slice(0, maxStringLength)}...[truncated ${value.length - maxStringLength} chars]`
      : value;
  }

  if (
    typeof value === "number" ||
    typeof value === "boolean" ||
    typeof value === "bigint"
  ) {
    return value;
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  if (Array.isArray(value)) {
    return value.slice(0, maxObjectEntries).map((item) => sanitizeValue(item, undefined, depth + 1));
  }

  if (value instanceof Uint8Array) {
    return `[Uint8Array length=${value.length}]`;
  }

  if (typeof FormData !== "undefined" && value instanceof FormData) {
    const formEntries: Record<string, unknown> = {};
    let count = 0;
    for (const [key, formValue] of value.entries()) {
      if (count >= maxObjectEntries) {
        formEntries.__truncated__ = true;
        break;
      }
      formEntries[key] =
        typeof formValue === "string"
          ? sanitizeValue(formValue, key, depth + 1)
          : `[${Object.prototype.toString.call(formValue).slice(8, -1) || "Blob"}]`;
      count++;
    }
    return formEntries;
  }

  if (typeof value === "object") {
    const entries = Object.entries(value as Record<string, unknown>);
    const sanitized: Record<string, unknown> = {};
    for (const [index, [key, nested]] of entries.entries()) {
      if (index >= maxObjectEntries) {
        sanitized.__truncated__ = true;
        break;
      }
      sanitized[key] = sanitizeValue(nested, key, depth + 1);
    }
    return sanitized;
  }

  return String(value);
};

const serializeForLog = (value: unknown) => {
  try {
    return sanitizeValue(value);
  } catch (error) {
    return `[UNSERIALIZABLE: ${error instanceof Error ? error.message : String(error)}]`;
  }
};

const getHeaderSnapshot = (request: Request) => {
  const authorization = request.headers.get("authorization");
  const cookie = request.headers.get("cookie");

  return {
    origin: request.headers.get("origin"),
    userAgent: request.headers.get("user-agent"),
    cfRay: request.headers.get("cf-ray"),
    hasAuthorization: Boolean(authorization),
    authorizationPreview: authorization ? `${authorization.slice(0, 20)}...` : null,
    hasCookie: Boolean(cookie),
    cookiePreview: cookie ? `${cookie.slice(0, 20)}...` : null,
    contentType: request.headers.get("content-type"),
  };
};

const getAuthSnapshot = (ctx: any) => ({
  authUserId: ctx.authUser?.id ?? ctx.user?.id ?? null,
  authRole: ctx.authUser?.role ?? ctx.user?.role ?? null,
});

const getRequestSnapshot = (ctx: any) => ({
  method: ctx.request.method,
  path: getPathname(ctx.request),
  query: getQuerySnapshot(ctx.request),
  params: serializeForLog(ctx.params ?? null),
  body: serializeForLog(ctx.body ?? null),
  headers: getHeaderSnapshot(ctx.request),
  ...getAuthSnapshot(ctx),
});

const getResponseSnapshot = (ctx: any, response?: unknown) => ({
  status: getStatusCode(ctx),
  headers: serializeForLog(ctx.set?.headers ?? null),
  body: serializeForLog(response),
});

const writeLog = (level: LogLevel, payload: Record<string, unknown>) => {
  const line = JSON.stringify({
    timestamp: new Date().toISOString(),
    level,
    ...payload,
  });

  if (level === "error") {
    console.error(line);
    return;
  }

  if (level === "warn") {
    console.warn(line);
    return;
  }

  console.info(line);
};

export const beginRequestLog = (ctx: any) => {
  const requestId = ctx.request.headers.get("x-request-id") ?? crypto.randomUUID();

  setLogState(ctx, {
    requestId,
    startTime: Date.now(),
  });

  ctx.set.headers["x-request-id"] = requestId;

  writeLog("info", {
    event: "request.start",
    requestId,
    ...getRequestSnapshot(ctx),
  });
};

export const attachResponseLog = (ctx: any, response: unknown) => {
  const state = getLogState(ctx);
  if (!state) return;
  state.request = getRequestSnapshot(ctx);
  state.response = getResponseSnapshot(ctx, response);
};

export const logAuthFailure = (
  ctx: any,
  input: {
    status: 401 | 403;
    reason: string;
    requiredRoles?: string[];
    resolvedRole?: string | null;
    userId?: string | null;
  },
) => {
  const state = getLogState(ctx);

  writeLog("warn", {
    event: "auth.denied",
    requestId: state?.requestId ?? null,
    ...getRequestSnapshot(ctx),
    status: input.status,
    reason: input.reason,
    requiredRoles: input.requiredRoles ?? [],
    resolvedRole: input.resolvedRole ?? null,
    userId: input.userId ?? null,
  });
};

export const logRequestError = (ctx: any, error: unknown, code?: string) => {
  const state = getLogState(ctx);
  const err = error instanceof Error ? error : new Error(String(error));

  writeLog("error", {
    event: "request.error",
    requestId: state?.requestId ?? null,
    ...getRequestSnapshot(ctx),
    response: state?.response ?? getResponseSnapshot(ctx, ctx.error?.message ?? null),
    status: getStatusCode(ctx),
    code: code ?? null,
    errorName: err.name,
    message: err.message,
    stack: err.stack ?? null,
    cause: serializeForLog((err as any).cause ?? null),
  });
};

export const completeRequestLog = (ctx: any) => {
  const state = getLogState(ctx);
  if (!state || state.completed) return;

  state.completed = true;

  writeLog("info", {
    event: "request.complete",
    requestId: state.requestId,
    durationMs: Date.now() - state.startTime,
    ...(state.request ?? getRequestSnapshot(ctx)),
    response: state.response ?? getResponseSnapshot(ctx, null),
  });
};
