# Покрасочная бригада — Project Summary

## Project

Landing page for a painting crew launch program (airless spraying), built as a Phoenix LiveView application.

## Brief

| Field | Value |
|-------|-------|
| Product | Запуск покрасочной бригады под ключ |
| Value proposition | Обучение + Оборудование + Практика + Поддержка |
| Target audience | Construction crews, entrepreneurs, painters, contractors |
| Primary CTA | Получить консультацию |
| Price | 3 tiers (Старт / Профессиональный / Под ключ), price on request |
| Phone | +7 900 654-68-21 |
| Launch timeline | 7–14 days |
| Language | Russian |

## Brand Colours

| Role | Hex | Notes |
|------|-----|-------|
| Primary (navy blue) | `#184675` | HSL(210°, 66%, 28%) — white text contrast 8.6:1 |
| Accent (red) | `#f70101` | HSL(0°, 99%, 49%) — used as accent only |
| Accent CTA | `#cc0101` | Shade-600 of red — white text contrast 5.1:1 WCAG AA |

## Tech Stack

- **Phoenix 1.7** with LiveView
- **Ecto** + PostgreSQL
- **Tailwind CSS 3.4** (build-time via Phoenix tailwind)
- **Google Fonts**: Unbounded (display), Onest (body)
- **Swoosh** for email notifications
- **Req** for Telegram notifications
- **Docker Compose** for local development
- **Fly.io** for production deployment

## Project Structure

```
lib/
├── painting_crew/
│   ├── submissions/
│   │   ├── submission.ex          # Ecto schema (name, phone, email, source)
│   │   └── submissions.ex         # Context (list, create, change)
│   ├── notifier.ex                # Email (Swoosh) + Telegram (Req) notifications
│   └── release.ex                 # Migration helper for releases
├── painting_crew_web/
│   ├── live/
│   │   └── landing_live.ex        # Landing page LiveView (all 14 sections)
│   ├── controllers/
│   │   ├── admin_controller.ex    # Admin panel (login, submissions list)
│   │   ├── admin_html.ex          # Admin view module
│   │   └── admin_html/            # Admin templates (login, index)
│   ├── plugs/
│   │   └── admin_auth.ex          # Session-based admin auth plug
│   ├── components/layouts/
│   │   ├── root.html.heex         # Root layout (lang=ru, fonts, OG meta)
│   │   └── app.html.heex          # App layout (minimal wrapper)
│   └── router.ex                  # Routes: / (LiveView), /admin/*
assets/
├── tailwind.config.js             # Brand colours (primary/accent), fonts
├── css/app.css                    # Custom CSS (grain, stripes, speed-bar)
└── js/app.js                      # LiveView hooks (DarkMode, MobileMenu, SpeedBar)
config/
├── config.exs                     # Notifier + admin defaults
├── dev.exs                        # DB hostname via DB_HOST env (default: "db")
├── test.exs                       # DB hostname via DB_HOST env (default: "db")
├── prod.exs                       # Production static config
└── runtime.exs                    # Prod secrets (DATABASE_URL, SMTP, Telegram, admin)
```

## Page Sections (Landing LiveView)

1. **Nav** — sticky, dark mode toggle (DarkMode hook), mobile hamburger (MobileMenu hook)
2. **Hero** — headline, sub, 3 benefits, two CTAs
3. **Для кого** — 4 audience cards
4. **Заработок** — earnings economics + example project
5. **Что входит** — 4 pillars
6. **Как проходит** — 4-step timeline
7. **Примеры работ** — 3 case study cards
8. **Оборудование** — starter kit checklist
9. **Скорость** — speed comparison bars (SpeedBar hook)
10. **Отзывы** — testimonial block
11. **Стоимость** — 3 pricing tiers
12. **FAQ** — 4 questions (native `<details>`)
13. **Финальный CTA** — LiveView form (name, phone, email) with validation
14. **Footer** — branding, privacy link, phone, copyright

## Routes

| Path | Handler | Description |
|------|---------|-------------|
| `/` | `LandingLive` | Landing page with consultation form |
| `/admin/login` | `AdminController` | Admin login page |
| `/admin` | `AdminController` | Submissions list (requires auth) |
| `/admin/logout` | `AdminController` | Logout |
| `/dev/dashboard` | LiveDashboard | Dev only |
| `/dev/mailbox` | Swoosh preview | Dev only |

## Docker Development

```bash
# Start all services
docker compose up --build

# Run tests inside container
docker compose exec painting_crew_app mix test

# Just the database
docker compose up -d db
```

Container names: `painting_crew_db` (PostgreSQL 16), `painting_crew_app` (Elixir dev server).

DB config uses `DB_HOST` env var (defaults to `"db"` for Docker networking).

## Production (Fly.io)

```bash
fly launch --no-deploy
fly secrets set SECRET_KEY_BASE=$(mix phx.gen.secret)
fly secrets set DATABASE_URL=ecto://...
fly secrets set ADMIN_PASS=...
fly deploy
```

## Environment Variables

See `.env.example` for full list. Key ones:

| Variable | Required | Description |
|----------|----------|-------------|
| `DATABASE_URL` | prod | PostgreSQL connection URL |
| `SECRET_KEY_BASE` | prod | Phoenix secret key |
| `ADMIN_PASS` | prod | Admin panel password |
| `ADMIN_USER` | no | Admin username (default: "admin") |
| `NOTIFY_TO` | no | Email recipient for notifications |
| `TELEGRAM_BOT_TOKEN` | no | Telegram bot token |
| `TELEGRAM_CHAT_ID` | no | Telegram chat ID |
| `SMTP_HOST` | no | SMTP server for prod email |
| `DB_HOST` | no | Database hostname (default: "db") |

## Placeholders to Replace

- Earnings figures (X ₽ / м², XXX ₽ per project)
- Case study areas and timelines (XXX м², X дней)
- Equipment photo in starter kit section
- Case study photos in examples section
- `og-image.jpg` (OG social share image)
- Privacy Policy page
- Canonical URL
