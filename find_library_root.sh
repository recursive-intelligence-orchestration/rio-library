#!/bin/bash

# find_library_root.sh
# Traverses up from any directory until it finds .rio-library-root
# Returns the absolute host path of the library root
# Never hardcodes paths — discovery is always dynamic

find_library_root() {
    local current="${1:-$(pwd)}"
    while [[ "$current" != "/" ]]; do
        if [[ -f "$current/.rio-library-root" ]]; then
            echo "$current"
            return 0
        fi
        current=$(dirname "$current")
    done
    echo "ERROR: .rio-library-root not found" >&2
    return 1
}

# If called directly, run the function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    find_library_root "${1:-$(pwd)}"
fi
