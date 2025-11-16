#!/bin/bash
# Validate Brewfile syntax

set -e

EXIT_CODE=0

for file in "$@"; do
    echo "Checking $file..."

    # Check if file is not empty
    if [ ! -s "$file" ]; then
        echo "Warning: $file is empty"
        continue
    fi

    # Check if file contains valid Brewfile commands
    if ! grep -q "^\(brew\|cask\|tap\|mas\|#\)" "$file"; then
        echo "Error: $file does not appear to be a valid Brewfile"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
