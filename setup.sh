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
#   1. Replaces all {{PLACEHOLDER}} values in tracked files
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

echo "1/4 Replacing placeholders..."

# Use perl for cross-platform compatibility (macOS + Linux)
while IFS= read -r -d '' file; do
    perl -pi -e "
        s/\\{\\{PROJECT_NAME\\}\\}/$PROJECT/g;
        s/\\{\\{GITHUB_OWNER\\}\\}/$OWNER/g;
        s/\\{\\{REPO_NAME\\}\\}/$REPO_NAME/g;
        s/\\{\\{COPYRIGHT_YEAR\\}\\}/$COPYRIGHT_YEAR/g;
    " "$file"
done < <(find . -type f \( \
    -name "*.go" -o \
    -name "*.mod" -o \
    -name "*.yml" -o \
    -name "*.yaml" -o \
    -name "*.md" -o \
    -name "*.txt" -o \
    -name "Makefile" -o \
    -name "LICENSE" -o \
    -name ".gitignore" \
    \) -not -path "./.git/*" -print0)

# ── git hook ──────────────────────────────────────────────────────────────────

echo "2/4 Installing pre-push hook..."
chmod +x .githooks/pre-push
git config core.hooksPath .githooks

# ── branch protection ─────────────────────────────────────────────────────────

echo "3/4 Applying branch protection on main..."

if ! command -v gh &>/dev/null; then
    echo "  WARNING: gh CLI not found — skipping GitHub API steps."
    echo "  Install gh: https://cli.github.com"
    echo ""
    echo "--- Done (partial — no GitHub API changes applied) ---"
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
echo "  1. Review and update README.md"
echo "  2. git add . && git commit -m 'feat: initial commit'"
echo "  3. git push -u origin main"
echo "  4. When ready to release: git tag v1.0.0 && git push origin v1.0.0"
echo ""
echo "  Install golangci-lint if not already:"
echo "  curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b \$(go env GOPATH)/bin v2.11.3"
