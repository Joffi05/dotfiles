#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define the path to the configuration file
CONFIG_FILE="$HOME/dotfiles/config.yaml"
MANIFEST_FILE="$HOME/dotfiles/.deploy_manifest"

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

# Initialize manifest file if it doesn't exist
if [ ! -f "$MANIFEST_FILE" ]; then
    touch "$MANIFEST_FILE"
fi

# Read existing manifest into an associative array
declare -A manifest
while IFS= read -r line; do
    manifest["$line"]=1
done < "$MANIFEST_FILE"

# Function to perform copy or link with force and backup options
deploy() {
    local source="$1"
    local target="$2"

    # Expand environment variables in target path
    eval target="$target"

    # Convert source and target to absolute paths
    source="$(realpath "$source")"
    target="$(realpath -m "$target")"

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

        # Record deployed files in the manifest
        while IFS= read -r -d '' file; do
            # Compute relative path from source
            rel_path=$(realpath --relative-to="$source" "$file")
            manifest_entry="$target/$rel_path"
            manifest["$manifest_entry"]=1
        done < <(find "$source" -type f -print0)
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

        # Record deployed file in the manifest
        manifest["$target"]=1
    fi
}

# Function to delete target files that no longer exist in source
cleanup_obsolete_targets() {
    echo "Starting cleanup of obsolete target files..."

    # Iterate over manifest entries
    for target_file in "${!manifest[@]}"; do
        matched=false
        for key in "${!mapping_targets[@]}"; do
            mapping_source="${mapping_sources[$key]}"
            mapping_target="${mapping_targets[$key]}"

            if [[ "$target_file" == "$mapping_target" || "$target_file" == "$mapping_target/"* ]]; then
                rel_path="${target_file#$mapping_target/}"
                source_file="$mapping_source/$rel_path"

                if [ ! -e "$source_file" ]; then
                    if [ -e "$target_file" ]; then
                        if [ "$DRY_RUN" = true ]; then
                            log "Would remove obsolete target file: $target_file"
                        else
                            log "Removing obsolete target file: $target_file"
                            rm -rf "$target_file"
                        fi
                    fi
                    # Remove from manifest
                    unset "manifest[$target_file]"
                    log "Removed from manifest: $target_file"
                fi
                matched=true
                break
            fi
        done

        if [ "$matched" = false ]; then
            # If target_file doesn't match any mapping, remove it from manifest
            unset "manifest[$target_file]"
        fi
    done

    echo "Cleanup completed."
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

# Read mapping keys into an array to avoid subshells
readarray -t MAPPINGS_KEYS < <(yq e '.mappings | keys | .[]' "$CONFIG_FILE")

if [ "$VERBOSE" = true ]; then
    echo "Mappings found:"
    printf '%s\n' "${MAPPINGS_KEYS[@]}"
fi

# Declare associative arrays to keep track of mapping sources and targets
declare -A mapping_sources
declare -A mapping_targets

# Parse mappings and deploy
for key in "${MAPPINGS_KEYS[@]}"; do
    # Extract target path
    target=$(yq e ".mappings.\"$key\".target" "$CONFIG_FILE")
    # Define source path relative to dotfiles
    source="$HOME/dotfiles/$key"

    # Expand environment variables in target path
    eval target="$target"

    # Convert source and target to absolute paths
    source="$(realpath "$source")"
    target="$(realpath -m "$target")"

    # Store mapping
    mapping_sources["$key"]="$source"
    mapping_targets["$key"]="$target"

    # Deploy the file or directory
    deploy "$source" "$target"
done

# Perform cleanup of obsolete target files
cleanup_obsolete_targets

# Update manifest file
if [ "$DRY_RUN" = false ]; then
    # Clear manifest file
    > "$MANIFEST_FILE"
    # Write updated manifest
    for path in "${!manifest[@]}"; do
        echo "$path" >> "$MANIFEST_FILE"
    done
fi

echo "Dotfiles deployment completed."

