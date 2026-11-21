# Blog revamp plan: Jekyll 3.9 + Chalk → Bridgetown 2.x

Status: **in progress** · Started: 2026-11-21

## Goal

Bring the blog to 2026 **without changing how it looks**. The site goes live on the new
stack only when it is visually identical to the current one and every legacy URL still
resolves. New features come after parity.

## Why

The current stack froze around 2017–2019 and no longer builds:

- Ruby 2.4.3 (EOL 2020), Bundler 2.2.31 crashes on Ruby 3.4.
- Jekyll 3.9.3, `jekyll-assets` + Sprockets 3 (unmaintained), Ruby Sass (dead since 2019),
  Nokogiri 1.10, jQuery/webfontloader/retinajs/svgxuse via yarn.
- Deploys via `bin/deploy` force-pushing `gh-pages` from a local machine.
- Three dead CI configs (Travis, Circle, Codeship badge).

Bugs found on the live site (2026-11-21):

- `/feed.xml` returns 404 (`rss_enabled` shows the icon, but `jekyll-feed` was never installed).
- `sitemap.xml` lists ~150 npm documentation pages (`/node_modules/npm/docs/...`) because
  `node_modules` was an asset source and got published.
- `url` in `_config.yml` lacks the scheme, so sitemap, `og:url` and feed links are invalid.
- Default theme is effectively *light* even though config says *dark*
  (`disabled="false"` still disables the stylesheet; JS seeds `light`).
- Google Analytics UA (shut down in 2023) is still embedded.
- GitHub Pages has `https_enforced: false`.
- Site `description` is literally `"description"`.

## Decisions

| Topic | Decision | Notes |
|---|---|---|
| Generator | **Bridgetown 2.x** | Active (releases through 2026), Ruby-first, Jekyll heritage. A home-made Ruby SSG stays an option for later. |
| Templates | **ERB** + Ruby components | No Liquid-first detour. |
| Styles | Keep the Chalk SCSS, compiled by Dart Sass via esbuild (`--use-sass`) | Fix `@import`/`lighten`/`darken` deprecations after parity. |
| Theme | Single stylesheet, CSS custom properties, `[data-theme]` | Default follows `prefers-color-scheme`; user choice persisted in `localStorage`. |
| JavaScript | No jQuery | Scroll-appear → `IntersectionObserver`; image zoom via `zooming` (or native `<dialog>`); theme toggle in vanilla JS. |
| Fonts | Self-hosted (already in `_assets/fonts`) | Drop Google Fonts / webfontloader. |
| Hosting | **Cloudflare Workers static assets** (DNS already there) | Built on GitHub Actions (mise, after `bin/ci`), deployed with the `cf` CLI; preview per PR. See Phase 6. |
| Devcontainer | **Remove** | `mise` covers the local environment. |
| Analytics / comments / share | Decide **after** parity | GA UA removed (dead). Disqus kept until then. |
| Runtime | **Ruby 4.0 + Node 26 LTS**, pinned in `mise.toml` | Bridgetown CI tests Ruby 3.3/3.4/4.0; matches the author's other projects. |
| Linting | Plain RuboCop (+ `rubocop-minitest`) | Tuned for a small Ruby project, not Rails omakase. |
| Language | Posts stay in English | |

## Workflow for this plan

- **One issue at a time.** Create the issue for the next phase only after the previous one is merged.
- Issue → `gh issue develop <N> --checkout` → PR → merge to `main` (see `CLAUDE.md`).
- Update the checkboxes and the issue column below as phases complete.

## Phases

### Phase 0: baseline · #83
- [x] Write this plan
- [x] Add `CLAUDE.md` (and `AGENTS.md` pointing to it)
- [x] Commit legacy URLs to `test/fixtures/legacy_urls.txt` (38 paths, all 200 on 2026-11-21)
- [x] Tag the current `gh-pages` build as `legacy-jekyll-site`

The live site itself is the visual baseline until cutover; the tag preserves the built
output after `gh-pages` is deleted.

### Phase 1: Bridgetown scaffold · #85
- [x] `bridgetown new --use-sass -t erb -s puma` in a temp dir; bring the structure into the repo
- [x] `mise.toml` with Ruby 4.0.10 + Node 26.13.1 (replaces `.ruby-version` 2.4.3)
- [x] `bin/setup` (bundle + `npm ci`)
- [x] Remove Jekyll/Chalk tooling: `Gemfile`/lock, `_config.yml`, `package.json`/`yarn.lock` (old),
      vendored `_assets/yarn/`, `bin/deploy`, `circle.yml`, `.travis.yml`, tracked `_site/`,
      `.devcontainer/`, devcontainer-only `dependabot.yml`, Codeship badge
- [x] Minitest via Bridgetown's `minitesting` configuration (smoke test for now)
- [x] `bin/ci`: local CI gate (setup, RuboCop, production build, tests); link check joins once content exists
- [x] GitHub Actions workflow on PRs and `main` that runs `bin/ci`
- [x] Decide on `gh signoff`: **not for now**. Keep local `bin/ci` (no signoff) plus GitHub Actions; revisit later

### Phase 2: content · #87
- [x] Legacy URL test first (`test/test_legacy_urls.rb`, moved here from Phase 5): red → green
- [x] `git mv` posts to `src/_posts` (history kept)
- [x] Posts are **plain Markdown** (`template_engine: none` in `src/_posts/_defaults.yml`):
      Bridgetown would otherwise run ERB over `.md` files and execute code samples like `<%= ... %>`
- [x] Scripted conversion, no prose changes: 63 `{% highlight %}` → fenced code, 2 `{{ "{{" }}` escapes
      undone, 9 `{% include image.html %}` → `![alt](/images/...){: .zooming}` (plain Markdown instead of
      an ERB component, so posts stay engine-free; zoom behaviour comes back in Phase 3)
- [x] `_my_tags/*.md` → `src/_data/tags.yml`; a Ruby builder (`plugins/builders/tag_pages.rb`) generates
      `/tag/:slug/` for **every** tag, including the 3 without posts (design, jekyll, web) that Jekyll served.
      Prototype pages were not used: they only cover tags in use and add pagination
- [x] Added the `minitest` tag (used by a post, missing from `_my_tags`: its link was a 404 on the live
      site); a test now fails when a post uses an unknown tag
- [x] Permalinks: posts `/posts/:slug.*`, tags `/tag/:slug/`, pagination `/posts/page/:num/` (4 per page)
- [x] Used images → `src/images`; dropped `*:Zone.Identifier` and Chalk sample images
      (`documentation/post_18_4_23_*` are real post images and were kept)
- [x] `about`, `tags`, `404`, `robots.txt` ported; scaffold sample pages removed

### Phase 3: templates & frontend · #89
- [x] Layouts in ERB: `default`, `post`, `tag`; home, tags, about and 404 with the Chalk markup
- [x] Ruby components: `Navigation`, `ArticleMeta` (date, reading time, tags), `Icon` (inlines the SVG
      symbols from `frontend/icons`, dropping svgxuse); the footer is a plain partial
- [x] Chalk SCSS → `frontend/styles` on Dart Sass with `@use` (no deprecation warnings), one stylesheet.
      The 15 colors that differ per theme are CSS custom properties; grays are pinned to the hex values the
      old `lighten()` build produced. Code block selectors adjusted to kramdown's markup
- [x] Theme follows `prefers-color-scheme`; the toggle stores an explicit choice in `localStorage`
      (same `theme` key as before), applied by an inline script before first paint
- [x] Vanilla JS: theme toggle, scroll-appear (`IntersectionObserver`), share popup; zoom via `zooming`
- [x] Self-hosted woff2 fonts; Google Fonts, webfontloader, jQuery, retina.js and GA UA dropped
- [x] Disqus and the Twitter share link kept (decisions deferred)
- [x] Legacy `_layouts/`, `_includes/`, `_assets/` removed (except the two deferred images)
- [x] Visual check with headless Chromium vs. the live site: pixel-identical except antialiasing in the
      logo font and two intended changes (`MINITEST` label on `/tags`, see below). All 21 colors of the
      legacy dark stylesheet are present in the dark theme
- [x] Tests: navigation, theme toggle, article meta, and reading time per post against the live values
      (`test/fixtures/reading_times.yml`). One post reads 2 minutes instead of 1: kramdown's code block
      markup adds a counted word per block, pushing it from 249 to 251

### Phase 4: plugins & metadata · #91
- [x] `bridgetown-feed` (Atom at `/feed.xml`, last 10 posts), `bridgetown-sitemap`, `bridgetown-seo-tag`
- [x] `url: https://blog.albertorocha.me`: feed, sitemap, canonical and `og:*` URLs are absolute.
      The sitemap matches the Jekyll one (posts, tag pages, about, home; no `/tags` or pagination)
      minus the `node_modules` pages; `robots.txt` points to it
- [x] Hand-written `og:*` / `twitter:*` tags replaced by seo-tag through a `seo_metadata` helper.
      The tab title keeps the Jekyll order (`Site | Page`; seo-tag renders `Page | Site`). seo-tag
      marks any page with a date as an article, and every Bridgetown resource has one (build time),
      so the helper sets `og:type` to `website` on everything but posts. `twitter:creator` needed
      the handle in `src/_data/authors.yml` (the plugin used the author's name)
- [x] Site description kept as is (`Notes, tips and tricks by Alberto Rocha.`, what the live home page
      sends); new wording waits until after parity
- [x] GA UA snippet: already removed in Phase 3 (Twitter share link kept until the share decision)
- [x] `new_post` CLI command (`plugins/commands/new_post.rb`, registered in `config/custom_commands.rb`),
      test-first: dated draft, slug from the title, refuses to overwrite
- [x] Tests parse responses as UTF-8: Nokolexbor turned non-ASCII bytes of Rack's binary body into U+FFFD
- Besides `<head>`, the only output change is the Twitter share link on posts: with `url ""` Phase 3
  shared a bare `/posts/slug` (the live site sends `blog.albertorocha.me/posts/slug`); it now shares
  the full `https://` URL. Swapping the hand-written tags for seo-tag left every `<body>` byte-identical

### Phase 5: parity verification · #93
- [x] ~~Legacy URL test~~ (done in Phase 2)
- [x] Link check: html-proofer through a `check_links` command (`plugins/commands/check_links.rb`), a step
      in `bin/ci`. Internal links, anchors, images, scripts, favicon and Open Graph URLs; URLs on
      `https://blog.albertorocha.me` are swapped back to paths, so canonical, `og:*` and the share link are
      checked against the build. External links only with `bin/bt check_links --external` (network, not CI).
      Sitemap and feed URLs are checked by `test/test_metadata.rb` (html-proofer reads HTML only)
- [x] Problems in post content are listed in `CheckLinks::KNOWN_FAILURES` instead of being fixed (no prose
      changes without approval): an empty `[Pull Request]()` link and three `http://` links. The check fails
      if a listed problem disappears, so the list shrinks when a post is fixed
- [x] Side-by-side visual comparison against the live site (home, two posts, tag, tags, about, 404), at
      1280px and 375px, light, dark stored by the toggle, dark clicked on the toggle, and dark OS (compared
      with the live toggle, since the live site ignores the OS). Screenshots through the DevTools protocol;
      the script stayed out of the repo (no baseline after cutover)
- [x] Fixed: Dart Sass rounded two derived colors one step off (code background `#faf9f9`, light link hover
      `#393636`); the CSS now has exactly the legacy color set. Light syntax colors apply under the dark
      theme too, as Chalk's `dark.css` loaded on top of `light.css` (shell prompt/output stayed gray)
- [x] Remaining differences, all explained: logo font antialiasing; `MINITEST` on `/tags`; 2-minute read on
      `asdf-ruby-no-version-set`; Rouge 4.7 (was 3.30) tokenizes `#{}` inside `%()` strings, which
      recolors parts of the code in `overwriting-pagy-navigation-helper`; text antialiasing in code blocks
      that scroll sideways (mobile) varies between runs on both sites
- Cloudflare already proxies the live site, and its Email Address Obfuscation rewrites `git@github.com` in
  two posts' code blocks into a link decoded by JavaScript. It looks the same, but see Phase 6

### Phase 6: cutover · #95
- [x] Workers static assets over Pages: Cloudflare's new features (Previews, Workers Logs) land on Workers,
      and static asset requests are free on both. Default `html_handling` (`auto-trailing-slash`) serves
      `posts/slug.html` at `/posts/slug` and `tag/x/index.html` at `/tag/x/`; `/posts/slug.html` becomes a
      307 to `/posts/slug`. `notFoundHandling: "404-page"` serves `404.html` with status 404
- [x] Build on GitHub Actions, not Workers Builds: its image defaults to Ruby 3.4 / Node 24 and doesn't use
      mise. CI builds with `BRIDGETOWN_ENV=production` after `bin/ci` (whose tests rebuild `output/` for the
      test environment) and deploys that `output/`
- [x] `cf` CLI instead of Wrangler: Cloudflare announced it as Wrangler's successor (open beta 2026-09-28;
      Wrangler gets 18 months of maintenance after the beta ends). Pinned to `1.0.0-rc.2`, an exact version,
      since it still makes breaking changes. Worker `blog` in `cloudflare.config.ts`
- [x] Workflow: preview per PR (`pr-<number>`), URL commented on the PR and checked with `check_deploy`,
      deleted on close; production on pushes to `main`. Skipped until the secrets exist (and on forks)
- [x] `check_deploy` command: every legacy URL, sitemap URL and feed link answers 200 without redirecting,
      unknown paths get the 404 page, and no page references `/cdn-cgi/` (Cloudflare rewrites). On the live
      site it flags every page: Email Address Obfuscation also rewrites the navigation's email link
- [x] Worker `blog` created by a first `cf deploy` from a local account login (creating a Worker needs
      Workers Admin); it serves `https://blog.betogrun.workers.dev`, which passes `check_deploy` and serves
      HTML byte-identical to `output/`
- [x] API token from the dashboard: `cf auth login` grants no token scopes, so the CLI can't create one.
      Scope **Specified Workers** → `blog`, permission **Individual Workers** → **Editor** (deploys and
      previews, can't create or delete Workers; the account has another Worker). Stored with the account ID
      as repository secrets
- [x] First preview (`https://pr-96-blog.betogrun.workers.dev`) deployed and checked by CI. Visual comparison
      against the live site (same pages, widths and themes as Phase 5): only the differences Phase 5 explained
- [ ] On merge: production deployed by CI and the PR's preview deleted (the token's Editor role covers
      creating previews; deleting one is untested)
- [ ] Point `blog.albertorocha.me` to Cloudflare; confirm HTTPS and all legacy URLs live
- [ ] Turn off Email Address Obfuscation (Scrape Shield) for the blog: it mangles `git@github.com` in code blocks
      and the navigation's email link; `check_deploy` on production must pass
- [ ] Only after confirming: disable GitHub Pages and delete the `gh-pages` branch
- [ ] Remove `CNAME` if no longer needed

### Phase 7: cleanup
- [ ] Delete ~30 stale remote branches
- [ ] Close the obsolete dependabot PR (#82)
- [ ] Dependabot for bundler, npm and GitHub Actions
- [ ] Rewrite `README.md`
- [ ] Decide on `_assets/images/photo4.jpg` and `post_1/new_pr.png` (the author's images, referenced nowhere)
- [ ] Remove unused `src/images/favicon-light.ico` and `apple-touch-icon-light.png` (or use them for a light-theme favicon)
- [ ] `zooming` has had no release since 2019; consider a native `<dialog>` zoom

### After parity (to discuss)
- Post links found in Phase 5 (wording changes need approval): the empty `[Pull Request]()` link in
  `publishing-ruby-gems-with-github-actions`, `http://` links, and external links that fail (see PR for #93)
- Analytics: none / Cloudflare Web Analytics / Plausible / GoatCounter
- Comments: Disqus → Giscus or none
- Share links: Twitter → Bluesky/Mastodon/LinkedIn or none
- Copy button on code blocks, light/dark syntax themes, client-side search (Pagefind), per-post OG images
- Image optimization (`src/images` is ~11 MB)
