#!/bin/bash

set -e

# Colors
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
RED=$'\033[0;31m'
BLUE=$'\033[0;34m'
NC=$'\033[0m' # No Color

# Initialize arrays to store output lines
list_updates=()
list_checked=()
list_uptodate=()

# Use process substitution < <(...) to avoid subshell, so arrays persist after loop
while read -r nvfile; do
    pkgdir=$(dirname "$nvfile")
    pkgname=$(basename "$pkgdir")
    
    # Run nvchecker and extract version using awk (splitting by "updated to ")
    # Output format example: [I 12-12 12:30:33.787 core:416] gemini-cli: updated to 0.20.0
    # Also handles extra info: ... updated to 0.24.2 revision=...
    newver=$(nvchecker -c "$nvfile" 2>&1 | awk -F 'updated to ' '/updated to/ {split($2,a," "); print a[1]}' | head -n1)

    # Get local ebuild PV
    # Assumes format: pkgname-version.ebuild
    ebuild=$(find "$pkgdir" -maxdepth 1 -name "${pkgname}-*.ebuild" | sort -V | tail -n1)
    
    if [[ -z "$ebuild" ]]; then
        list_checked+=("${RED}${pkgname}: No ebuild found${NC}")
        continue
    fi
    
    # Extract version from filename
    # Remove pkgname- prefix and .ebuild suffix
    curver=$(basename "$ebuild" .ebuild)
    curver=${curver#${pkgname}-}

    # Compare versions and add to respective arrays
    if [[ -z "$newver" ]]; then
        list_checked+=("${RED}${pkgname}: Checked (Local: $curver)${NC}")
    elif [[ "$newver" == "$curver" ]]; then
        list_uptodate+=("${GREEN}${pkgname}: Up to date ($curver)${NC}")
    else
        list_updates+=("${BLUE}${pkgname}${NC}: ${YELLOW}Update available ($curver -> $newver)${NC}")
    fi
done < <(find /var/db/repos/local -name nvchecker.toml)

# Function to print array sorted
print_sorted() {
    if [ "$#" -gt 0 ]; then
        printf "%s\n" "$@" | sort
    fi
}

# Output in order of importance: Updates -> Checked/Error -> Up to date
# 1. Updates (Yellow/Blue)
print_sorted "${list_updates[@]}"

# 2. Checked/Errors (Red)
print_sorted "${list_checked[@]}"

# 3. Up to date (Green)
print_sorted "${list_uptodate[@]}"