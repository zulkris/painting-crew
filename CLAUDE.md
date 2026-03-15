# Painting Crew — Project Summary

## Project

Landing page for a 3-day painting business launch program.

**File:** `index.html` — single self-contained HTML file, no build step required.

## Brief

| Field | Value |
|-------|-------|
| Product | Start Your Painting Crew in 3 Days |
| Value proposition | Education + Equipment + Technology + Support |
| Target audience | People wanting to start a painting business (no experience needed) |
| Primary CTA | Book a Call |
| Price | $10,000 (one-time, payment plans available) |
| Phone | +7 900 654-68-21 |
| Program length | 3 days |

## Brand Colours

| Role | Hex | Notes |
|------|-----|-------|
| Primary (navy blue) | `#184675` | HSL(210°, 66%, 28%) — white text contrast 8.6:1 ✅ |
| Accent (red) | `#f70101` | HSL(0°, 99%, 49%) — used as accent only (stars, pulses) |
| Accent CTA | `#cc0101` | Shade-600 of red — white text contrast 5.1:1 ✅ WCAG AA |

## Page Structure

1. **Nav** — sticky, dark mode toggle, mobile hamburger, "Book a Call" CTA
2. **Hero** — headline, sub, two CTAs, social proof snippet
3. **Trust bar** — 3 days / 200+ businesses / 4 pillars / $10K
4. **What You Get** — 4 pillars: Education, Equipment, Technology, Support
5. **3-Day Journey** — Day 1 (Foundation), Day 2 (Skills), Day 3 (Launch)
6. **Pricing** — $10,000 all-inclusive card with feature checklist
7. **Testimonials** — 3 cards with star ratings
8. **Book a Call** — form (name, email, phone) + direct phone link
9. **FAQ** — 5 questions, schema.org FAQPage markup
10. **Footer** — phone, privacy/terms placeholders, copyright

## Tech Stack

- Tailwind CSS via CDN (no build step)
- Vanilla JS — dark mode toggle (localStorage), mobile menu
- Single `index.html` — deployable anywhere

## Placeholders to Replace

- Testimonial names, quotes, and company names
- `og-image.jpg` (OG social share image)
- Form `action` attribute (wire to backend / Tally / Typeform)
- Privacy Policy and Terms pages
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
