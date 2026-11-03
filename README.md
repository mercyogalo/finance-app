# Hifadhi

Hifadhi is a mobile savings app that protects people from their own spending habits. Deposits come in through M-Pesa, funds are held in escrow on Stellar, and an agent decides when and how much can be withdrawn.

This repository is a monorepo. The foundation is in place: a typed API, a Flutter app shell with the design system, Docker, and CI. Feature flows (auth, goals, deposits, withdrawals, the agent) are added on the `develop` branch one task at a time.

The product name lives in one place on each side: `AppStrings.appName` in the app, and the `hifadhi-api` package name on the server.

## Layout

| Path | What it is |
| --- | --- |
| `backend/` | Node.js, TypeScript, Express, MongoDB (Mongoose) |
| `mobile/` | Flutter app (Riverpod, go_router, Dio) |
| `.github/workflows/ci.yml` | Backend and mobile checks |

Do not use Supabase or Firebase. Configuration comes only from environment variables validated at startup.

## Prerequisites

- Node.js 22 or newer (CI and the Docker image use Node 24)
- npm
- Docker, if you want to run the API and MongoDB together
- Flutter stable, for the mobile app

## Backend

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

The API listens on `http://127.0.0.1:3000` by default.

| Check | Command |
| --- | --- |
| Lint | `npm run lint` |
| Types | `npm run typecheck` |
| Tests | `npm test` |
| Production build | `npm run build` |

### HTTP

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/health` | Liveness. Does not touch the database. |
| `GET` | `/ready` | Readiness. Pings MongoDB. `503` when the database is down. |

Errors always use this JSON shape:

```json
{ "error": { "code": "NOT_FOUND", "message": "Route not found: GET /missing" } }
```

Every response includes an `x-request-id` header. Send one to keep your own id; otherwise the API generates one.

### Docker

From `backend/`:

```bash
docker compose up --build
```

That starts the API and MongoDB 7. The API image is a multi-stage build. Compose points `MONGODB_URI` at the `mongo` service. Readiness is `GET /ready`.

Run only one API process. Scheduled jobs use `node-cron` inside that process, and the rate limiter keeps its counters in memory. A second instance would run the same jobs twice.

### Configuration

Copy `backend/.env.example` to `backend/.env`. The process refuses to start when a required value is missing or a switch is not one of the allowed values. Never commit `.env`.

| Variable | Required | Default | Purpose |
| --- | --- | --- | --- |
| `MONGODB_URI` | yes | | `mongodb://` or `mongodb+srv://` connection string |
| `CORS_ORIGINS` | yes | | Comma-separated absolute `http(s)` origins. Requests with no `Origin` header (the mobile app, curl) are allowed. |
| `NODE_ENV` | no | `development` | `development`, `test`, or `production` |
| `PORT` | no | `3000` | HTTP port |
| `HOST` | no | `0.0.0.0` | Bind address |
| `LOG_LEVEL` | no | `info` | Pino level, including `silent` |
| `RATE_LIMIT_WINDOW_MS` | no | `900000` | Rate-limit window. `/health` and `/ready` are not counted. |
| `RATE_LIMIT_MAX` | no | `100` | Max requests per window per client |

Money is stored as integer cents (`1 KES = 100`). Do not use floating point for amounts. `assertKesCents` rejects anything that is not a non-negative safe integer.

Logs redact authorization headers, cookies, and fields named like `pin`, `otp`, `password`, `secret`, `token`, and `phone`.

### Switches

These are validated on boot. Later tasks wire each one to a real provider. Until then they are loaded, logged only as configuration, and covered by tests.

| Switch | Values | Default | What it will do |
| --- | --- | --- | --- |
| `DEMO_MODE` | `true` or `false` | `false` | Shortens the withdrawal cooling-off period from 72 hours to 20 seconds, and accepts any 6-digit OTP. |
| `MOCK_AI` | `true` or `false` | `true` | Uses rule-based agent decisions and does not call Anthropic. |
| `PAYOUT_PROVIDER` | `mock` or `minisend` | `mock` | Who sends KES after escrow release. `mock` records a fake payout. |
| `SMS_PROVIDER` | `console` or `africastalking` | `console` | Who sends OTP SMS. `console` prints the code in the API logs. |
| `X402_ENABLED` | `true` or `false` | `false` | When `true`, agent decisions are paid over x402. When `false`, the API calls the agent directly. |

## Mobile

The app target is Flutter stable, with null-safe Dart. From `mobile/`:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

The API base URL and the demo switch are compile-time defines:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:3000 \
  --dart-define=DEMO_MODE=true \
  --dart-define=USE_MOCK_REPOSITORIES=false
```

| Define | Default | Meaning |
| --- | --- | --- |
| `API_BASE_URL` | `http://localhost:3000` | Dio base URL. Android emulators usually need `http://10.0.2.2:3000`. |
| `DEMO_MODE` | `false` | Matches the backend switch. `DemoConfig.withdrawalDelay` is 20 seconds when this is `true`, otherwise 72 hours. |
| `USE_MOCK_REPOSITORIES` | `true` | When `true`, screens use `MockRepository` implementations and the UI runs with no API. Set `false` to call the real client. |

Amounts are shown as KES with thousands separators. Strings shown in widgets come from `lib/core/constants/strings.dart`. Colors are defined only in `lib/core/theme/app_colors.dart`.

| Token | Hex |
| --- | --- |
| primary | `#0E9F6E` |
| primaryDark | `#057A55` |
| primaryTint | `#E6F6EF` |
| accent | `#FFB020` |
| accentTint | `#FFF4DB` |
| background | `#F7FAF8` |
| surface | `#FFFFFF` |
| textPrimary | `#0F1F18` |
| textSecondary | `#5B6B63` |
| border | `#E3EAE6` |
| error | `#DC2626` |

`error` is for errors and penalties only. Surfaces are solid colors: no gradients.

## CI

`.github/workflows/ci.yml` runs two jobs on every push and pull request.

- Backend: `npm ci`, lint, typecheck, test, build, and `docker build`.
- Mobile: `flutter pub get`, `flutter analyze`, and `flutter test`.
