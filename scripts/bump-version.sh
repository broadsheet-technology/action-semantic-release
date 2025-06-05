#!/usr/bin/env bash
set -eo pipefail

PR_ID="${1:?Usage: $0 <pr-id>}"

# 1) Get all label names on the PR (one per line).
LABELS="$(gh pr view "$PR_ID" --json labels -q '.labels[].name')"

# 2) Determine which bump label is present.
BUMP_TYPE=""
if echo "$LABELS" | grep -qx "version-bump/major"; then
  BUMP_TYPE="major"
elif echo "$LABELS" | grep -qx "version-bump/minor"; then
  BUMP_TYPE="minor"
elif echo "$LABELS" | grep -qx "version-bump/patch"; then
  BUMP_TYPE="patch"
else
  echo "ERROR: no version-bump/major, version-bump/minor, or version-bump/patch label found on PR #$PR_ID."
  exit 1
fi

# 3) Read current version from package.json (e.g. "v0.1.18" or "0.1.18")
RAW_VERSION="$(jq -r '.version' package.json)"

# 4) Strip leading 'v' if present
if [[ "$RAW_VERSION" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  BARE_VERSION="${BASH_REMATCH[1]}"
  PREFIX="v"
elif [[ "$RAW_VERSION" =~ ^([0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
  BARE_VERSION="${BASH_REMATCH[1]}"
  PREFIX=""
else
  echo "ERROR: package.json version ('$RAW_VERSION') is not semver-compatible (expected x.y.z or vx.y.z)."
  exit 1
fi

# 5) Split bare version into MAJOR, MINOR, PATCH
IFS='.' read -r MAJ MIN PATCH <<< "$BARE_VERSION"

# 6) Compute the new bump
case "$BUMP_TYPE" in
  major)
    NEW_MAJ=$((MAJ + 1))
    NEW_VER="${NEW_MAJ}.0.0"
    ;;
  minor)
    NEW_MIN=$((MIN + 1))
    NEW_VER="${MAJ}.${NEW_MIN}.0"
    ;;
  patch)
    NEW_PAT=$((PATCH + 1))
    NEW_VER="${MAJ}.${MIN}.${NEW_PAT}"
    ;;
esac

# 7) Prepend the original prefix (e.g. "v") and export
NEW_FULL_VERSION="${PREFIX}${NEW_VER}"
echo "bumped_version=$NEW_FULL_VERSION" >> "$GITHUB_OUTPUT"
