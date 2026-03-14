# Contributing

## Prerequisites

- Go 1.25+
- [golangci-lint](https://golangci-lint.run/welcome/install/) v2.11.3+
- [goreleaser](https://goreleaser.com/install/) (for release testing only)

## Setup after cloning

```bash
make hooks   # installs the pre-push hook (lint + build + test)
```

## Development workflow

```bash
make build   # build binary for current OS/arch
make test    # run tests
make lint    # run linter
make check   # run full checklist (lint + build + test)
```

## Before pushing

The pre-push hook runs automatically:
1. `golangci-lint config verify`
2. `golangci-lint run`
3. `go build`
4. `go test`

All must pass. Fix issues before pushing.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | When to use |
|--------|-------------|
| `feat:` | new feature |
| `fix:` | bug fix |
| `refactor:` | code change with no behavior change |
| `test:` | adding or updating tests |
| `docs:` | documentation only |
| `chore:` | dependency updates, tooling |
| `sec:` | security fix or hardening |

## Pull requests

- Branch from `main`
- Keep PRs focused — one logical change per PR
- CI (Test + Lint) must pass before merge

## Releasing

Tag a version to trigger GoReleaser:

```bash
git tag v1.0.0 && git push origin v1.0.0
```

GoReleaser builds linux/amd64 and linux/arm64 binaries and creates a GitHub Release automatically.
