# Blog revamp: Jekyll 3.9 + Chalk → Bridgetown 2.x

Status: **complete** · 2026-11-21 · Issues #83–#99

## Goal

Bring the blog to 2026 **without changing how it looks**: the new stack went live only once
it looked identical to the old site and every legacy URL still resolved. New features come
after parity (see the list at the end).

## Why

The stack froze around 2017–2019 and no longer built: Ruby 2.4.3, Bundler crashing on Ruby
3.4, Jekyll 3.9 with `jekyll-assets` and Sprockets 3, Ruby Sass, jQuery and friends vendored
through yarn, deploys force-pushing `gh-pages` from a laptop, and three dead CI configs.

The live site also had bugs, all fixed by the migration: `/feed.xml` was a 404, the sitemap
listed ~150 `node_modules` pages, URLs in the sitemap and `og:url` lacked the scheme, the
default theme ignored its config, a dead Google Analytics UA was embedded, and the site
`description` was literally `"description"`.

## Decisions

| Topic | Decision | Notes |
|---|---|---|
| Generator | **Bridgetown 2.x** | Active, Ruby-first, Jekyll heritage. |
| Templates | **ERB** + Ruby components | |
| Posts | Plain Markdown (`template_engine: none`) | Bridgetown would otherwise run ERB over code samples like `<%= ... %>`. |
| Styles | The Chalk SCSS on Dart Sass with `@use`, bundled by esbuild | Per-theme colors as CSS custom properties; grays pinned to the legacy hex values. |
| Theme | One stylesheet, `[data-theme]` | Follows `prefers-color-scheme`; the toggle stores an explicit choice in `localStorage`. |
| JavaScript | Small vanilla JS, no jQuery | `IntersectionObserver` scroll-appear, theme toggle, share popup; zoom via `zooming`. |
| Fonts | Self-hosted woff2 | Google Fonts and webfontloader dropped. |
| Metadata | `bridgetown-feed`, `bridgetown-sitemap`, `bridgetown-seo-tag` | Through a `seo_metadata` helper that keeps the Jekyll title order. |
| Runtime | **Ruby 4.0 + Node 26 LTS** in `mise.toml` | |
| Checks | `bin/ci`: RuboCop, production build, html-proofer link check, Minitest | Same script locally and on GitHub Actions. |
| Hosting | **Cloudflare Workers static assets** | Built on GitHub Actions after `bin/ci`, deployed with the `cf` CLI; preview per PR. |
| Analytics / comments / share | Decide after parity | Disqus and the Twitter share link kept for now. |

## Outcomes

- **Phase 0 · #83, baseline.** This plan, `CLAUDE.md`, the 38 legacy URLs in
  `test/fixtures/legacy_urls.txt`, and the `legacy-jekyll-site` tag on the old build.
- **Phase 1 · #85, scaffold.** Bridgetown with ERB and Sass, `mise.toml`, `bin/setup`, `bin/ci`
  and its GitHub Actions workflow; the Jekyll tooling, dead CI configs and devcontainer removed.
- **Phase 2 · #87, content.** Posts moved with their history and converted by script without
  prose changes (`{% highlight %}` → fenced code, image includes → Markdown). A builder
  generates `/tag/:slug/` for every tag in `src/_data/tags.yml`; a test fails on unknown tags.
- **Phase 3 · #89, templates and frontend.** Layouts and components in ERB and Ruby; the Chalk
  SCSS on Dart Sass; theme, fonts and JavaScript as decided above.
- **Phase 4 · #91, plugins and metadata.** Atom feed, sitemap and seo-tag with an `https` site
  URL; the `new_post` command.
- **Phase 5 · #93, parity.** The `check_links` command in `bin/ci`, with problems in post content
  listed in `CheckLinks::KNOWN_FAILURES` instead of edited. Screenshots against the live site at
  two widths and four theme states; two derived colors fixed to the legacy values.
- **Phase 6 · #95, cutover.** A Worker serving `output/` as static assets: the default
  `auto-trailing-slash` routing serves `posts/slug.html` at `/posts/slug` and `tag/x/index.html`
  at `/tag/x/`. CI deploys a checked preview per PR and production on `main`; the
  `check_deploy` command verifies a deploy (legacy URLs, sitemap and feed links, 404 page, no
  Cloudflare rewrites). `blog.albertorocha.me` switched on 2026-11-21, after turning off
  Email Address Obfuscation, which rewrote `git@github.com` in code blocks. GitHub Pages is off;
  the `gh-pages` branch is kept.
- **Phase 7 · #99, cleanup.** See the checklist below.

Intended differences from the Jekyll site: the `minitest` tag (missing before, so its link was a
404), one post reading 2 minutes instead of 1 (kramdown's code markup adds a word per block),
Rouge 4.7 coloring `#{}` inside `%()` strings, a working feed, and the share link with the full
`https://` URL.

### Phase 7: cleanup · #99
- [x] The obsolete dependabot PR (#82) was already closed
- [x] Dependabot for gems, npm packages and GitHub Actions (weekly; minor and patch grouped, `cf` alone)
- [x] README rewritten for the finished site; `CLAUDE.md` describes the layout and drops the parity rule
- [x] This plan condensed to decisions and outcomes
- [x] Unused images removed: the light favicon and touch icon, and `_assets/images/photo4.jpg` and
      `post_1/new_pr.png`, which stay in the history (`git show 8654ff5:_assets/images/photo4.jpg`)
- [x] The `new_feature` branch (2017, the example of the `feature-branch-workflow` post) is kept
- Skipped, since they add little and can happen any time: deleting merged branches (remote and local) and
  the leftover `github-pages` environment

## After parity (to discuss)

- Post links found in Phase 5 (wording changes need approval): the empty `[Pull Request]()` link in
  `publishing-ruby-gems-with-github-actions`, `http://` links, and external links that fail (see PR for #93)
- Analytics: none / Cloudflare Web Analytics / Plausible / GoatCounter
- Comments: Disqus → Giscus or none
- Share links: Twitter → Bluesky/Mastodon/LinkedIn or none
- Copy button on code blocks, light/dark syntax themes, client-side search (Pagefind), per-post OG images
- Image optimization (`src/images` is ~11 MB)
- Replace `zooming` (no release since 2.1.1) with a native `<dialog>` zoom
- A light-theme favicon
- Always Use HTTPS: the zone setting is off, so HTTP serves pages (200) as it did on GitHub Pages
- Move to `blog.alberto.dev` (shorter). `alberto.dev` isn't on the Cloudflare account yet (nameservers first).
  Every `blog.albertorocha.me` URL must 301 to the same path; change `url`, canonical and feed;
  Search Console change of address; Disqus comments are keyed by URL, so they need Disqus's domain migration
