#!/bin/bash
# Validate profiles.conf syntax

set -e

for file in "$@"; do
    echo "Validating $file..."

    # Source the file to check for syntax errors
    # shellcheck disable=SC1090
    if source "$file" >/dev/null 2>&1; then
        echo "✓ $file is valid"
    else
        echo "Error: $file has syntax errors"
        exit 1
    fi
done

exit 0
