type LogLevel = "info" | "warn" | "error";

type RuntimeLogState = {
  requestId: string;
  startTime: number;
  completed?: boolean;
};

const runtimeLogKey = "__runtimeLog";

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

const getHeaderSnapshot = (request: Request) => ({
  origin: request.headers.get("origin"),
  userAgent: request.headers.get("user-agent"),
  cfRay: request.headers.get("cf-ray"),
  hasAuthorization: Boolean(request.headers.get("authorization")),
  hasCookie: Boolean(request.headers.get("cookie")),
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
    method: ctx.request.method,
    path: getPathname(ctx.request),
    headers: getHeaderSnapshot(ctx.request),
  });
};

export const logAuthFailure = (ctx: any, input: {
  status: 401 | 403;
  reason: string;
  requiredRoles?: string[];
  resolvedRole?: string | null;
  userId?: string | null;
}) => {
  const state = getLogState(ctx);

  writeLog("warn", {
    event: "auth.denied",
    requestId: state?.requestId ?? null,
    method: ctx.request.method,
    path: getPathname(ctx.request),
    status: input.status,
    reason: input.reason,
    requiredRoles: input.requiredRoles ?? [],
    resolvedRole: input.resolvedRole ?? null,
    userId: input.userId ?? null,
    headers: getHeaderSnapshot(ctx.request),
  });
};

export const logRequestError = (ctx: any, error: unknown, code?: string) => {
  const state = getLogState(ctx);
  const err = error instanceof Error ? error : new Error(String(error));

  writeLog("error", {
    event: "request.error",
    requestId: state?.requestId ?? null,
    method: ctx.request.method,
    path: getPathname(ctx.request),
    status: getStatusCode(ctx),
    code: code ?? null,
    errorName: err.name,
    message: err.message,
    stack: err.stack ?? null,
  });
};

export const completeRequestLog = (ctx: any) => {
  const state = getLogState(ctx);
  if (!state || state.completed) return;

  state.completed = true;

  writeLog("info", {
    event: "request.complete",
    requestId: state.requestId,
    method: ctx.request.method,
    path: getPathname(ctx.request),
    status: getStatusCode(ctx),
    durationMs: Date.now() - state.startTime,
    authUserId: ctx.authUser?.id ?? ctx.user?.id ?? null,
    authRole: ctx.authUser?.role ?? ctx.user?.role ?? null,
  });
};
