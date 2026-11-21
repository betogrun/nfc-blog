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
| Hosting | **Cloudflare** (DNS already there) | Per-PR preview deployments. Choose Pages vs. Workers static assets at Phase 6. |
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
- [ ] Decide on `photo4.jpg` and `post_1/new_pr.png`: the author's images, referenced nowhere,
      left in `_assets/images`

### Phase 3: templates & frontend
- [ ] Layouts → ERB (`default`, `post`, tag archive)
- [ ] Components: `Navigation`, `Footer`, `ArticleMeta`, `Figure`, `Icon`
- [ ] SCSS → `frontend/styles`; one stylesheet with `[data-theme]` variables
- [ ] Vanilla JS: theme toggle, scroll-appear, image zoom
- [ ] Self-hosted fonts

### Phase 4: plugins & metadata
- [ ] `bridgetown-feed` (`/feed.xml`), `bridgetown-sitemap`, `bridgetown-seo-tag`
- [ ] `url: https://blog.albertorocha.me`; real site description
- [ ] Remove the GA UA snippet (keep the Twitter share link until the share decision is made)
- [ ] Custom `new_post` CLI command in `plugins/commands/`, test-first

### Phase 5: parity verification
- [x] ~~Legacy URL test~~ (done in Phase 2)
- [ ] Link check (lychee or html-proofer)
- [ ] Side-by-side visual comparison against the live site (home, post, tag, tags, about, 404, both themes)

### Phase 6: cutover
- [ ] Cloudflare project (Pages or Workers static assets) with production on `main` and PR previews
- [ ] Build with the same Ruby/Node as local (`mise`); `BRIDGETOWN_ENV=production`
- [ ] Point `blog.albertorocha.me` to Cloudflare; confirm HTTPS and all legacy URLs live
- [ ] Only after confirming: disable GitHub Pages and delete the `gh-pages` branch
- [ ] Remove `CNAME` if no longer needed

### Phase 7: cleanup
- [ ] Delete ~30 stale remote branches
- [ ] Close the obsolete dependabot PR (#82)
- [ ] Dependabot for bundler, npm and GitHub Actions
- [ ] Rewrite `README.md`

### After parity (to discuss)
- Analytics: none / Cloudflare Web Analytics / Plausible / GoatCounter
- Comments: Disqus → Giscus or none
- Share links: Twitter → Bluesky/Mastodon/LinkedIn or none
- Copy button on code blocks, light/dark syntax themes, client-side search (Pagefind), per-post OG images
- Image optimization (`src/images` is ~11 MB)
