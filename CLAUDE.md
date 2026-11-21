# CLAUDE.md

Guidance for working in this repository.

## Project

"Notes from a coder", a personal tech blog by Alberto Rocha, served at
https://blog.albertorocha.me.

## Current state: mid-migration

The blog is being migrated from **Jekyll 3.9 + Chalk theme** to **Bridgetown 2.x**.
The plan, decisions and phase checklist live in
[`docs/REVAMP_PLAN.md`](docs/REVAMP_PLAN.md). Read it before starting migration
work and keep its checkboxes up to date in the same PR that completes them.

- The Bridgetown site lives in `src/` (content, layouts, components), `frontend/`
  (styles, JS, fonts, icons), `config/` and `plugins/`.
- `_assets/images/` only holds two unused images whose fate is deferred to cleanup.
- Since 2026-11-21 the live site is the Bridgetown build on Cloudflare. The old Jekyll
  build on the `gh-pages` branch (GitHub Pages) stays until the end of Phase 6; the tag
  `legacy-jekyll-site` preserves it.

## Writing posts

- Start a post with `bin/bt new_post "Title"`: it creates
  `src/_posts/YYYY-MM-DD-<slug>.md` as a draft. The slug is derived from the title
  and becomes the permanent URL, so rename the file for a shorter slug before
  publishing.
- Posts live in `src/_posts/YYYY-MM-DD-slug.md` and are served at `/posts/slug`.
- Posts are **plain Markdown**: `src/_posts/_defaults.yml` sets
  `template_engine: none`, so ERB or Liquid in a post renders as text. That keeps
  code samples (`<%= ... %>`, `${{ secrets.X }}`) safe without escaping. Don't
  add template tags or components to posts.
- Code: fenced blocks with a language (```` ```ruby ````). Images:
  `![alt](/images/<folder>/<file>.png){: .zooming}` with the file in `src/images/`.
  Links opening a new tab: `[text](url){:target="_blank"}`.
- Every tag in a post's `tags:` needs an entry in `src/_data/tags.yml` (slug →
  display name); a test fails otherwise. Each tag gets a `/tag/<slug>/` page.
- Drafts: `published: false` in front matter; preview with `bin/bt start -U`.

## Language

All code, comments, documentation, posts, commit messages, issues, and pull
requests are written in **English**. Conversations with the author may happen in
Portuguese.

## PR and commit style

- Do not mention Claude Code or add `Co-Authored-By` trailers in commit messages
  or PR bodies.
- Small, frequent commits with a short imperative subject (e.g. "Fix broken
  link"); body optional.
- PR bodies reference the issue with `Closes #<number>`.

## Development workflow

Work is issue-driven, and Ruby code is written test-first.

1. **Issue first.** Every change starts as a GitHub issue: `gh issue create`.
   During the migration, create the issue for the next phase only after the
   current one is merged, so the plan can change based on what each phase teaches.
2. **Branch from the issue** so GitHub links them natively:
   `gh issue develop <issue-number> --checkout`.
3. **TDD for Ruby code** (components, plugins, commands): red → green → refactor.
   Content and styling changes are verified by the build and the parity checks
   instead.
4. **Before pushing**, run the local CI gate; it must be green. GitHub Actions
   runs the same `bin/ci`, so a green local run means a green PR.
5. **Open a PR** against `main`: `gh pr create`. CI deploys a preview of the PR to
   Cloudflare, comments its URL on the PR and runs `check_deploy` against it.
6. **Merge** once CI is green. Merging, pushing to `main`, deleting branches, and
   anything touching DNS or hosting are done only when the author asks.

## Hard rules

- **Preserve URLs.** Every path in `test/fixtures/legacy_urls.txt` must keep
  resolving: they are indexed by search engines and linked from elsewhere, and a
  broken link loses both. Posts live at `/posts/:slug` (no trailing slash), tags
  at `/tag/:slug/`, pagination at `/posts/page/:num/`.
- **No visual changes before parity.** The migrated site must look identical to
  the live one. Mixing a redesign into the migration makes regressions impossible
  to tell apart from intended changes; improvements come after cutover.
- **Don't rewrite post prose.** Mechanical conversions (e.g. `{% highlight %}` →
  fenced code) are fine; wording changes need the author's approval.

## Frontend

- Styles are the Chalk SCSS on Dart Sass with `@use`. Colors that change per theme
  are CSS custom properties defined in `frontend/styles/_themes.scss`; use
  `var(--name)` for them and the `$gray-*` variables for fixed colors.
- `@include theme(light|dark) { ... }` (in `_mixins.scss`) scopes styles to a theme:
  an explicit `data-theme` on `<html>` wins, otherwise the OS preference applies.
- Icons: `render Icon.new("name")` inlines `frontend/icons/name.svg`.
- `<head>` metadata (Open Graph, Twitter card, canonical) comes from bridgetown-seo-tag
  via the `seo_metadata` helper (`plugins/builders/seo_metadata.rb`); don't hand-write
  those tags. Site-wide values live in `src/_data/site_metadata.yml`.
- Visual checks: headless Chromium screenshots of `bin/bt start`; simulate the dark
  OS setting with `--blink-settings=preferredColorScheme=0`.

## Stack

- Ruby 4.0 + Node 26 LTS, pinned in `mise.toml`.
- Plain RuboCop with `rubocop-minitest` (`.rubocop.yml`); not Rails omakase.
- Bridgetown 2.x with **ERB** templates and Ruby components; esbuild + Dart Sass
  for the frontend. Prefer Ruby over JavaScript where reasonable.
- No jQuery; small vanilla JS only.
- Hosting: a Cloudflare Worker (`blog`) serving `output/` as static assets, configured in
  `cloudflare.config.ts`. GitHub Actions builds with `BRIDGETOWN_ENV=production` after
  `bin/ci` and deploys with the `cf` CLI (Wrangler's successor, pinned to an exact version
  while it is pre-1.0): a preview per PR (`pr-<number>`, deleted on close) and production
  on pushes to `main`. Secrets: `CLOUDFLARE_API_TOKEN`, `CLOUDFLARE_ACCOUNT_ID`.
- The custom domain `blog.albertorocha.me` is attached to the Worker outside the config. Never
  add `domains` to `cloudflare.config.ts`: CI would then overwrite DNS records without asking.

## Common commands

| Task                        | Command          |
| --------------------------- | ---------------- |
| Install Ruby + Node         | `mise install`   |
| Install dependencies        | `bin/setup`      |
| Dev server (live reload)    | `bin/bt start`   |
| Dev server with drafts      | `bin/bt start -U`|
| New draft post              | `bin/bt new_post "Title"` |
| Console                     | `bin/bt console` |
| Run tests                   | `bin/bt test`    |
| Lint (autofix: `-a`)        | `bin/rubocop`    |
| Link check (`--external` adds outside links) | `bin/bt check_links` |
| Full CI gate                | `bin/ci`         |
| Production build            | `bin/bt deploy`  |
| Check a deployed site       | `bin/bt check_deploy <url>` |
