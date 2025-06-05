#!/usr/bin/env bash
set -eo pipefail

# 1. Fetch all label names on this PR
PR_ID="${1:?PR ID must be provided as first argument}"
LABELS_JSON="$(gh pr view "$PR_ID" --json labels -q '.labels[].name')"

# 2. Determine which bump label is present
#    We expect labels exactly named:
#      version-bump/major
#      version-bump/minor
#      version-bump/patch
BUMP_TYPE=""
if echo "$LABELS_JSON" | grep -qx "version-bump/major"; then
  BUMP_TYPE="major"
elif echo "$LABELS_JSON" | grep -qx "version-bump/minor"; then
  BUMP_TYPE="minor"
elif echo "$LABELS_JSON" | grep -qx "version-bump/patch"; then
  BUMP_TYPE="patch"
else
  echo "No version-bump label (major, minor, or patch) found on PR #$PR_ID."
  exit 1
fi

# 3. Read current version from package.json
CURRENT_VERSION="$(jq -r '.version' package.json)"
if [[ ! "$CURRENT_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "package.json version ('$CURRENT_VERSION') is not semver-compatible."
  exit 1
fi

# 4. Split into MAJOR, MINOR, PATCH
IFS='.' read -r MAJ MIN PATCH <<< "$CURRENT_VERSION"

# 5. Compute new version
case "$BUMP_TYPE" in
  major)
    NEW_MAJOR=$((MAJ + 1))
    NEW_VERSION="$NEW_MAJOR.0.0"
    ;;
  minor)
    NEW_MINOR=$((MIN + 1))
    NEW_VERSION="$MAJ.$NEW_MINOR.0"
    ;;
  patch)
    NEW_PATCH=$((PATCH + 1))
    NEW_VERSION="$MAJ.$MIN.$NEW_PATCH"
    ;;
esac

# 6. Emit the new version so that GitHub Actions steps can pick it up
echo "bumped_version=$NEW_VERSION" >> "$GITHUB_OUTPUT"
