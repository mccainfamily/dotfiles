#!/bin/bash

################################################################################
# Git Repository Initialization Script
# Helps you set up the dotfiles repository on GitHub
################################################################################

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║           Dotfiles Git Repository Setup                       ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

cd "${DOTFILES_DIR}"

# Check if already initialized
if [[ -d .git ]]; then
    echo "⚠️  Git repository already initialized!"
    echo ""
    echo "Current remote:"
    git remote -v || echo "  No remote configured"
    echo ""

    if ! git remote -v | grep -q "origin"; then
        echo "No 'origin' remote found."
    else
        echo "Repository is already set up."
        exit 0
    fi
fi

# Prompt for GitHub username
echo "Let's set up your dotfiles repository on GitHub."
echo ""
read -p "Enter your GitHub username: " GITHUB_USERNAME

if [[ -z "$GITHUB_USERNAME" ]]; then
    echo "Error: GitHub username is required"
    exit 1
fi

REPO_URL="https://github.com/${GITHUB_USERNAME}/dotfiles.git"

echo ""
echo "Repository will be: ${REPO_URL}"
echo ""
echo "Please create this repository on GitHub first:"
echo "  1. Go to: https://github.com/new"
echo "  2. Repository name: dotfiles"
echo "  3. Description: My macOS configuration files"
echo "  4. Choose Public or Private"
echo "  5. Do NOT initialize with README, .gitignore, or license"
echo "  6. Click 'Create repository'"
echo ""

read -p "Have you created the repository on GitHub? (y/n): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo ""
    echo "Please create the repository first, then run this script again."
    exit 1
fi

echo ""
echo "Setting up local repository..."

# Initialize git if needed
if [[ ! -d .git ]]; then
    git init
    echo "✓ Git repository initialized"
fi

# Add all files
git add .
echo "✓ Files staged"

# Create initial commit
if ! git rev-parse HEAD > /dev/null 2>&1; then
    git commit -m "Initial dotfiles commit"
    echo "✓ Initial commit created"
fi

# Set up remote
if ! git remote | grep -q "origin"; then
    git remote add origin "${REPO_URL}"
    echo "✓ Remote 'origin' added"
fi

# Rename branch to main if needed
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
    git branch -M main
    echo "✓ Branch renamed to 'main'"
fi

# Push to GitHub
echo ""
echo "Pushing to GitHub..."

if git push -u origin main 2>&1 | grep -q "rejected"; then
    echo ""
    echo "⚠️  Push was rejected. This might mean:"
    echo "  1. The repository already has content"
    echo "  2. You need to authenticate"
    echo ""
    echo "Try running manually:"
    echo "  git pull origin main --allow-unrelated-histories"
    echo "  git push -u origin main"
else
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                  Setup Complete! 🎉                            ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Your dotfiles are now on GitHub:"
    echo "  ${REPO_URL}"
    echo ""
    echo "Next steps:"
    echo "  1. View your repo: https://github.com/${GITHUB_USERNAME}/dotfiles"
    echo "  2. Customize brew/Brewfile with your apps"
    echo "  3. Update config/.gitconfig with your info"
    echo "  4. Make changes and commit:"
    echo "       cd ~/.dotfiles"
    echo "       git add ."
    echo "       git commit -m 'Your message'"
    echo "       git push"
    echo ""
    echo "To install on another Mac:"
    echo "  git clone ${REPO_URL} ~/.dotfiles"
    echo "  cd ~/.dotfiles && ./install.sh"
    echo ""
fi
