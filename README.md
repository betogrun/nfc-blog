# Notes from a coder

[![CI](https://github.com/betogrun/nfc-blog/actions/workflows/ci.yml/badge.svg)](https://github.com/betogrun/nfc-blog/actions/workflows/ci.yml)

My personal blog at [blog.albertorocha.me](https://blog.albertorocha.me), being migrated from
[Jekyll](https://jekyllrb.com/) + [Chalk](https://github.com/nielsenramon/chalk) to
[Bridgetown](https://www.bridgetownrb.com/). See [`docs/REVAMP_PLAN.md`](docs/REVAMP_PLAN.md).

## Development

```sh
mise install     # Ruby + Node from mise.toml
bin/setup        # gems + npm packages
bin/bt start     # http://localhost:4000 with live reload
bin/ci           # the same checks GitHub Actions runs
```

Commands, conventions and the workflow for contributors and coding agents are in
[`CLAUDE.md`](CLAUDE.md) (`AGENTS.md` points to it).

## Deploy

The site is a Cloudflare Worker that serves the build in `output/` as static assets
([`cloudflare.config.ts`](cloudflare.config.ts)). GitHub Actions deploys it with the
[`cf` CLI](https://github.com/cloudflare/cf) once `bin/ci` passes:

- **Pull requests** get a preview, whose URL is commented on the PR and checked with
  `bin/bt check_deploy`. The preview is deleted when the PR closes.
- **Pushes to `main`** deploy production.

`bin/bt check_deploy <url>` checks any deploy: legacy URLs, sitemap and feed links, the 404
page, and pages rewritten by Cloudflare. CI needs the `CLOUDFLARE_API_TOKEN` and
`CLOUDFLARE_ACCOUNT_ID` repository secrets and skips the deploy steps without them.
