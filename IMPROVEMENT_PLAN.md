# BookrHub Landing Page — Improvement & Tracking Plan

**Last updated:** June 2026  
**Source:** Derived from `Improve-app.md` (Gemini analysis), site audit, and additional research.

---

## How to Use

- [ ] = not started
- [/] = in progress
- [x] = done
- Date format: `YYYY-MM-DD`

---

## 🔴 CRITICAL — Page Speed & Core Web Vitals

These are the highest-impact items. Fixing these will transform Lighthouse scores, reduce bounce rate, and improve SEO ranking signals.

### 1. Convert 137 MB of GIFs to MP4

18 GIF files totaling 137 MB. Largest offenders: `hair-salon-landing.gif` (19 MB), `photography-landing.gif` (17 MB), `nails-landing.gif` (12 MB), `barber-landing.gif` (12 MB).

**Action:** Convert all to MP4 (H.264) using ffmpeg, serve with `<video autoplay loop muted playsinline poster="...">`.

```bash
# One-liner for each GIF:
ffmpeg -i input.gif -b:v 1M -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -movflags +faststart output.mp4
```

- [x] `public/gifs/barber-book.gif` → `/videos/barber-book.mp4`
- [x] `public/gifs/my-calendar.gif` → `/videos/my-calendar.mp4`
- [x] `public/gifs/barber-confirmation.gif` → `/videos/barber-confirmation.mp4`
- [x] `public/gifs/my-overview.gif` → `/videos/my-overview.mp4`
- [x] `public/gifs/dental-landing.gif` → `/videos/dental-landing.mp4`
- [x] `public/gifs/medical-clinic-landing.gif` → `/videos/medical-clinic-landing.mp4`
- [x] `public/gifs/iphone.gif` → `/videos/iphone.mp4`
- [x] `public/gifs/high-converting-landing.gif` → `/videos/high-converting-landing.mp4`
- [x] `public/gifs/modern-ux-landing.gif` → `/videos/modern-ux-landing.mp4`
- [x] `public/gifs/my-configuration.gif` → `/videos/my-configuration.mp4`
- [x] `public/gifs/fitness-landing.gif` → `/videos/fitness-landing.mp4`
- [x] `public/gifs/spa-massage-landing.gif` → `/videos/spa-massage-landing.mp4`
- [x] `public/gifs/fitness-pro-landing.gif` → `/videos/fitness-pro-landing.mp4`
- [x] `public/gifs/pet-grooming-landing.gif` → `/videos/pet-grooming-landing.mp4`
- [x] `public/gifs/nails-landing.gif` → `/videos/nails-landing.mp4`
- [x] `public/gifs/barber-landing.gif` → `/videos/barber-landing.mp4`
- [x] `public/gifs/photography-landing.gif` → `/videos/photography-landing.mp4`
- [x] `public/gifs/hair-salon-landing.gif` → `/videos/hair-salon-landing.mp4`
- [x] Update all `<img>` tags to `<video>` tags in `views/index.erb`, `seo_wrapper.erb`, `seo_layout.erb`
- [ ] Delete original GIFs after confirmation

**Estimated speed gain:** ~120 MB reduction. LCP will drop from 5-10s to 1-2s.

---

### 2. Add Lazy Loading

No images currently use `loading="lazy"`. All load eagerly.

- [x] Add `loading="lazy"` to all below-the-fold images in `views/index.erb`
- [x] Keep above-the-fold images (hero, nav logo) with no `loading` attribute
- [x] Add `decoding="async"` to all non-critical images (footer icons across all templates)

**Affected files:** `views/index.erb`, `views/seo_wrapper.erb`, `views/seo_layout.erb`, `views/oops.erb`, `views/server_error.erb`, `views/contact.erb`, `views/about.erb`

---

### 3. Fix Render-Blocking Scripts

- [ ] Move `<script src="https://www.noupe.com/embed/...">` to bottom of `<body>` or add `defer`
- [ ] Verify GTM script in `<head>` is using standard non-blocking pattern
- [ ] Add `preconnect` hint for `www.googletagmanager.com` and `www.google-analytics.com`

---

### 4. Fix Layout Shift (CLS)

- [ ] Add explicit `width` and `height` attributes to all `<img>` tags (currently only nav/footer logos have them)
- [ ] For `<video>` replacements (GIF→MP4), set explicit container dimensions
- [ ] Verify no layout shift in Chrome DevTools after changes

**Affected elements:** All GIF images in features section, template carousel, demo sections.

---

### 5. Enable Gzip Compression

- [x] Add `use Rack::Deflater` to `app.rb`
- [ ] Verify with `curl -H "Accept-Encoding: gzip" -I https://www.bookrhub.com/`

---

### 6. Add Caching Headers

- [x] Set `Cache-Control: public, max-age=31536000` for all static assets (`/images/*`, `/css/*`, `/videos/*`)
- [ ] Set `Cache-Control: public, max-age=3600` for HTML pages
- [ ] Configure Fly.io edge caching in `fly.toml` (or add Cloudflare)

---

### 7. Add Resource Hints

- [x] `<link rel="preconnect" href="https://www.googletagmanager.com">`
- [x] `<link rel="preconnect" href="https://www.google-analytics.com">`
- [x] `<link rel="preconnect" href="https://js.stripe.com">`
- [x] `<link rel="dns-prefetch" href="https://my.bookrhub.com">`

**Affected files:** `views/index.erb`, `views/seo_wrapper.erb`, `views/seo_layout.erb`

---

### 8. Optimize og-preview.jpg

- [ ] Compress from 424 KB to < 100 KB (use `sips` or ImageOptim)
- [ ] Create WebP version with `<picture>` fallback

---

### 9. Minify CSS

- [ ] Minify `public/css/styles.css` (64 KB → ~40 KB)
- [ ] Minify `public/css/seo-layout.css` (9.7 KB → ~6 KB)
- [ ] Update `?v=2.5.1` cache-busting parameter

---

### 10. Extract Inline JavaScript

- [ ] Move ~230 lines of inline JS from `views/index.erb` to `public/js/main.js`
- [ ] Load with `defer` at end of `<body>`
- [ ] Minify the external JS file

---

## 🔴 CRITICAL — SEO Fixes

### 11. Fix 404s & Redirect Errors

Search Console shows 42 redirect errors and 16 404s.

- [ ] Export full list of broken URLs from Search Console
- [ ] Fix or 301-redirect each broken URL
- [ ] Add wildcard redirect patterns in `app.rb` for common misspellings
- [ ] Verify with a crawl tool (Screaming Frog or similar)

---

### 12. Improve Meta Title/Description CTR

Main page has 0% CTR at position 4.16 — the title/description aren't compelling enough.

- [ ] Write 3-5 alternative meta title variations with benefits + numbers + social proof
- [ ] Write 3-5 alternative meta description variations
- [ ] Track CTR changes in Search Console after update

**Example direction:** Include "700+ businesses trust", "$0 commission", "5-min setup" in title/description.

---

### 13. Get Programmatic Pages Indexed

1,325 pages discovered but not indexed.

- [ ] Add more internal links from homepage / high-authority pages to programmatic pages
- [ ] Add breadcrumb navigation on all programmatic pages
- [ ] Add "Related articles" sections linking between pages
- [ ] Reduce content similarity across pages (add unique local content)
- [ ] Submit key pages for indexing via Search Console
- [ ] Create hub/listing pages that link to all niche pages (e.g., `/booking-system-by-industry`)

---

### 14. Create Blog Section

Currently `/blog` redirects to homepage.

- [ ] Choose a strategy: subdirectory (`/blog/`) vs subdomain (`blog.bookrhub.com`). **Recommendation:** subdirectory for SEO benefits
- [ ] Create blog index template at `views/blog.erb`
- [ ] Create blog post template with article schema
- [ ] Add RSS feed at `/blog/feed.xml`
- [ ] Write first 3-5 posts targeting high-intent long-tail keywords:
  - [ ] "How to Choose a Booking System for Your Salon (2026 Guide)"
  - [ ] "Fresha vs BookrHub: Which Saves You More Money?"
  - [ ] "Commission-Free Booking: The Complete Guide for Barbers"
  - [ ] "How to Reduce No-Shows by 80% with Automated Reminders"
  - [ ] "Booking Software Pricing Comparison: What Actually Costs What"

---

### 15. Improve Internal Linking

- [ ] Add breadcrumbs to all programmatic SEO pages
- [ ] Add "You might also like" / "Compare with" links at bottom of each page
- [ ] Link from main page to top 5 competitor comparison pages
- [ ] Link from comparison pages to related niche pages
- [ ] Ensure every programmatic page has at least 2-3 internal links pointing to it

---

## 🟡 HIGH — Conversion & Lead Generation

### 16. Add Email Capture / Lead Magnet

No newsletter or email capture exists on the landing page.

- [ ] Create lead magnet: "Free Salon Growth Checklist" or "Booking System ROI Calculator"
- [ ] Add embedded signup form (use your own endpoint, not external)
- [ ] Add signup form in footer or as a section after pricing/features
- [ ] Add A/B test for form placement (footer vs mid-page vs slide-in)

---

### 17. Add Exit-Intent Popup

- [ ] Implement exit-intent detection (JS mouseleave listener)
- [ ] Show offer: "Start your free trial — no credit card needed" + email capture
- [ ] Set cookie to not show again for 30 days

---

### 18. Add Real-Time Social Proof

- [ ] Add counter: "X businesses joined BookrHub this week" (can be static or dynamic)
- [ ] Add "X appointments booked today" counter
- [ ] Add live visitor count (optional, from analytics)

---

### 19. Replace "Watch Demo" with Actual Video

Currently scrolls to static screenshots.

- [ ] Record 60-90s product demo video (screen recording + voiceover)
- [ ] Host on Vimeo/YouTube or self-host with poster image
- [ ] Replace the "Watch Demo" scroll anchor with video modal/lightbox
- [ ] Add transcript below video for SEO

---

### 20. Improve Contact Form

Currently uses Formspree (external service).

- [ ] Build server-side contact form endpoint in Sinatra (POST `/contact`)
- [ ] Add email delivery (SendGrid, Mailgun, or SMTP via `mail` gem)
- [ ] Add spam protection (honeypot field + rate limiting)
- [ ] Remove Formspree dependency

---

### 21. Add Live Chat / Chatbot

- [ ] Evaluate options: Tawk.to (free), Crisp, or custom chatbot
- [ ] Install on all pages
- [ ] Set up automated greeting + FAQ responses

---

## 🟡 HIGH — GEO / AI Search Optimization

### 22. Add Original Data & Statistics

LLMs cite pages with original data 6.5x more.

- [ ] Add 3-5 data points / statistics to the main page (e.g., "Appointment no-shows cost salons $X annually")
- [ ] Source data from industry reports and cite them
- [ ] Add "Statistics" section to programmatic pages where relevant

---

### 23. Add Expert Quotes / Author Bios

- [ ] Add "Expert quote" callout boxes on key pages
- [ ] Add author byline with bio on blog posts and key SEO pages
- [ ] Include author schema markup

---

### 24. Claim Wikipedia Presence

- [ ] Check if BookrHub meets Wikipedia notability criteria
- [ ] If yes, draft Wikipedia article with neutral tone + third-party sources
- [ ] If no, focus on getting mentioned in existing relevant Wikipedia articles

---

### 25. Execute Software Directory Listings

From `BACKLINK_ACTION_PLAN.md`:

- [ ] **G2** — Submit product, get 10+ reviews
- [ ] **Capterra** — Submit product, get reviews
- [ ] **Software Advice** — Submit product
- [ ] **TrustRadius** — Submit product
- [ ] **GetApp** — Submit product
- [ ] **Google Business Profile** — Claim and complete
- [ ] **Yelp Business** — Claim listing
- [ ] **Bing Places** — Claim listing

---

### 26. Audit & Strengthen llms.txt

- [x] Review `/public/llms.txt` for completeness
- [x] Ensure it covers all key pages, features, and differentiation points
- [x] Add structured sections (Overview, Features, Pricing, FAQ)
- [x] Updated "Last updated" to June 2026

---

## 🟡 HIGH — Content Depth

### 27. Write 5-10 More Linkable Assets

Original research, data studies, templates that earn backlinks:

- [ ] "State of the Salon Industry 2026" report
- [ ] "Booking Software Pricing Benchmarks" report
- [ ] "Barbershop Business Plan Template" (free download)
- [ ] "Salon Marketing Calendar 2026" (free download)
- [ ] "How Much Do Salons Lose to No-Shows?" (data study)
- [ ] "SaaS for Salons: Market Analysis 2026"
- [ ] "The Complete Guide to Switching from Fresha" (linkable guide)

---

### 28. Add More FAQ Content

- [ ] Add niche-specific FAQs to programmatic pages (e.g., "How to set up online booking for a barbershop")
- [ ] Add FAQ schema to all pages that have FAQ content
- [ ] Target "People also ask" queries from Search Console

---

### 29. Create Additional Niche Pages

Underserved niches not yet covered:

- [ ] Booking system for yoga studios
- [ ] Booking system for tattoo artists
- [ ] Booking system for therapists / counselors
- [ ] Booking system for dental clinics
- [ ] Booking system for veterinarians
- [ ] Booking system for photographers
- [ ] Booking system for auto repair shops

---

### 30. Audit Multi-Language Pages

- [ ] Verify all 6 non-EN/ES locale pages are complete (FR, DE, PT, IT, NL, RU)
- [ ] Check for missing translations or placeholder content
- [ ] Add locale-specific keywords for each language

---

## 🟢 MEDIUM — Technical & Polish

### 31. Fix Inconsistent Analytics

- [ ] `index.erb`: env-conditional GTM/GA4 ✅
- [x] `seo_wrapper.erb`: env-conditional ✅
- [x] `seo_layout.erb`: env-conditional ✅
- [x] `privacy.erb`: env-conditional ✅
- [ ] `about.erb`: env-conditional ✅
- [ ] `contact.erb`: env-conditional ✅

---

### 32. Add / Improve Structured Data

- [ ] Add `datePublished` / `dateModified` to all programmatic pages
- [ ] Add BreadcrumbList schema to all programmatic pages
- [ ] Add Organization schema to About and Contact pages
- [ ] Add LocalBusiness schema to country/city-specific pages
- [ ] Add Product schema for pricing tiers

---

### 33. Add Geo Tags on Country Pages

- [x] Add `<meta name="geo.region" content="AR">` on Argentina pages
- [x] Add `<meta name="geo.region" content="CL">` on Chile pages
- [x] Add `<meta name="geo.region" content="NZ">` on New Zealand pages
- [x] Add `<meta name="geo.placename" content="...">` on relevant pages

**Approach:** `COUNTRY_GEO` mapping in `app.rb` with `set_geo_from_path` helper, renders geo tags in `seo_wrapper.erb` and `seo_layout.erb`

---

### 34. Improve 404 Page

- [ ] Add search bar on 404 page
- [ ] Add "Popular pages" links
- [ ] Add "Contact us" link
- [ ] Make it friendly and on-brand

---

### 35. Set Up A/B Testing

- [ ] Choose framework: Google Optimize (free) or server-side variants in Sinatra
- [ ] Set up first test: hero headline A/B test
- [ ] Set up second test: CTA button text/color

---

### 36. CDN / Edge Caching

- [ ] Configure Fly.io CDN (add `[[services]]` with cache settings in `fly.toml`)
- [ ] Or add Cloudflare in front of Fly.io
- [ ] Set proper Cache-Control and Vary headers

---

## From Improve-app.md (Original Items — for Reference)

### ✅ Already Done

- [x] Competitor comparison pages (10 EN + 4 ES)
- [x] Regional/local SEO (city+niche pages, country pages)
- [x] 301 redirects for old URLs
- [x] HTTPS enforcement + www canonicalization
- [x] Dynamic XML sitemap with 1,200+ URLs
- [x] Dynamic robots.txt
- [x] Hreflang tags for 12+ locales
- [x] Open Graph + Twitter Cards on all pages
- [x] JSON-LD structured data (SoftwareApplication, Organization, FAQPage, BreadcrumbList, HowTo, Review)
- [x] Google Analytics + Google Tag Manager
- [x] Backlink strategy document (BACKLINK_ACTION_PLAN.md)

### ❌ Still Pending

- [ ] See items 11-15 above (CTR improvement, blog, indexation, etc.)

---

## Weekly Progress Tracker

| Week | Focus Area | Start | End | Completed Items |
|---|---|---|---|---|
| Week 1 | Page Speed & Core Web Vitals (items 1-10) | | | |
| Week 2 | SEO Fixes (items 11-15) | | | |
| Week 3 | Conversion & GEO (items 16-26) | | | |
| Week 4 | Content Depth (items 27-30) | | | |
| Week 5+ | Technical & Polish (items 31-36) | | | |
