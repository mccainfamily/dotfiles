#!/bin/bash
# Check for TODO/FIXME comments (informational only, does not fail)

set -e

echo "Searching for TODO/FIXME comments..."

# Search for TODOs and FIXMEs
if grep -rn "TODO\|FIXME" \
    --include="*.sh" \
    --include="*.yaml" \
    --include="*.md" \
    --include="Makefile" \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    --exclude-dir=.pre-commit-cache \
    . 2>/dev/null; then
    echo ""
    echo "ℹ Found TODO/FIXME comments (informational only)"
fi

# Always exit 0 to make this informational only
exit 0
