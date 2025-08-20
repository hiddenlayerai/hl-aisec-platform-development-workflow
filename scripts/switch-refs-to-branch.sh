#!/bin/bash

# Script to temporarily switch action references to branch for testing
# This allows CI/CD to pass before v2 tag is created

BRANCH_NAME="${1:-autort-service-support}"

echo "Switching action references from @v1 to @$BRANCH_NAME..."

# Find all YAML files and replace @v1 with branch reference
find .github/workflows -name "*.yml" -type f | while read -r file; do
    if grep -q "hl-aisec-reference-actions.*@v1" "$file"; then
        echo "Updating: $file"
        # Use sed to replace @v1 with @branch
        sed -i.bak "s|hl-aisec-reference-actions/\([^@]*\)@v1|hl-aisec-reference-actions/\1@$BRANCH_NAME|g" "$file"
        rm "$file.bak"
    fi
done

# Also update individual action files
find . -name "action.yml" -path "*/action.yml" -not -path "./.github/*" | while read -r file; do
    if grep -q "hl-aisec-reference-actions.*@v1" "$file"; then
        echo "Updating: $file"
        sed -i.bak "s|hl-aisec-reference-actions/\([^@]*\)@v1|hl-aisec-reference-actions/\1@$BRANCH_NAME|g" "$file"
        rm "$file.bak"
    fi
done

echo "Done! References now point to @$BRANCH_NAME"
echo "Remember to switch back to @v1 after creating the release tag" 