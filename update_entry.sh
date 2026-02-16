#!/bin/bash

chown -R www-data:www-data /var/www/
# update_json_files.sh - Update app.js with JSON filenames from info folder

INFO_DIR="./info"
APP_JS="./app.js"

# Check if info directory exists
if [ ! -d "$INFO_DIR" ]; then
    echo "❌ Error: $INFO_DIR directory not found."
    exit 1
fi

# Check if app.js exists
if [ ! -f "$APP_JS" ]; then
    echo "❌ Error: $APP_JS file not found."
    exit 1
fi

# Collect all .json files from info directory
shopt -s nullglob
json_files=("$INFO_DIR"/*.json)
shopt -u nullglob

if [ ${#json_files[@]} -eq 0 ]; then
    echo "⚠️  Warning: No .json files found in $INFO_DIR."
    new_array="const jsonFiles = [];"
else
    # Build the new array content
    new_array="const jsonFiles = ["
    for file in "${json_files[@]}"; do
        filename=$(basename "$file")
        new_array+=$'\n    '"'$filename',"
    done
    # Remove trailing comma and close bracket
    new_array="${new_array%,}"
    new_array+=$'\n];'
fi

# Escape the new array for safe use in sed
escaped_array=$(printf '%s\n' "$new_array" | sed 's:[\/&]:\\&:g;$!s/$/\\/')

# Replace the old jsonFiles array block in app.js
# Match from "const jsonFiles = [" line to the next "];" line
sed -i.bak -e "/^[[:space:]]*const jsonFiles = \[/,/^[[:space:]]*\];/c\\
$escaped_array" "$APP_JS"

# Check if replacement succeeded
if [ $? -eq 0 ]; then
    echo "✅ app.js updated successfully with $(basename ${#json_files[@]}) file(s)."
    echo "📁 Files:"
    for file in "${json_files[@]}"; do
        echo "   - $(basename "$file")"
    done
else
    echo "❌ Failed to update app.js."
    exit 1
fi
