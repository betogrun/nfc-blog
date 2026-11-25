# Reflections & Refactors

[![CI](https://github.com/betogrun/nfc-blog/actions/workflows/ci.yml/badge.svg)](https://github.com/betogrun/nfc-blog/actions/workflows/ci.yml)

My personal tech blog, at [blog.albertorocha.me](https://blog.albertorocha.me): notes, tips and
tricks on Ruby, Rails, Git and the tools around them.

## Stack

- [Bridgetown](https://www.bridgetownrb.com/) 2 with ERB templates and Ruby components
- Posts in plain Markdown, highlighted by Rouge
- The Chalk theme's SCSS structure on Dart Sass with a book-page look, bundled by esbuild;
  small vanilla JavaScript
- Ruby 4.0 and Node 26, pinned in `mise.toml`
- Hosted on a Cloudflare Worker as static assets

The blog ran on Jekyll from 2017 to 2026; [`docs/REVAMP_PLAN.md`](docs/REVAMP_PLAN.md) records
the migration.

## Development

```sh
mise install            # Ruby + Node from mise.toml
bin/setup               # gems + npm packages
bin/bt start            # http://localhost:4000 with live reload (-U shows drafts)
bin/bt new_post "Title" # a dated draft in src/_posts
bin/ci                  # the same checks GitHub Actions runs
```

Commands, conventions and the workflow for contributors and coding agents are in
[`CLAUDE.md`](CLAUDE.md) (`AGENTS.md` points to it).

## Deploy

GitHub Actions deploys the build in `output/` to the Worker
([`cloudflare.config.ts`](cloudflare.config.ts)) with the
[`cf` CLI](https://github.com/cloudflare/cf) once `bin/ci` passes:

- **Pull requests** get a preview, whose URL is commented on the PR and checked with
  `bin/bt check_deploy`. The preview is deleted when the PR closes.
- **Pushes to `main`** deploy production.

`bin/bt check_deploy <url>` checks any deploy: legacy URLs, sitemap and feed links, the 404
page, and pages rewritten by Cloudflare. CI needs the `CLOUDFLARE_API_TOKEN` and
`CLOUDFLARE_ACCOUNT_ID` repository secrets and skips the deploy steps without them, as it
does for Dependabot's pull requests, which run without repository secrets.
