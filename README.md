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

The site is a Cloudflare Worker named `blog` that serves the build in `output/` as static
assets ([`cloudflare.config.ts`](cloudflare.config.ts)). GitHub Actions deploys it with the
[`cf` CLI](https://github.com/cloudflare/cf) once `bin/ci` passes:

- **Pull requests** get a preview at `https://pr-<number>-blog.betogrun.workers.dev`. Its URL
  is commented on the PR and checked with `bin/bt check_deploy`; the preview is deleted when
  the PR closes.
- **Pushes to `main`** deploy production.

`bin/bt check_deploy <url>` checks any deploy: legacy URLs, sitemap and feed links, the 404
page, and pages rewritten by Cloudflare.

### One-time setup

1. Create the Worker. This needs an account login, since only a Workers Admin can create
   Workers:

   ```sh
   npx cf auth login
   BRIDGETOWN_ENV=production bin/bt deploy   # production build in output/
   npx cf deploy output
   ```

2. Create an API token in the Cloudflare dashboard (Manage Account → Account API Tokens →
   Create token → Start from scratch). Scope: **Specified Workers** → `blog`. Permission:
   **Individual Workers** → **Editor**, enough to deploy and preview but not to create or
   delete Workers. `cf auth login` can't create tokens: its login has no token scopes.

3. Store the token and the account ID as repository secrets:

   ```sh
   gh secret set CLOUDFLARE_API_TOKEN    # paste the token at the prompt
   gh secret set CLOUDFLARE_ACCOUNT_ID --body <id from `npx cf accounts list`>
   ```

Until both secrets exist, CI skips the deploy steps.

### Custom domain

`blog.albertorocha.me` is a Custom Domain of the Worker, attached once from a terminal and
kept out of `cloudflare.config.ts` on purpose. `cf deploy` only touches the domains the config
declares, and in CI (no terminal) it overwrites conflicting DNS records without asking; a
declared domain would also need zone permissions on the token.

To attach a domain, use the `cf auth login` session in an interactive terminal:

1. Add `domains: ["<hostname>"]` to the `worker` block of `cloudflare.config.ts`, without
   committing it. Keep `workersDev: true` and `previewUrls: true`: declaring a domain turns
   both off otherwise.
2. If the hostname already has a DNS record, delete it right before deploying. Cloudflare
   refuses to replace an existing record (`externally managed DNS records`). Get the record ID
   from `npx cf dns records list --zone <zone-id>`:

   ```sh
   npx cf dns records delete <record-id> --zone <zone-id> --force && npx cf deploy output
   ```

3. Revert the config change: `git checkout cloudflare.config.ts`.
