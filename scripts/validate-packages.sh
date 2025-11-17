#!/bin/bash

################################################################################
# Package Validation Script
#
# Validates that all brew formulas, casks, and App Store apps specified in
# bundles are valid and available without installing them.
#
# Usage:
#   ./validate-packages.sh
################################################################################

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUNDLES_DIR="${DOTFILES_DIR}/brew/bundles"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
TOTAL_FORMULAS=0
VALID_FORMULAS=0
INVALID_FORMULAS=0

TOTAL_CASKS=0
VALID_CASKS=0
INVALID_CASKS=0

TOTAL_MAS=0
VALID_MAS=0
INVALID_MAS=0

# Arrays to store invalid packages
declare -a INVALID_FORMULA_LIST
declare -a INVALID_CASK_LIST
declare -a INVALID_MAS_LIST

log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if brew is available
if ! command -v brew >/dev/null 2>&1; then
    log_error "Homebrew not found. Please install Homebrew first."
    exit 1
fi

# Check if mas is available (optional)
MAS_AVAILABLE=0
if command -v mas >/dev/null 2>&1; then
    MAS_AVAILABLE=1
fi

log_info "Validating packages in bundles..."
echo

################################################################################
# Validate Homebrew Formulas
################################################################################

log_info "Validating Homebrew formulas..."
for brewfile in "${BUNDLES_DIR}"/*.Brewfile; do
    [[ -f "$brewfile" ]] || continue

    # Extract formula names (lines starting with 'brew "')
    while IFS= read -r line; do
        if [[ $line =~ ^brew[[:space:]]+\"([^\"]+)\" ]]; then
            formula="${BASH_REMATCH[1]}"
            ((TOTAL_FORMULAS++))

            # Show progress
            echo -n "  Checking formula $TOTAL_FORMULAS: $formula... "

            # Validate using brew info with timeout
            if timeout 10 brew info "$formula" >/dev/null 2>&1; then
                ((VALID_FORMULAS++))
                echo "✓"
            else
                ((INVALID_FORMULAS++))
                INVALID_FORMULA_LIST+=("$formula (in $(basename "$brewfile"))")
                echo "✗"
                log_error "Invalid formula: $formula (in $(basename "$brewfile"))"
            fi
        fi
    done < "$brewfile"
done

################################################################################
# Validate Homebrew Casks
################################################################################

log_info "Validating Homebrew casks..."
for brewfile in "${BUNDLES_DIR}"/*.Brewfile; do
    [[ -f "$brewfile" ]] || continue

    # Extract cask names (lines starting with 'cask "')
    while IFS= read -r line; do
        if [[ $line =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
            cask="${BASH_REMATCH[1]}"
            ((TOTAL_CASKS++))

            # Show progress
            echo -n "  Checking cask $TOTAL_CASKS: $cask... "

            # Validate using brew info --cask with timeout
            if timeout 10 brew info --cask "$cask" >/dev/null 2>&1; then
                ((VALID_CASKS++))
                echo "✓"
            else
                ((INVALID_CASKS++))
                INVALID_CASK_LIST+=("$cask (in $(basename "$brewfile"))")
                echo "✗"
                log_error "Invalid cask: $cask (in $(basename "$brewfile"))"
            fi
        fi
    done < "$brewfile"
done

################################################################################
# Validate App Store Apps
################################################################################

if [[ $MAS_AVAILABLE -eq 1 ]]; then
    log_info "Validating App Store apps..."
    for appfile in "${BUNDLES_DIR}"/*.Appfile; do
        [[ -f "$appfile" ]] || continue

        # Extract app IDs (lines starting with 'mas "')
        while IFS= read -r line; do
            if [[ $line =~ ^mas[[:space:]]+\"([^\"]+)\",[[:space:]]+id:[[:space:]]+([0-9]+) ]]; then
                app_name="${BASH_REMATCH[1]}"
                app_id="${BASH_REMATCH[2]}"
                ((TOTAL_MAS++))

                # Show progress
                echo -n "  Checking App Store app $TOTAL_MAS: $app_name (ID: $app_id)... "

                # Validate using mas info with timeout
                # mas info returns 0 if app exists, non-zero if not found
                if timeout 10 mas info "$app_id" >/dev/null 2>&1; then
                    ((VALID_MAS++))
                    echo "✓"
                else
                    ((INVALID_MAS++))
                    INVALID_MAS_LIST+=("$app_name (ID: $app_id, in $(basename "$appfile"))")
                    echo "✗"
                    log_error "Invalid App Store app: $app_name (ID: $app_id, in $(basename "$appfile"))"
                fi
            fi
        done < "$appfile"
    done
else
    log_warning "mas (Mac App Store CLI) not installed - skipping App Store validation"
    log_info "Install with: brew install mas"
fi

################################################################################
# Summary
################################################################################

echo
echo "=================================================="
echo "Package Validation Summary"
echo "=================================================="
echo

echo "Homebrew Formulas:"
echo "  Total:   $TOTAL_FORMULAS"
echo "  Valid:   $VALID_FORMULAS"
echo "  Invalid: $INVALID_FORMULAS"
echo

echo "Homebrew Casks:"
echo "  Total:   $TOTAL_CASKS"
echo "  Valid:   $VALID_CASKS"
echo "  Invalid: $INVALID_CASKS"
echo

if [[ $MAS_AVAILABLE -eq 1 ]]; then
    echo "App Store Apps:"
    echo "  Total:   $TOTAL_MAS"
    echo "  Valid:   $VALID_MAS"
    echo "  Invalid: $INVALID_MAS"
    echo
fi

# Print detailed list of invalid packages
if [[ $INVALID_FORMULAS -gt 0 ]] || [[ $INVALID_CASKS -gt 0 ]] || [[ $INVALID_MAS -gt 0 ]]; then
    echo "Invalid Packages:"
    echo

    if [[ $INVALID_FORMULAS -gt 0 ]]; then
        echo "  Formulas:"
        for formula in "${INVALID_FORMULA_LIST[@]}"; do
            echo "    - $formula"
        done
        echo
    fi

    if [[ $INVALID_CASKS -gt 0 ]]; then
        echo "  Casks:"
        for cask in "${INVALID_CASK_LIST[@]}"; do
            echo "    - $cask"
        done
        echo
    fi

    if [[ $INVALID_MAS -gt 0 ]]; then
        echo "  App Store Apps:"
        for app in "${INVALID_MAS_LIST[@]}"; do
            echo "    - $app"
        done
        echo
    fi

    echo "=================================================="
    log_error "Validation failed - invalid packages found"
    exit 1
else
    echo "=================================================="
    log_success "All packages are valid!"
    exit 0
fi
