# go-template

A GitHub template repository for Go CLI tools. Includes CI/CD, release automation, security scanning, linting, and pre-push enforcement — ready in one command.

---

## What's included

| Component | Details |
|-----------|---------|
| CI | GitHub Actions: build + test on every push/PR |
| Linting | golangci-lint v2 with errcheck, staticcheck, govet, misspell |
| Release | GoReleaser — linux/amd64 and linux/arm64 on version tag |
| SAST | CodeQL on push/PR + weekly scheduled scan |
| Dependabot | Weekly PRs for Go modules and Actions version bumps |
| Branch protection | CI must pass, no force-push, no delete |
| Pre-push hook | Enforces lint + build + test before every push |
| Community files | LICENSE (MIT), SECURITY.md, CONTRIBUTING.md |

---

## How to use

### 1. Create a new repo from this template

```bash
gh repo create KrakoX/my-tool --template KrakoX/go-template --public --clone
cd my-tool
```

### 2. Run setup

```bash
bash setup.sh KrakoX/my-tool my-tool
```

`setup.sh` replaces template values (`KrakoX`, `go-template`) with your project details, installs the pre-push hook, and applies branch protection and Dependabot settings via the GitHub API.

### 3. Start building

Update `README.md`, write your code, then:

```bash
git add .
git commit -m "feat: initial commit"
git push -u origin main
```

### 4. Release

```bash
git tag v1.0.0 && git push origin v1.0.0
```

GoReleaser builds the binaries and creates the GitHub Release automatically.

---

## What setup.sh replaces

The template uses its own real values as placeholders. `setup.sh` replaces them with your project-specific values:

| Template value | Replaced with | Files |
|---------------|---------------|-------|
| `KrakoX/go-template` | `owner/repo` | go.mod, SECURITY.md |
| `go-template` | your project name | Makefile, .goreleaser.yaml, main.go, .gitignore |
| `KrakoX` | your GitHub owner | .goreleaser.yaml, LICENSE |
| copyright year | current year | LICENSE |

---

## Requirements

- Go 1.25+
- [gh CLI](https://cli.github.com) (authenticated)
- [golangci-lint](https://golangci-lint.run/welcome/install/) v2.11.3+
