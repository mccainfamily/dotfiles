# Makefile for Dotfiles Repository
# Initialize developer environment and manage development tasks

.PHONY: help init install-deps install-hooks check test clean validate-brewfiles validate-scripts validate-packages

# Default target
.DEFAULT_GOAL := help

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Setup

init: install-deps install-hooks ## Initialize developer environment (install deps + hooks)
	@echo "✓ Developer environment initialized successfully!"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Review and customize bundle configurations in brew/bundles/"
	@echo "  2. Run 'make check' to validate all files"
	@echo ""
	@echo "To install applications for your system:"
	@echo "  bash scripts/install-apps.sh --list-profiles"
	@echo "  bash scripts/install-apps.sh --list-bundles"
	@echo "  bash scripts/install-apps.sh --profile <name>"
	@echo "  bash scripts/install-apps.sh --bundles \"<list>\""

install-deps: ## Install development dependencies (pre-commit, shellcheck, etc.)
	@echo "Installing development dependencies..."
	@echo ""
	@# Check if Homebrew is installed, install if not
	@if ! command -v brew >/dev/null 2>&1; then \
		echo "Homebrew not found. Installing..."; \
		bash scripts/single-user-homebrew-install.sh || exit 1; \
	else \
		echo "✓ Homebrew is installed"; \
	fi
	@echo ""
	@# Install dotfiles-dev bundle using install-apps.sh
	@echo "Installing dotfiles-dev bundle..."
	@bash scripts/install-apps.sh --bundles "dotfiles-dev"
	@echo ""
	@echo "✓ All development dependencies installed"

install-hooks: ## Install pre-commit git hooks
	@echo "Installing pre-commit hooks..."
	@pre-commit install
	@pre-commit install --hook-type commit-msg
	@echo "✓ Pre-commit hooks installed"

##@ Validation & Testing

check: validate-brewfiles validate-scripts validate-yaml ## Run all validation checks (skip package validation by default)
	@echo ""
	@echo "✓ All validation checks passed!"
	@echo ""
	@echo "Note: Package validation skipped (takes several minutes)."
	@echo "Run 'make validate-packages' to validate all brew formulas, casks, and App Store apps."

validate-brewfiles: ## Validate all Brewfile syntax
	@echo "Validating Brewfiles..."
	@for file in brew/bundles/*.Brewfile; do \
		if [ -f "$$file" ]; then \
			echo "  Checking $$file..."; \
			if ! grep -q "^\(brew\|cask\|tap\|mas\)" "$$file" && [ -s "$$file" ]; then \
				echo "  ✗ Error: $$file does not appear to be a valid Brewfile"; \
				exit 1; \
			fi; \
		fi; \
	done
	@echo "✓ All Brewfiles are valid"

validate-scripts: ## Validate shell scripts (syntax and shellcheck)
	@echo "Validating shell scripts..."
	@for file in brew/bundles/*.sh scripts/*.sh; do \
		if [ -f "$$file" ]; then \
			echo "  Checking $$file..."; \
			if [ ! -x "$$file" ]; then \
				echo "  ✗ Warning: $$file is not executable"; \
			fi; \
			bash -n "$$file" || exit 1; \
			if command -v shellcheck >/dev/null 2>&1; then \
				shellcheck -S warning "$$file" || exit 1; \
			fi; \
		fi; \
	done
	@echo "✓ All shell scripts are valid"

validate-yaml: ## Validate YAML files
	@echo "Validating YAML files..."
	@if command -v yamllint >/dev/null 2>&1; then \
		yamllint -d "{extends: default, rules: {line-length: {max: 120}, comments: {min-spaces-from-content: 1}}}" .pre-commit-config.yaml || exit 1; \
	else \
		echo "  ⚠ yamllint not installed, skipping YAML validation"; \
	fi
	@echo "✓ YAML files are valid"

validate-packages: ## Validate brew formulas, casks, and App Store apps
	@echo "Validating packages..."
	@bash scripts/validate-packages.sh

test: check ## Run all tests (alias for 'check')

##@ Pre-commit

pre-commit-run: ## Run pre-commit hooks on all files
	@pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks to latest versions
	@pre-commit autoupdate

##@ Maintenance

fix-permissions: ## Fix script file permissions
	@echo "Fixing file permissions..."
	@chmod +x brew/bundles/*.sh 2>/dev/null || true
	@chmod +x scripts/*.sh 2>/dev/null || true
	@echo "✓ File permissions fixed"

clean: ## Clean up temporary files and caches
	@echo "Cleaning up temporary files..."
	@find . -name ".DS_Store" -delete 2>/dev/null || true
	@find . -name "*.pyc" -delete 2>/dev/null || true
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@rm -rf .pytest_cache 2>/dev/null || true
	@echo "✓ Cleanup complete"

update-secrets-baseline: ## Update the secrets baseline (run after adding legitimate secrets)
	@echo "Updating secrets baseline..."
	@detect-secrets scan --baseline .secrets.baseline
	@echo "✓ Secrets baseline updated"

##@ Git Hooks

git-hooks-test: ## Test git hooks without committing
	@echo "Testing git hooks..."
	@pre-commit run --all-files --verbose
