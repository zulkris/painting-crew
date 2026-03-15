# Покрасочная бригада — Project Summary

## Project

Landing page for a painting crew launch program (airless spraying).

**File:** `index.html` — single self-contained HTML file, no build step required.

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

## Page Structure

1. **Nav** — sticky, dark mode toggle, mobile hamburger, "Получить консультацию" CTA
2. **Hero** — headline, sub, 3 key benefits, two CTAs
3. **Для кого** — 4 target audience cards (crew, entrepreneur, painter, contractor)
4. **Заработок** — earnings economics + example project cards
5. **Что входит** — 4 pillars: training, equipment, practice, post-training support
6. **Как проходит** — 4-step timeline (consult, equip, train, launch)
7. **Примеры работ** — 3 project case study cards (facade, warehouse, interior)
8. **Оборудование** — starter kit checklist + image placeholder
9. **Скорость** — speed comparison bars (brush/roller/airless spraying)
10. **Отзывы** — case study testimonial block
11. **Стоимость** — 3 pricing tiers (Старт / Профессиональный / Под ключ)
12. **FAQ** — 4 questions
13. **Финальный CTA** — consultation form (name, phone, email) + phone link
14. **Footer** — branding, privacy link, phone, copyright

## Tech Stack

- Tailwind CSS via CDN (no build step)
- Google Fonts: Unbounded (display), Onest (body)
- Vanilla JS — dark mode (localStorage), mobile menu, IntersectionObserver for speed bars
- Single `index.html` — deployable anywhere

## Placeholders to Replace

- Earnings figures (X ₽ / м², XXX ₽ per project)
- Case study areas and timelines (XXX м², X дней)
- Equipment photo in starter kit section
- Case study photos in examples section
- `og-image.jpg` (OG social share image)
- Form `action` attribute (wire to backend / Tally / Typeform)
- Privacy Policy page
- Canonical URL (`https://paintingcrew.com`)

## Preview

```bash
python3 -m http.server 8080
# open http://localhost:8080
```

## Skills Used

Installed globally via `npx skills add`:

| Skill | Path |
|-------|------|
| `landing-page` | `~/.agents/skills/landing-page` |
| `tailwind-theme-builder` | `~/.agents/skills/tailwind-theme-builder` |
| `color-palette` | `~/.agents/skills/color-palette` |

Source: `https://github.com/jezweb/claude-skills`
