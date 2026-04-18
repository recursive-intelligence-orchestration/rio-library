#!/bin/bash

# init_environment.sh
# Self-healing environment initialization
# Run at container instantiation to establish correct paths
# Discovers library root, calculates context path, creates dynamic symlinks
# Generates docker-compose.yml from template using discovered variables

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/find_library_root.sh"

# Discover library root
LIBRARY_ROOT=$(find_library_root "$SCRIPT_DIR")
if [[ $? -ne 0 ]]; then
    echo "FATAL: Cannot discover library root. Aborting." >&2
    exit 1
fi

# Calculate context path relative to library root
SELF_PATH=$(pwd)
CONTEXT_PATH="${SELF_PATH#$LIBRARY_ROOT/}"

# Read genesis UUID from marker
GENESIS_UUID=$(python3 -c "
import json, sys
with open('${LIBRARY_ROOT}/.rio-library-root') as f:
    data = json.load(f)
print(data.get('genesis_uuid', 'unknown'))
")

# Export discovered variables
export LIBRARY_ROOT
export CONTEXT_PATH
export GENESIS_UUID

echo "Library root discovered: ${LIBRARY_ROOT}"
echo "Context path: ${CONTEXT_PATH}"
echo "Genesis UUID: ${GENESIS_UUID}"

# Self-healing symlinks
# Check before creating — never mkdir a symlink destination
COMMON_LAYER_DIR="$(pwd)/layers/common_layer"
if [[ -d "$COMMON_LAYER_DIR" ]]; then
    # Universal symlink
    if [[ ! -L "${COMMON_LAYER_DIR}/universal" ]]; then
        ln -sf "${LIBRARY_ROOT}/common/universal" "${COMMON_LAYER_DIR}/universal"
        echo "Symlink created: universal"
    fi
    # Context symlink
    if [[ ! -L "${COMMON_LAYER_DIR}/context" ]]; then
        ln -sf "${LIBRARY_ROOT}/common/${CONTEXT_PATH}" "${COMMON_LAYER_DIR}/context"
        echo "Symlink created: context -> ${CONTEXT_PATH}"
    fi
fi

# Generate docker-compose.yml from template if template exists
TEMPLATE="${LIBRARY_ROOT}/templates/docker-compose.template.yml"
if [[ -f "$TEMPLATE" ]]; then
    envsubst < "$TEMPLATE" > "$(pwd)/docker-compose.yml"
    echo "docker-compose.yml generated from template"
fi

echo "Environment initialized successfully"
echo "LIBRARY_ROOT=${LIBRARY_ROOT}"
echo "CONTEXT_PATH=${CONTEXT_PATH}"
echo "GENESIS_UUID=${GENESIS_UUID}"
