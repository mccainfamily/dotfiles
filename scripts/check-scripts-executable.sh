#!/bin/bash
# Check that shell scripts are executable

set -e

EXIT_CODE=0

for file in "$@"; do
    if [ ! -x "$file" ]; then
        echo "Error: $file is not executable. Run: chmod +x $file"
        EXIT_CODE=1
    fi
done

exit $EXIT_CODE
