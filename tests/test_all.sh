#!/usr/bin/env bash
# Repository validation tests

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ERRORS=0

fail() {
  echo "❌ $1"
  ERRORS=$((ERRORS + 1))
}

pass() {
  echo "✅ $1"
}

echo "==> Validating models/manifest.json ..."
if python3 -m json.tool models/manifest.json >/dev/null 2>&1; then
  pass "models/manifest.json is valid JSON"
else
  fail "models/manifest.json is invalid JSON"
fi

echo "==> Checking shell script syntax ..."
if bash -n scripts/convert.sh; then
  pass "scripts/convert.sh syntax is valid"
else
  fail "scripts/convert.sh has syntax errors"
fi

echo "==> Checking for removed internal files ..."
for file in NOTE_FOR_CHANNELS.md BLOG.md docs/status.md; do
  if [ -e "$file" ]; then
    fail "$file should be removed before public release"
  else
    pass "$file is absent"
  fi
done

echo "==> Checking README language split ..."
if [ -f README.md ]; then
  pass "README.md exists"
else
  fail "README.md is missing"
fi

if [ -f README.ja.md ]; then
  pass "README.ja.md exists"
else
  fail "README.ja.md is missing"
fi

echo "==> Checking for parent-repo references ('../') ..."
if grep -R "\.\./" --include="*.sh" --include="*.yml" --include="*.md" --include="*.json" . 2>/dev/null | grep -v '.git/' | grep -v 'tests/test_all.sh'; then
  fail "Found '../' references outside of tests"
else
  pass "No '../' references found"
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
  echo "All checks passed."
  exit 0
else
  echo "$ERRORS check(s) failed."
  exit 1
fi
