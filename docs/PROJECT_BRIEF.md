# JobsAndMoreng.com — Project Brief (Master Context)

You are a senior Flutter engineer and product designer. You will build **JobsAndMoreng.com**, an AI-enabled employment, recruitment, career-development and business-support platform for Nigeria. It connects **Job Seekers, Employers/Recruiters, Business Owners/SMEs, Training Providers and Admins**.

It must be **one Flutter codebase** that ships to:
- **Web** (desktop + mobile browser)
- **Android** (Google Play)
- **iOS** (App Store)

The visual quality bar is **world-class**. Think LinkedIn's clarity, Airbnb's warmth, Linear's polish and Duolingo's delight. It must not look like a template or a generic job board.

## 1. Tech stack (use exactly this; keep it simple)

| Layer | Choice | Why |
|---|---|---|
| UI framework | **Flutter 3.x (latest stable), Dart 3** | One codebase for web, Android, iOS |
| State management | **Riverpod 2** (with `riverpod_generator`) | Simple, testable, scales |
| Routing | **go_router** | Deep links, web URLs, auth guards |
| Backend | **Supabase** (Postgres, Auth, Storage, Realtime, Edge Functions) | Relational data suits jobs/ATS; Row Level Security for privacy; no server to manage |
| AI | **Supabase Edge Functions** calling an LLM API (Claude by Anthropic) | API keys never live in the app |
| Payments | **Paystack** (Naira, cards, bank transfer, USSD) via Edge Function webhooks | Best fit for Nigeria |
| Push | **Firebase Cloud Messaging** (`firebase_messaging`) | Android/iOS/web push |
| Email | **Resend** (or Brevo) from Edge Functions | Transactional + job-alert digests |
| Models | **freezed** + **json_serializable** | Immutable, type-safe data |
| Animation | **flutter_animate**, **Rive** (hero/illustration motion), **Lottie** (success/empty states) | Premium motion |
| Fonts | **google_fonts** | Typography |
| Icons | **Phosphor Icons** (`phosphor_flutter`) | Modern, consistent icon set |
| Images | **cached_network_image**, `shimmer` for skeletons | Fast, polished loading |
| Charts | **fl_chart** | Dashboards, ATS score rings |
| Files | `file_picker`, `syncfusion_flutter_pdfviewer` (view CVs), `pdf` (export CVs) | CV upload/build/export |
| Forms | `reactive_forms` or plain `Form` + validators | Clear validation |
| Localisation | `flutter_localizations` + ARB files (English first; structure ready for Hausa, Yoruba, Igbo, Pidgin) | Nigeria-ready |
| Testing | `flutter_test`, `mocktail`, `integration_test`, golden tests for key screens | Quality |
| CI/CD | GitHub Actions + Codemagic (or Fastlane) | Automated builds |
| Web hosting | Firebase Hosting or Vercel; build with `flutter build web --wasm` | Fast load |

**SEO note for web:** Flutter web is not crawled well by Google. So:
1. The Flutter web app serves the logged-in experience and all screens.
2. Create a **Supabase Edge Function (`/seo`)** that server-renders lightweight HTML pages for **public job listings, employer profiles, courses and the homepage**. Include `<title>`, meta description, Open Graph tags and **Google for Jobs `JobPosting` JSON-LD**. Each page carries an "Open in app" link into the Flutter route.
3. Generate `sitemap.xml` and `robots.txt` from the database.
4. Set proper `<meta>` tags and a branded splash/loading screen in `web/index.html` so first paint never looks blank.

## 2. Project structure (feature-first, clean architecture)

```
lib/
  main.dart
  app/                 # App widget, router, theme, env config
    router/
    theme/             # design tokens, ThemeData light/dark, typography, motion
  core/                # shared: widgets, utils, extensions, constants, errors
    widgets/           # design-system components (JmButton, JmCard, JmChip...)
    responsive/        # breakpoints + adaptive layout helpers
  features/
    auth/              # sign in, sign up, onboarding, role selection
    home/              # public homepage
    jobs/              # search, detail, apply, saved, alerts
    profile/           # candidate career profile + completion score
    career_tools/      # AI CV builder, ATS analyser, interview coach, etc.
    employer/          # employer profile, vacancies, ATS pipeline, team
    business/          # business hub, services, opportunities, directory
    academy/           # courses, my courses, certificates, provider portal
    opportunities/     # scholarships, grants, internships, CGPA calculator
    messaging/         # inbox, notifications
    billing/           # plans, Paystack checkout, invoices
    rewards/           # points, referrals
    resources/         # articles, FAQs, help centre
    admin/             # admin console (web-first)
  each feature/
    data/              # repositories, Supabase data sources, DTOs
    domain/            # models (freezed), business rules
    presentation/      # screens, widgets, controllers (Riverpod)
supabase/
  migrations/          # SQL schema + RLS policies
  functions/           # Edge Functions (ai-*, paystack-webhook, job-alerts, seo, etc.)
  seed.sql             # realistic demo data, clearly marked as demo
```

## 3. Design system ("the best visuals")

Build the design system **first** and use it everywhere. Never hard-code colours, sizes or text styles in screens.

**Brand personality:** trustworthy, optimistic, modern, proudly Nigerian, professional but warm.

**Colour tokens (light mode)**
- `primary` Emerald `#0B8457` (trust, growth, a nod to the Nigerian flag) with a tonal scale 50–900
- `secondary` Deep Ink Navy `#0F1B2D` (headings, premium surfaces)
- `accent` Warm Amber `#F5A524` (calls to action, highlights, rewards)
- `info` Sky `#2F80ED`, `success` `#12B76A`, `warning` `#F79009`, `error` `#E5484D`
- `surface` `#FFFFFF`, `background` `#F7F9FB`, `border` `#E6EAF0`, `muted text` `#5B6575`
- **Dark mode:** background `#0B1220`, surface `#121A2B`, primary lifted to `#2BC48A`. Must be fully designed, not auto-inverted.
- **Signature gradient:** Emerald → Teal `#0B8457 → #14B8A6`, used sparingly on the hero, primary CTA hover and premium badges.
- All text/background pairs must meet **WCAG 2.2 AA contrast**.

**Typography**
- Headings: **Plus Jakarta Sans** (600–800)
- Body/UI: **Inter** (400–600)
- Type scale: Display 56/48, H1 40, H2 32, H3 24, H4 20, Body L 18, Body 16, Small 14, Caption 12. Scale down roughly 15% on mobile. Respect the system text-scale setting.

**Spacing, shape, depth**
- 4-pt spacing grid (4, 8, 12, 16, 24, 32, 48, 64, 96)
- Radii: 8 (inputs), 12 (buttons), 16 (cards), 24 (sheets/hero panels), full (chips/avatars)
- Elevation: soft, layered, colour-tinted shadows (e.g. `0 8 24 rgba(15,27,45,0.08)`), never harsh black
- Generous white space. Max content width 1200px on desktop.

**Visual style**
- Clean, airy layouts with **one** focal point per section
- Subtle **mesh-gradient / blurred-orb backgrounds** in hero areas, with a light glassmorphism panel for the hero search bar (blur + 70% white). Keep it tasteful.
- **Custom illustrations** with Nigerian people, settings and workplaces (Lagos office, Abuja SME, Kano artisan, campus graduate). Use Rive or SVG. **Never repeat the same image across unrelated sections. No obvious stock-photo clichés.**
- Verified badges are crisp and precise. Use separate labels: "Email verified", "Business details reviewed", "Verified employer".
- Data visuals: animated radial score rings (ATS score, profile completion), progress bars and sparkline stats.

**Motion (premium, never distracting)**
- Durations: 150ms (micro), 250ms (standard), 400ms (page/hero). Curves: `easeOutCubic`, `emphasized` spring for sheets.
- Staggered fade+slide-up for lists and cards on first load (flutter_animate)
- Hero transitions from job card to job detail and from course card to course detail
- Button press scale (0.97), hover lift on web cards (translateY -4 with a shadow increase)
- Skeleton shimmer loaders matching real layouts. **No bare spinners on content screens.**
- Lottie celebrations for: application submitted, profile reaches 100%, course completed, certificate issued
- Respect "reduce motion" accessibility settings

**Core components to build in `core/widgets/` (with a Widgetbook or `/dev/gallery` page that shows every one)**
`JmButton` (primary/secondary/ghost/destructive, loading state), `JmTextField` (label, helper, error, prefix icon), `JmSearchBar` (hero + compact), `JmCard`, `JmJobCard`, `JmCourseCard`, `JmEmployerCard`, `JmChip`/`JmFilterChip`, `JmBadge` (verification levels, sponsored, new), `JmAvatar`, `JmScoreRing`, `JmProgressMeter`, `JmStepper` (onboarding), `JmEmptyState` (illustration + message + action), `JmErrorState`, `JmSkeleton`, `JmBottomSheet`, `JmDialog`, `JmToast`, `JmSectionHeader`, `JmStatTile`, `JmTimeline` (application status), `JmKanbanColumn` (ATS), `JmPricingCard`.

## 4. Responsive and adaptive layout

Breakpoints: **mobile < 600**, **tablet 600–1024**, **desktop > 1024**.
- **Mobile app:** bottom navigation bar with 5 tabs per role (Job Seeker: Home, Jobs, Tools, Learn, Me). Native-feeling: iOS Cupertino back-swipe, Material 3 on Android, safe areas, 44pt minimum touch targets, pull-to-refresh, haptic feedback on key actions.
- **Web desktop:** a top navigation bar for public pages (Home, Find Jobs, Hire Talent, Business Hub, Courses & Academy, Career Tools, Resources, About/Contact, Sign in / Get started). A **collapsible side rail + top bar** for dashboards. Multi-column layouts: filters | results | preview pane for job search; Kanban for the ATS.
- **Web mobile:** same as the mobile app, with a hamburger menu for public pages.
- Every screen must be checked at 375px, 768px, 1280px and 1920px widths.

## 5. Non-negotiable product rules (from the blueprint)

1. **No placeholder text, lorem ipsum, template branding, fake testimonials, invented statistics or unverified vacancy claims** in production. Seed data must be flagged `is_demo = true` and hidden in production builds.
2. Precise verification labels only. Never show one badge that implies checks that were not done.
3. **AI outputs are always editable, rejectable and regenerable.** AI must never invent qualifications or experience. Missing facts are highlighted for the user to fill in.
4. ATS scoring is called **"estimated ATS-readiness"** or "CV compatibility analysis", with a visible disclaimer. Never claim to reproduce an employer's ATS, and never auto-reject candidates based on AI scores.
5. Sponsored/featured listings are always clearly labelled. Paid ranking is never disguised as organic.
6. Expired vacancies never appear as active.
7. Scholarships, grants, fellowships, volunteering and international opportunities are **separate listing types**, not "jobs".
8. Candidates control profile visibility and CV sharing. Employers see only what is needed for recruitment, and **never** another employer's applicants.
9. Separate, withdrawable consent for marketing, location, WhatsApp and optional data use.
10. Never store raw card details (Paystack handles them). Never ship API keys in the app.
11. Aim for **WCAG 2.2 AA**: semantic labels (`Semantics`), keyboard navigation on web, focus rings, scalable text and screen-reader support.

## 6. Data model (Supabase Postgres; write migrations with RLS on every table)

Core tables (add sensible columns, `created_at`, `updated_at`, soft-delete where useful):
- `profiles` (user_id, full_name, phone, state, city, avatar_url, active_role, roles[], consents jsonb)
- `organisations` (employer/business/provider; type, name, logo, industry, size, website, address, description, verification_level enum: `none | email_verified | details_reviewed | verified`)
- `organisation_members` (org_id, user_id, role: owner/admin/recruiter/viewer)
- `verification_requests` (org_id, evidence files, status, reviewer_id, notes, decided_at)
- `candidate_profiles` + child tables: `experiences`, `educations`, `skills`, `languages`, `certificates`, `associations`, `cv_documents`, `cover_letters`, `portfolio_items`
- `jobs` (org_id, title, description, responsibilities, requirements, benefits, type, arrangement, state, city, salary_min/max/disclosed, experience_level, industry, closing_date, status: draft/published/paused/closed/expired, is_sponsored, screening_questions jsonb)
- `opportunities` (type: scholarship/fellowship/grant/volunteering/competition/international/tender/accelerator; source_url, eligibility jsonb, deadline)
- `applications` (job_id, candidate_id, cv_document_id, cover_letter, answers jsonb, stage enum: New, Under Review, Shortlisted, Assessment, Interview, Reference Check, Offer, Hired, Rejected, Withdrawn)
- `application_events` (timeline/audit), `recruiter_notes`, `interviews`
- `saved_jobs`, `job_alerts` (keywords, states[], radius_km, types[], frequency: immediate/daily/weekly, channels[], paused)
- `ai_runs` (user_id, tool, input_ref, output jsonb, score, created_at), used for history, comparison and usage limits
- `courses`, `course_modules`, `lessons`, `enrolments`, `quiz_attempts`, `certificates_issued` (unique credential_ref, public verification page)
- `services` (business marketplace), `enquiries`, `connections`, `messages`, `conversations`
- `notifications` (category, read_at, link)
- `plans`, `subscriptions`, `transactions`, `invoices`, `credits`
- `reward_ledger`, `referrals`
- `reports` (listing/user/review reports), `reviews` (moderated), `audit_log`
- `cms_pages`, `articles`, `faqs`, `success_stories` (consent_confirmed bool), `partners` (logo_permission bool)
- `taxonomy_states`, `taxonomy_industries`, `taxonomy_skills`, `feature_flags`

RLS essentials: users read/write their own rows. Org members access only their org's jobs and applications. Candidates see their own applications. Admin roles are checked through a `staff_roles` table (super_admin, ops_admin, verification_officer, content_manager, finance_officer).

## 7. Engineering quality bar
- Null-safe, lint-clean (`very_good_analysis` or `flutter_lints` strict). No warnings.
- Every async screen has **loading (skeleton), empty, error and success** states.
- Repositories behind interfaces so they can be mocked in tests.
- Environment config via `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `PAYSTACK_PUBLIC_KEY`). No secrets in the repo.
- Image uploads are compressed client-side. File uploads are type/size-validated and virus-scanned server-side (Edge Function hook).
- Rate-limit AI and auth endpoints.
- Write a `README.md` with setup, run, build and deploy steps for web, Android and iOS.
- After each phase: run `flutter analyze`, run the tests and list what was built and what's left.

## Build phases

0. Foundation & Design System
1. Database & Auth
2. Public Website & Homepage
3. Jobs Marketplace & Job Alerts
4. Job Seeker Dashboard & Career Profile
5. AI Career Tools
6. Employer Experience & ATS
7. Business Hub (SMEs)
8. Academy, Opportunities & Rewards
9. Messaging, Notifications & Billing
10. Admin Console (web-first)
11. Polish, Accessibility, Testing & Launch
