#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the path to the configuration file
CONFIG_FILE="$HOME/.dotfiles/config.yaml"

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -c, --copy        Perform the copy operations (default behavior)"
    echo "  -l, --link        Create symbolic links instead of copying"
    echo "  -b, --backup      Backup existing files before overwriting"
    echo "  -n, --dry-run     Show what would have been done without making changes"
    echo "  -v, --verbose     Enable verbose output"
    echo "  -h, --help        Display this help message"
    exit 1
}

# Default options
ACTION="copy"
BACKUP=false
DRY_RUN=false
VERBOSE=false

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -c|--copy)
            ACTION="copy"
            shift
            ;;
        -l|--link)
            ACTION="link"
            shift
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Function for verbose logging
log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

# Function to perform copy or link
deploy() {
    local source="$1"
    local target="$2"

    # Expand environment variables in target path
    eval target="$target"

    # Check if source exists
    if [ ! -e "$source" ]; then
        echo "Source $source does not exist. Skipping."
        return
    fi

    # Create target directory if it doesn't exist
    local target_dir
    target_dir=$(dirname "$target")
    if [ ! -d "$target_dir" ]; then
        if [ "$DRY_RUN" = true ]; then
            log "Would create directory: $target_dir"
        else
            log "Creating directory: $target_dir"
            mkdir -p "$target_dir"
        fi
    fi

    # Backup existing target if necessary
    if [ "$BACKUP" = true ] && [ -e "$target" ]; then
        if [ "$DRY_RUN" = true ]; then
            log "Would backup existing file: $target to $target.backup"
        else
            log "Backing up existing file: $target to $target.backup"
            cp -a "$target" "$target.backup"
        fi
    fi

    # Perform the copy or link
    if [ "$ACTION" = "copy" ]; then
        if [ "$DRY_RUN" = true ]; then
            log "Would copy $source to $target"
        else
            log "Copying $source to $target"
            cp -a "$source" "$target"
        fi
    elif [ "$ACTION" = "link" ]; then
        if [ "$DRY_RUN" = true ]; then
            log "Would create symlink from $target to $source"
        else
            log "Creating symlink from $target to $source"
            ln -sf "$source" "$target"
        fi
    fi
}

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Read mappings from config.yaml using yq
MAPPINGS=$(yq e '.mappings' "$CONFIG_FILE")

# Iterate over each mapping
echo "$MAPPINGS" | yq e 'keys | .[]' - | while read -r key; do
    # Extract target path
    target=$(yq e ".mappings.\"$key\".target" "$CONFIG_FILE")
    # Define source path relative to .dotfiles
    source="$HOME/.dotfiles/$key"

    # Deploy the file or directory
    deploy "$source" "$target"
done

echo "Dotfiles deployment completed."

