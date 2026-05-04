#!/usr/bin/env bash
# Publish the DFW Senior Facilities map to GitHub Pages.
#
# Prerequisites:
#   - git installed
#   - GitHub CLI ('gh') installed and authenticated:
#       brew install gh
#       gh auth login          (choose GitHub.com, HTTPS, login with web browser)
#
# Usage from this directory:
#   ./deploy.sh
#
# What it does:
#   1. Initializes git in this folder if not already a repo.
#   2. Stages and commits any changes.
#   3. Creates a public repo named 'dfw-senior-map' on your GitHub account
#      (skips this step if the repo already exists).
#   4. Pushes to the 'main' branch.
#   5. Enables GitHub Pages on main / root.
#   6. Prints the public URL.

set -euo pipefail

REPO_NAME="dfw-senior-map"
DEFAULT_BRANCH="main"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install with:  brew install gh"
  echo "Then authenticate:  gh auth login"
  echo
  echo "Or use the web-UI route documented in the README."
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in to gh. Run:  gh auth login"
  exit 1
fi

# Initialize git if needed
if [ ! -d .git ]; then
  echo "Initializing git repo..."
  git init -b "$DEFAULT_BRANCH"
fi

# Make sure we're on the default branch
current_branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ "$current_branch" != "$DEFAULT_BRANCH" ]; then
  git checkout -B "$DEFAULT_BRANCH"
fi

# Stage + commit
git add -A
if ! git diff --cached --quiet; then
  git commit -m "Update DFW senior facilities map"
else
  # Allow first push to work if there's already a commit
  git commit --allow-empty -m "Publish DFW senior facilities map" 2>/dev/null || true
fi

# Get the GitHub user
GH_USER=$(gh api user --jq '.login')
FULL_REPO="${GH_USER}/${REPO_NAME}"

# Create the repo on GitHub if it doesn't exist
if gh repo view "$FULL_REPO" >/dev/null 2>&1; then
  echo "Repo $FULL_REPO already exists on GitHub. Pushing updates..."
  # Make sure remote is set
  if ! git remote get-url origin >/dev/null 2>&1; then
    git remote add origin "https://github.com/${FULL_REPO}.git"
  fi
  git push -u origin "$DEFAULT_BRANCH"
else
  echo "Creating repo $FULL_REPO on GitHub..."
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push --description "Interactive DFW senior facilities map"
fi

# Enable GitHub Pages on main / root
echo "Enabling GitHub Pages..."
gh api -X POST "/repos/${FULL_REPO}/pages" \
  -f "source[branch]=${DEFAULT_BRANCH}" \
  -f "source[path]=/" \
  >/dev/null 2>&1 || \
gh api -X PUT "/repos/${FULL_REPO}/pages" \
  -f "source[branch]=${DEFAULT_BRANCH}" \
  -f "source[path]=/" \
  >/dev/null 2>&1 || true

# Wait a few seconds for Pages to register, then fetch the URL
sleep 3
PAGES_URL=$(gh api "/repos/${FULL_REPO}/pages" --jq '.html_url' 2>/dev/null || echo "https://${GH_USER}.github.io/${REPO_NAME}/")

cat <<EOF

================================================
DONE.

Repo:         https://github.com/${FULL_REPO}
Pages URL:    ${PAGES_URL}

GitHub Pages can take 30-90 seconds to build the first time. If you
get a 404 immediately, wait a minute and refresh.

To publish updates later, just edit index.html and re-run:
    ./deploy.sh
================================================
EOF
