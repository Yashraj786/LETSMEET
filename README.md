# LETSMEET

> An exclusive, invite-only hangout network for high-end demographics. By invitation only.

## Architecture Overview

**Stack:** Ruby 3.2 · Rails 8.1 · PostgreSQL 16 · Redis/Sidekiq · ActiveStorage

### Core Models

| Model | Purpose |
|---|---|
| `User` | Devise auth with role enum (member/admin), invite tracking |
| `ReferralCode` | Cryptographic token controlling who can invite whom |
| `Invitation` | One-time-use invite linking prospect email to a referral code |
| `Profile` | Public-facing identity with ActiveStorage avatar + cover photo |
| `Hangout` | Exclusive events (virtual/in-person/hybrid) |
| `HangoutParticipant` | RSVP junction (invited/accepted/declined/waitlisted) |

### Key Security Mechanisms

1. **Invite-Only Registration** — Devise registrations controller is overridden to validate an `invitation_token` parameter. No token → no account.
2. **Referral Code Gatekeeping** — Each invitation consumes one use from a `ReferralCode`. Codes have max-use caps, expiry dates, and can be deactivated.
3. **Pundit Authorization** — Every controller action is authorized via a Pundit policy. Defaults to DENY. Admins have elevated access.
4. **Lockable + Confirmable** — Devise lockable protects against brute-force; confirmable requires email verification before first access.

### Background Jobs (Sidekiq)

- `InvitationEmailJob` — dispatched immediately on invitation creation.
- `WelcomeEmailJob` — dispatched after registration; allocates the member's first referral code.

## Setup

### Prerequisites

- Ruby 3.2+
- PostgreSQL 16+
- Redis (for Sidekiq)

### Installation

```bash
git clone https://github.com/Yashraj786/LETSMEET.git
cd LETSMEET

bundle install

# Configure environment
cp .env.example .env

rails db:create db:migrate db:seed

bin/dev
```

### Environment Variables

| Variable | Description | Default |
|---|---|---|
| `REDIS_URL` | Redis connection string | `redis://localhost:6379/1` |
| `MAILER_FROM` | From address for emails | `noreply@letsmeet.app` |
| `ADMIN_EMAIL` | Seed admin email | `admin@letsmeet.app` |
| `ADMIN_PASSWORD` | Seed admin password | Random (printed once) |
| `SIDEKIQ_CONCURRENCY` | Sidekiq worker threads | `5` |

### Starting Sidekiq

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

## Access Flow

```
Admin mints referral code → Sends invitation email with unique token
→ Prospect follows link → Registration form pre-filled with their email
→ Registers → Token consumed, referral code use decremented
→ Confirms email → Full access granted
→ Receives welcome email + their first referral code
```

## Admin Operations

Access the admin panel at `/admin` (requires `role: :admin`).

From the admin panel you can:
- View all members and their invite chains
- Grant/revoke admin privileges
- Mint referral codes with configurable use limits and expiry
- Monitor the invitation pipeline

To seed the first admin:

```bash
rails db:seed
# Or set ADMIN_EMAIL / ADMIN_PASSWORD env vars before seeding
```
