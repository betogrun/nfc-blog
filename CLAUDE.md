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

- The legacy Jekyll setup (`_config.yml`, `_assets/`, `_layouts/`, `_includes/`,
  `_my_tags/`, `bin/deploy`) stays in the tree until Phase 1 lands. It **does not
  build** on modern Ruby and is about to be deleted, so don't spend time fixing it.
- The live site is still the Jekyll build on the `gh-pages` branch (GitHub Pages)
  until the Phase 6 cutover. The tag `legacy-jekyll-site` preserves that output.

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
4. **Before pushing**, run the local CI gate; it must be green. `bin/ci` runs the
   same steps as GitHub Actions, so a green local run means a green PR.
   *(Introduced in Phase 1; until then there is nothing to run.)*
5. **Open a PR** against `main`: `gh pr create`.
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

## Target stack (Phase 1 onward)

- Ruby 3.4 + Node LTS, pinned in `mise.toml`.
- Bridgetown 2.x with **ERB** templates and Ruby components; esbuild + Dart Sass
  for the frontend. Prefer Ruby over JavaScript where reasonable.
- No jQuery; small vanilla JS only.
- Hosting on Cloudflare with per-PR previews; production builds use
  `BRIDGETOWN_ENV=production`.
- Drafts are posts with `published: false` in front matter.

## Common commands

Available once the Phase 1 scaffold lands:

| Task                        | Command          |
| --------------------------- | ---------------- |
| Install Ruby + Node         | `mise install`   |
| Install dependencies        | `bin/setup`      |
| Dev server (live reload)    | `bin/bt start`   |
| Dev server with drafts      | `bin/bt start -U`|
| Console                     | `bin/bt console` |
| Run tests                   | `bin/bt test`    |
| Full CI gate                | `bin/ci`         |
| Production build            | `bin/bt deploy`  |
