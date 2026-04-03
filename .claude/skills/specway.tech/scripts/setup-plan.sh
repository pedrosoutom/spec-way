#!/usr/bin/env bash

set -e

# Parse command line arguments
JSON_MODE=false
TEMPLATE_PATH=""
ARGS=()

i=1
while [ $i -le $# ]; do
    arg="${!i}"
    case "$arg" in
        --json)
            JSON_MODE=true
            ;;
        --template)
            i=$((i + 1))
            TEMPLATE_PATH="${!i}"
            ;;
        --help|-h)
            echo "Usage: $0 [--json] [--template <path>]"
            echo "  --json            Output results in JSON format"
            echo "  --template <path> Path to plan template file"
            echo "  --help            Show this help message"
            exit 0
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
    i=$((i + 1))
done

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../specway.product/scripts/common.sh"

# Get all paths and variables from common functions
_paths_output=$(get_feature_paths) || { echo "ERROR: Failed to resolve feature paths" >&2; exit 1; }
eval "$_paths_output"
unset _paths_output

# Check if we're on a proper feature branch (only for git repos)
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Ensure the feature directory exists
mkdir -p "$FEATURE_DIR"

# Copy plan template if it exists
if [[ -n "$TEMPLATE_PATH" ]] && [[ -f "$TEMPLATE_PATH" ]]; then
    cp "$TEMPLATE_PATH" "$IMPL_TECH"
    echo "Copied plan template to $IMPL_TECH"
else
    echo "Warning: Plan template not found"
    # Create a basic plan file if template doesn't exist
    touch "$IMPL_TECH"
fi

# Output results
if $JSON_MODE; then
    if has_jq; then
        jq -cn \
            --arg feature_product "$FEATURE_PRODUCT" \
            --arg impl_tech "$IMPL_TECH" \
            --arg specs_dir "$FEATURE_DIR" \
            --arg branch "$CURRENT_BRANCH" \
            --arg has_git "$HAS_GIT" \
            '{FEATURE_PRODUCT:$feature_product,IMPL_TECH:$impl_tech,SPECS_DIR:$specs_dir,BRANCH:$branch,HAS_GIT:$has_git}'
    else
        printf '{"FEATURE_PRODUCT":"%s","IMPL_TECH":"%s","SPECS_DIR":"%s","BRANCH":"%s","HAS_GIT":"%s"}\n' \
            "$(json_escape "$FEATURE_PRODUCT")" "$(json_escape "$IMPL_TECH")" "$(json_escape "$FEATURE_DIR")" "$(json_escape "$CURRENT_BRANCH")" "$(json_escape "$HAS_GIT")"
    fi
else
    echo "FEATURE_PRODUCT: $FEATURE_PRODUCT"
    echo "IMPL_TECH: $IMPL_TECH"
    echo "SPECS_DIR: $FEATURE_DIR"
    echo "BRANCH: $CURRENT_BRANCH"
    echo "HAS_GIT: $HAS_GIT"
fi

