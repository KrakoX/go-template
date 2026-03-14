#!/usr/bin/env bash
# setup.sh — run once after cloning this template to wire up a new project.
#
# Usage:
#   bash setup.sh <github-owner>/<repo-name> <project-name>
#
# Example:
#   bash setup.sh KrakoX/my-tool my-tool
#
# What it does:
#   1. Replaces template values (KrakoX/go-template) with your project details
#   2. Installs the pre-push git hook
#   3. Applies GitHub branch protection via gh CLI
#   4. Enables Dependabot alerts and security updates via gh CLI
#
# Requirements:
#   - gh CLI authenticated (gh auth status)
#   - git remote origin already pointing at the new repo

set -euo pipefail

# ── args ─────────────────────────────────────────────────────────────────────

REPO="${1:-}"
PROJECT="${2:-}"

if [[ -z "$REPO" || -z "$PROJECT" ]]; then
    echo "Usage: bash setup.sh <owner>/<repo> <project-name>"
    echo "Example: bash setup.sh KrakoX/my-tool my-tool"
    exit 1
fi

OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"
COPYRIGHT_YEAR="$(date +%Y)"

echo "--- Setting up: $PROJECT ($REPO) ---"

# ── placeholder replacement ───────────────────────────────────────────────────
# The template uses its own real values as placeholders.
# We replace them with your project-specific values.

echo "1/4 Replacing template values..."

# go.mod: module path
perl -pi -e "s|github\.com/KrakoX/go-template|github.com/$OWNER/$REPO_NAME|g" go.mod

# .goreleaser.yaml: project name, binary name, owner, repo
perl -pi -e "
    s/^project_name: go-template\$/project_name: $PROJECT/;
    s/^  - id: go-template\$/  - id: $PROJECT/;
    s/^    binary: go-template\$/    binary: $PROJECT/;
    s/^    owner: KrakoX\$/    owner: $OWNER/;
    s/^    name: go-template\$/    name: $REPO_NAME/;
" .goreleaser.yaml

# Makefile: binary name
perl -pi -e "s/^BINARY  := go-template\$/BINARY  := $PROJECT/" Makefile

# main.go: binary name in version string
perl -pi -e "s/go-template version/$PROJECT version/" main.go

# .gitignore: binary name
perl -pi -e "
    s/^go-template\$/$PROJECT/;
    s/^go-template-\*\$/${PROJECT}-*/;
" .gitignore

# SECURITY.md: advisory URL
perl -pi -e "s|KrakoX/go-template|$OWNER/$REPO_NAME|g" SECURITY.md

# LICENSE: copyright year and owner
perl -pi -e "
    s/Copyright \(c\) \d{4} KrakoX/Copyright (c) $COPYRIGHT_YEAR $OWNER/;
" LICENSE

# ── git hook ──────────────────────────────────────────────────────────────────

echo "2/4 Installing pre-push hook..."
chmod +x .githooks/pre-push
git config core.hooksPath .githooks

# ── branch protection ─────────────────────────────────────────────────────────

echo "3/4 Applying branch protection on main..."

if ! command -v gh &>/dev/null; then
    echo "  WARNING: gh CLI not found — skipping GitHub API steps."
    echo "  Install gh: https://cli.github.com"
    _print_next_steps
    exit 0
fi

gh api "repos/$REPO/branches/main/protection" \
    --method PUT \
    --header "Accept: application/vnd.github+json" \
    --input - <<EOF
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Test", "Lint"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": null,
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "block_creations": false,
  "required_conversation_resolution": true
}
EOF

# ── dependabot ────────────────────────────────────────────────────────────────

echo "4/4 Enabling Dependabot..."
gh api "repos/$REPO/vulnerability-alerts" --method PUT --silent
gh api "repos/$REPO/automated-security-fixes" --method PUT --silent

# ── next steps ────────────────────────────────────────────────────────────────

echo ""
echo "--- Done. Next steps: ---"
echo ""
echo "  1. Update README.md with your project description"
echo "  2. git add . && git commit -m 'feat: initial commit'"
echo "  3. git push -u origin main"
echo "  4. When ready to release: git tag v1.0.0 && git push origin v1.0.0"
echo ""
echo "  Install golangci-lint if not already:"
echo "  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$(go env GOPATH)/bin v2.11.3"
