#!/bin/bash

# Dotfiles Setup Script
# Sets up ZSH and symlinks configuration files to home directory

set -e  # Exit on error

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "Dotfiles Setup Script"
echo "========================================="
echo "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Function to backup existing file/directory
backup_if_exists() {
    local file="$1"
    if [ -e "$file" ] || [ -L "$file" ]; then
        echo "  Backing up existing $file"
        mkdir -p "$BACKUP_DIR"
        cp -r "$file" "$BACKUP_DIR/" 2>/dev/null || true
    fi
}

# Function to create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    backup_if_exists "$target"

    # Remove existing file/symlink
    rm -rf "$target"

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -s "$source" "$target"
    echo "  ✓ Linked $target -> $source"
}

# 1. Install and set ZSH as default shell
echo "Step 1: Setting up ZSH"
echo "----------------------------------------"

# Check if ZSH is installed
if ! command -v zsh &> /dev/null; then
    echo "ZSH not found. Installing ZSH..."

    # Detect OS and install ZSH
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update && sudo apt-get install -y zsh
        elif command -v yum &> /dev/null; then
            sudo yum install -y zsh
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y zsh
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm zsh
        else
            echo "ERROR: Could not detect package manager. Please install ZSH manually."
            exit 1
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - ZSH should be pre-installed on modern versions
        if ! command -v zsh &> /dev/null; then
            if command -v brew &> /dev/null; then
                brew install zsh
            else
                echo "ERROR: Homebrew not found. Please install ZSH manually or install Homebrew first."
                exit 1
            fi
        fi
    else
        echo "ERROR: Unsupported OS. Please install ZSH manually."
        exit 1
    fi
else
    echo "  ✓ ZSH already installed at $(which zsh)"
fi

# Set ZSH as default shell
ZSH_PATH=$(which zsh)
if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "Setting ZSH as default shell..."

    # Add ZSH to valid shells if not already there
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        echo "Adding $ZSH_PATH to /etc/shells (requires sudo)..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells > /dev/null
    fi

    # Change default shell
    echo "Changing default shell to ZSH (requires password)..."
    chsh -s "$ZSH_PATH"
    echo "  ✓ Default shell set to ZSH"
    echo "  NOTE: You'll need to log out and back in for the shell change to take effect"
else
    echo "  ✓ ZSH is already the default shell"
fi

echo ""

# 2. Create symlinks
echo "Step 2: Creating symlinks"
echo "----------------------------------------"

# Symlink .zshrc
create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"

# Symlink .tmux.conf
create_symlink "$DOTFILES_DIR/.tmux.conf" "$HOME/.tmux.conf"

# Symlink .vimrc
create_symlink "$DOTFILES_DIR/.vimrc" "$HOME/.vimrc"

# Symlink Claude Code settings
create_symlink "$DOTFILES_DIR/.claude/settings.local.json" "$HOME/.claude/settings.local.json"

# Symlink CLAUDE.md to home directory .claude folder
create_symlink "$DOTFILES_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo ""

# 3. Summary
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo "Backups saved to: $BACKUP_DIR"
    echo ""
fi

echo "Symlinks created:"
echo "  ~/.zshrc        -> $DOTFILES_DIR/.zshrc"
echo "  ~/.tmux.conf    -> $DOTFILES_DIR/.tmux.conf"
echo "  ~/.vimrc        -> $DOTFILES_DIR/.vimrc"
echo "  ~/.claude/settings.local.json -> $DOTFILES_DIR/.claude/settings.local.json"
echo "  ~/.claude/CLAUDE.md -> $DOTFILES_DIR/CLAUDE.md"
echo ""

if [ "$SHELL" != "$ZSH_PATH" ]; then
    echo "IMPORTANT: Please log out and log back in for the shell change to take effect."
    echo "Or run: exec zsh"
else
    echo "You can start using your new configuration by running: exec zsh"
fi

echo ""
echo "Done!"
