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
