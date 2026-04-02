# cargo-back

A modern, type-safe starter template for building APIs with [Elysia.js](https://elysiajs.com) on [Cloudflare Workers](https://workers.cloudflare.com/), featuring [Drizzle ORM](https://orm.drizzle.team/) with Cloudflare D1 and [Better Auth](https://www.better-auth.com/) for authentication.

## ✨ Features

- ⚡ **Elysia.js** - Fast, type-safe web framework
- 🌐 **Cloudflare Workers** - Edge-first serverless deployment
- 🗃️ **Drizzle ORM** - Type-safe SQL with Cloudflare D1
- 🔐 **Better Auth** - Modern authentication with email/password
- 🪣 **R2 + KV Bindings** - Built-in object storage and key-value cache access
- 📖 **OpenAPI** - Auto-generated API documentation
- 🔒 **CORS** - Pre-configured cross-origin support

## 📋 Prerequisites

- [Bun](https://bun.sh) (v1.0+)
- [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/)
- A Cloudflare account with D1, R2, and KV resources

## 🚀 Getting Started

### 1. Install dependencies

```bash
bun install
```

### 2. Configure environment variables

Copy the example environment file and fill in your values:

```bash
cp .dev.examples .dev.vars
```

Edit `.dev.vars` with your credentials:

```env
BETTER_AUTH_SECRET=your-secure-secret-key
CLOUDFLARE_ACCOUNT_ID=your-account-id
CLOUDFLARE_DATABASE_ID=your-d1-database-id
CLOUDFLARE_D1_TOKEN=your-cloudflare-api-token
```

Then update `wrangler.jsonc` with your real resource IDs for `DB`, `BUCKET`, and `CACHE`.

### 3. Generate Cloudflare types

```bash
bun run cf-types
```

### 4. Set up the database

Generate and run migrations:

```bash
bun run db:generate
bun run db:migrate
```

To apply migrations to your remote D1 database:

```bash
bun run db:migrate:remote
```

### 5. Start development server

```bash
bun run dev
```

Your API will be available at `http://localhost:8787`

## 📜 Available Scripts

| Script                | Description                      |
| --------------------- | -------------------------------- |
| `bun run dev`         | Start local development server   |
| `bun run deploy`      | Deploy to Cloudflare Workers     |
| `bun run openapi:generate` | Generate and save OpenAPI JSON |
| `bun run openapi:sync` | Alias for OpenAPI generation      |
| `bun run db:generate` | Generate Drizzle migrations      |
| `bun run db:migrate`  | Apply D1 migrations (local)      |
| `bun run db:migrate:remote` | Apply D1 migrations (remote) |
| `bun run db:studio`   | Open Drizzle Studio GUI          |
| `bun run cf-types`    | Generate Cloudflare Worker types |

## 📁 Project Structure

```
├── src/
│   ├── index.ts          # Main application entry
│   ├── ctx/
│   │   ├── better-auth.ts # Auth plugin & middleware
│   │   ├── cf-bindings.ts  # Cloudflare bindings context
│   │   └── database.ts    # Database context
│   ├── db/
│   │   ├── index.ts        # Drizzle client setup
│   │   └── schema/         # Database schema modules
│   ├── routes/
│   │   ├── index.ts        # API route composition
│   │   ├── cargos/         # Cargo workflow routes
│   │   ├── payments/       # Payment routes
│   │   └── branches/       # Branch routes
│   └── lib/
│       ├── auth.ts         # Better Auth configuration
│       ├── schemas/        # drizzle-valibot request schemas
│       └── constants/      # app constants and enums
├── .github/
│   └── workflows/
│       └── deploy-worker.yml # CI deploy to Cloudflare
├── public/                # Static assets
├── drizzle/
│   └── migrations/        # Database migrations
├── drizzle.config.ts      # Drizzle Kit configuration
├── env.d.ts               # Env and context type augmentation
├── wrangler.jsonc         # Cloudflare Workers config & bindings
└── worker-configuration.d.ts # Generated CF types
```

## 🔐 Authentication

This starter includes Better Auth with email/password authentication. Available endpoints:

- `POST /auth/sign-up` - Register a new user
- `POST /auth/sign-in` - Sign in with credentials
- `POST /auth/sign-out` - Sign out
- `GET /auth/session` - Get current session

### Protected Routes

Use the `auth` macro to protect routes:

```typescript
app.get(
  "/protected",
  ({ user }) => {
    return `Hello, ${user.name}!`;
  },
  {
    auth: true,
  }
);
```

## 📖 API Documentation

OpenAPI documentation can be generated locally and shipped as a static asset at `/openapi.json`.

## 🚢 Deployment

Deploy to Cloudflare Workers:

```bash
bun run deploy
```

> **Note:** Make sure to set your environment variables in the Cloudflare dashboard or using `wrangler secret put`.

### GitHub Actions Deploy

Automatic deployment runs on push to `master` via `.github/workflows/deploy-worker.yml`.
Add these repository secrets:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

### OpenAPI Spec Generation

To generate the OpenAPI JSON locally with `fromTypes()`:

```bash
bun run openapi:generate
```

It writes to `public/openapi.json` by default, which Cloudflare Workers ships as a static asset.

You can override the output file if needed:

```bash
OPENAPI_OUTPUT=openapi/openapi.json bun run openapi:generate
```

## 📄 License

[MIT](https://github.com/trickrenzgarcia/elysia-cf-starter/blob/master/LICENSE)
