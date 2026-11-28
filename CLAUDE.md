# CLAUDE.md

Guidance for working in this repository.

## Project

"Reflections & Refactors", a personal tech blog by Alberto Rocha, served at
https://blog.albertorocha.me.

## Layout

- `src/`: content and templates. Posts in `src/_posts`, images in `src/images`, data
  (tags, site metadata, authors) in `src/_data`, ERB layouts, partials and Ruby components.
- `frontend/`: styles, JavaScript, fonts and SVG icons, bundled by esbuild.
- `plugins/`: Ruby builders (tag pages, SEO metadata) and CLI commands (`new_post`,
  `check_links`, `check_deploy`); `config/` holds the Bridgetown setup.
- `test/`: Minitest, with `test/fixtures/legacy_urls.txt` as the list of URLs to keep.
- The blog moved from Jekyll to Bridgetown in 2026; `docs/REVAMP_PLAN.md` records the
  decisions. The old Jekyll build stays in the `gh-pages` branch and the
  `legacy-jekyll-site` tag. Ideas deferred during the migration are tracked in issue #107.

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
- Translations (#127): a Portuguese version sits next to its original as
  `YYYY-MM-DD-<slug>.pt.md`, with the same slug and tags, and is served at `/pt/posts/<slug>`.
  Code blocks stay as in the original. The author approves every translation.
- Portuguese style: Brazilian, a little informal but correct, no slang or regional
  expressions. "Você" for the reader ("a gente" now and then); "pra" rather than "para".
  Keep the English terms Brazilian developers use (commit, branch, merge, pull request,
  deploy, workflow, job, token, secrets, tag, changelog; "a gem", feminine) and translate
  the rest (repositório, versão, testes). No enclitic pronouns ("gerá-la"): rephrase
  instead. Shorter, more direct sentences than the original are fine.

## Portuguese version

- English at the root, Portuguese under `/pt/` with the same paths, through Bridgetown's
  i18n (`available_locales` in `config/initializers.rb`). Site pages (home, tags, 404,
  feed) use `locale: multi`; the About page has `about.pt.erb`.
- Interface strings live in `src/_locales/{en,pt}.yml` and render with `t()` in templates
  (`I18n.t` in Ruby); don't hardcode interface text. Tag names that differ in Portuguese go
  under `tag_names` in `pt.yml`.
- `Locales` (`plugins/locales.rb`) gives a path in a language (`Locales.path("/tags")`), the
  posts in a language and a page's versions; use it for every internal link.
- The header's `EN · PT` selector and the `hreflang` links show only on pages that exist in
  both languages. A script in `<head>` sends a reader whose browser prefers Portuguese to the
  translation, and a language picked in the selector is saved and always wins.
- `src/feed.erb` renders one Atom feed per language (`/feed.xml`, `/pt/feed.xml`).

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
2. **Branch from the issue** so GitHub links them natively:
   `gh issue develop <issue-number> --checkout`.
3. **TDD for Ruby code** (components, plugins, commands): red → green → refactor.
   Content and styling changes are verified by the build, the link check and
   screenshots instead.
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
  at `/tag/:slug/`, pagination at `/posts/page/:num/` (8 posts a page; the Jekyll page
  numbers past the last real page forward to it, see `plugins/builders/legacy_pagination.rb`).
- **Don't rewrite post prose.** Mechanical conversions (e.g. `{% highlight %}` →
  fenced code) are fine; wording changes need the author's approval.

## Frontend

- Styles keep the Chalk SCSS structure on Dart Sass with `@use`, with a book-page look
  (#116): EB Garamond for the masthead and titles, Literata for body text, IBM Plex
  Mono for data and code, self-hosted in `frontend/fonts/`. Every color is a CSS custom
  property in `frontend/styles/_themes.scss` (paper, ink, meta, rule and the code
  palette); use `var(--name)`, and keep every text color at 4.5:1 or more on its
  background in both themes.
- A post's opening words are set in small caps by `OpeningPhrase`
  (`plugins/opening_phrase.rb`), called from the post layout.
- `@include theme(light|dark) { ... }` (in `_mixins.scss`) scopes styles to a theme:
  an explicit `data-theme` on `<html>` wins, otherwise the OS preference applies.
- Icons: `render Icon.new("name")` inlines `frontend/icons/name.svg`.
- `<head>` metadata (Open Graph, Twitter card, canonical) comes from bridgetown-seo-tag
  via the `seo_metadata` helper (`plugins/builders/seo_metadata.rb`); don't hand-write
  those tags. Site-wide values live in `src/_data/site_metadata.yml`.
- The home's subtitle, in the masthead under the name, rolls one of `taglines` (in `site_metadata.yml`) per
  visit; the first is the main subtitle and the site `description`. Keep the count a die
  size (4, 6, 8, 10, 12 or 20) and each tagline within the length `test/test_taglines.rb`
  allows. The Portuguese ones sit under `pt:` in the same file, one per English tagline.
  The Disqus shortname stays `notesfromacoder`, the old name.
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
- Never add `domains` to `cloudflare.config.ts`: the custom domain is attached outside the config,
  and a declared one makes CI overwrite DNS records without asking.

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
