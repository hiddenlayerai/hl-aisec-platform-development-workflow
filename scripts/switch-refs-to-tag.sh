#!/bin/bash

# Script to switch action references back to version tag
# Use this after creating the release tag

TAG_NAME="${1:-v2}"
BRANCH_NAME="${2:-autort-service-support}"

echo "Switching action references from @$BRANCH_NAME to @$TAG_NAME..."

# Find all YAML files and replace branch reference with tag
find .github/workflows -name "*.yml" -type f | while read -r file; do
    if grep -q "hl-aisec-reference-actions.*@$BRANCH_NAME" "$file"; then
        echo "Updating: $file"
        sed -i.bak "s|hl-aisec-reference-actions/\([^@]*\)@$BRANCH_NAME|hl-aisec-reference-actions/\1@$TAG_NAME|g" "$file"
        rm "$file.bak"
    fi
done

# Also update individual action files
find . -name "action.yml" -path "*/action.yml" -not -path "./.github/*" | while read -r file; do
    if grep -q "hl-aisec-reference-actions.*@$BRANCH_NAME" "$file"; then
        echo "Updating: $file"
        sed -i.bak "s|hl-aisec-reference-actions/\([^@]*\)@$BRANCH_NAME|hl-aisec-reference-actions/\1@$TAG_NAME|g" "$file"
        rm "$file.bak"
    fi
done

echo "Done! References now point to @$TAG_NAME" 