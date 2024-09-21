#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the path to the configuration file
CONFIG_FILE="$HOME/dotfiles/config.yaml"

# Function to display usage information
usage() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -c, --copy        Perform the copy operations (default behavior)"
    echo "  -l, --link        Create symbolic links instead of copying"
    echo "  -f, --force       Force overwrite of existing files or links"
    echo "  -b, --backup      Backup existing files before overwriting"
    echo "  -n, --dry-run     Show what would have been done without making changes"
    echo "  -v, --verbose     Enable verbose output"
    echo "  -h, --help        Display this help message"
    exit 1
}

# Default options
ACTION="copy"
FORCE=false
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
        -f|--force)
            FORCE=true
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

# Function to perform copy or link with force and backup options
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

    # Determine if source is a directory
    if [ -d "$source" ]; then
        # Ensure target directory exists
        if [ ! -d "$target" ]; then
            if [ "$DRY_RUN" = true ]; then
                log "Would create directory: $target"
            else
                log "Creating directory: $target"
                mkdir -p "$target"
            fi
        fi

        # Copy contents of the source directory to the target directory
        if [ "$DRY_RUN" = true ]; then
            log "Would copy contents of $source to $target"
        else
            log "Copying contents of $source to $target"
            cp -a "$source/." "$target/"
        fi
    else
        # Handle files

        # If force is enabled and target exists, remove it
        if [ "$FORCE" = true ] && [ -e "$target" ]; then
            if [ "$DRY_RUN" = true ]; then
                log "Would remove existing file/link: $target"
            else
                log "Removing existing file/link: $target"
                rm -rf "$target"
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
    fi
}

# Check if configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file $CONFIG_FILE not found!"
    exit 1
fi

# Read mappings from config.yaml using yq
if [ "$VERBOSE" = true ]; then
    echo "Reading configuration from $CONFIG_FILE"
fi

MAPPINGS=$(yq e '.mappings' "$CONFIG_FILE")

if [ "$VERBOSE" = true ]; then
    echo "Mappings found:"
    echo "$MAPPINGS"
fi

# Iterate over each mapping
echo "$MAPPINGS" | yq e 'keys | .[]' - | while read -r key; do
    # Extract target path
    target=$(yq e ".mappings.\"$key\".target" "$CONFIG_FILE")
    # Define source path relative to dotfiles
    source="$HOME/dotfiles/$key"

    # Deploy the file or directory
    deploy "$source" "$target"
done

echo "Dotfiles deployment completed."

