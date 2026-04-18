# Rio Library Self-Discovering Orchestration

## Overview

Rio Library implements a self-discovering orchestration pattern that eliminates hardcoded paths through dynamic root discovery and runtime path resolution. This architecture enables fractal deployment patterns where directories can be moved, renamed, or nested arbitrarily deep without breaking references.

## Core Principle: Dynamic Root Discovery

Every component in Rio discovers its library root at runtime by traversing upward from its current location until it finds the `.rio-library-root` marker file. This marker serves as the anchor point for all path calculations.

### The `.rio-library-root` Marker

```json
{
  "library": "rio-library",
  "type": "library",
  "organization": "recursive-intelligence-orchestration",
  "network": "recursive-field",
  "discipline": "field-architecture",
  "architectural_epoch": "rio-v0",
  "genesis_uuid": "b5ae486e-1b42-4fa5-a47e-73f793bb1a0e",
  "inception_timestamp": "2026-04-02T21:29:30Z",
  "root_marker": true,
  "classification": "template",
  "license": "proprietary",
  "author": "Jazen Cosby"
}
```

This marker contains:
- **Genesis UUID**: Permanent identifier for this library instance
- **Inception timestamp**: When this library was created
- **Architectural epoch**: Version of the Rio architecture (rio-v0)
- **Organization/Network**: Organizational context
- **Root marker flag**: Confirms this is a valid library root

## Root Discovery Mechanism

### `find_library_root.sh`

The root discovery function traverses upward from any location:

```bash
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
```

**How it works:**
1. Start from current directory (or specified path)
2. Check for `.rio-library-root` file
3. If not found, move up one directory level
4. Repeat until root is found or filesystem root (`/`) is reached
5. Return absolute path to library root

**Key properties:**
- No hardcoded paths
- Works from any depth in the directory tree
- Fails safely if marker not found
- Returns absolute paths for consistency

## Self-Healing Environment Initialization

### `init_environment.sh`

This script runs at container instantiation to establish correct paths and create dynamic symlinks:

```bash
#!/bin/bash
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
import json
with open('${LIBRARY_ROOT}/.rio-library-root') as f:
    data = json.load(f)
print(data.get('genesis_uuid', 'unknown'))
")

# Export discovered variables
export LIBRARY_ROOT
export CONTEXT_PATH
export GENESIS_UUID
```

**What it does:**
1. **Discovers library root** using `find_library_root.sh`
2. **Calculates context path** - where this environment sits relative to root
3. **Reads genesis metadata** from the marker file
4. **Exports variables** for use by other scripts and configurations
5. **Creates dynamic symlinks** that adapt to directory structure
6. **Generates configurations** from templates using discovered variables

### Self-Healing Symlinks

The initialization script creates symlinks that repair themselves on every run:

```bash
COMMON_LAYER_DIR="$(pwd)/layers/common_layer"
if [[ -d "$COMMON_LAYER_DIR" ]]; then
    # Universal symlink - points to library-wide shared content
    if [[ ! -L "${COMMON_LAYER_DIR}/universal" ]]; then
        ln -sf "${LIBRARY_ROOT}/common/universal" "${COMMON_LAYER_DIR}/universal"
    fi
    
    # Context symlink - points to this context's specific content
    if [[ ! -L "${COMMON_LAYER_DIR}/context" ]]; then
        ln -sf "${LIBRARY_ROOT}/common/${CONTEXT_PATH}" "${COMMON_LAYER_DIR}/context"
    fi
fi
```

**Key features:**
- Symlinks are created dynamically, not stored in git
- Paths are calculated from discovered root, not hardcoded
- Broken symlinks are automatically recreated on next initialization
- Context-aware - each environment gets appropriate symlinks

## Dynamic Configuration Generation

### Docker Compose Template

Rio uses templates with variable substitution instead of static configuration files:

```yaml
# templates/docker-compose.template.yml
services:
  agent:
    image: frdocker/agent-zero:latest
    environment:
      - LIBRARY_ROOT=${LIBRARY_ROOT}
      - CONTEXT_PATH=${CONTEXT_PATH}
      - GENESIS_UUID=${GENESIS_UUID}
    volumes:
      - ${LIBRARY_ROOT}/common/universal:/a0/knowledge/universal:ro
      - ${LIBRARY_ROOT}/common/${CONTEXT_PATH}:/a0/knowledge/context:ro
    restart: unless-stopped
```

The initialization script generates the actual `docker-compose.yml`:

```bash
TEMPLATE="${LIBRARY_ROOT}/templates/docker-compose.template.yml"
if [[ -f "$TEMPLATE" ]]; then
    envsubst < "$TEMPLATE" > "$(pwd)/docker-compose.yml"
    echo "docker-compose.yml generated from template"
fi
```

**Benefits:**
- No hardcoded paths in compose files
- Configurations adapt to directory moves/renames
- Same template works across all contexts
- Variables are discovered at runtime, not deployment time

## Fractal Architecture

Rio's self-discovering pattern enables infinite nesting:

```
rio-library/                          ← .rio-library-root here
├── experimental/
│   ├── production/                   ← Can discover root from here
│   │   └── containers/agent-1/       ← Or from here
│   ├── development/
│   └── testing/
├── personal/
│   ├── production/
│   ├── development/
│   └── testing/
└── professional/
    ├── production/
    ├── development/
    └── testing/
```

**Any directory at any depth can:**
1. Call `find_library_root.sh` to discover the root
2. Calculate its own context path
3. Generate configurations with correct paths
4. Create symlinks that point to the right locations

**This means you can:**
- Move entire contexts to different locations
- Nest deployments arbitrarily deep
- Rename directories without breaking references
- Clone contexts and they self-configure

## Bind Mounts and Direct Access

Rio uses bind mounts to give agents direct, transparent access to their own structure:

```yaml
volumes:
  - ${LIBRARY_ROOT}/containers/${AGENT_NAME}:/agent_container:ro
  - ${LIBRARY_ROOT}/layers/${AGENT_NAME}:/agent_layer:ro
  - ${LIBRARY_ROOT}/layers/common_layer:/common_layer:ro
```

**What agents can see:**
- `/agent_container` - their own container configuration
- `/agent_layer` - their specific layer customizations
- `/common_layer` - shared library resources

**Why this matters:**
- Agents can read their own configuration
- Agents can discover their context path
- Agents can access library documentation
- Agents can understand their deployment structure

## Methodology Neutrality

Rio's self-discovering pattern is methodology-agnostic:

- **Field Architecture of Resonance** deployments discover FAR-specific content via context paths
- **Enterprise workflows** discover corporate policies and procedures
- **Custom frameworks** discover their own knowledge bases

The infrastructure doesn't impose structure on content - it just discovers where it is and makes it accessible.

## Comparison to Hardcoded Approaches

### Traditional Approach (Hardcoded)
```bash
# Breaks if directory moves
LIBRARY_ROOT="/opt/deployments/agent-library"
docker run -v /opt/deployments/agent-library/common:/common
```

### Rio Approach (Self-Discovering)
```bash
# Works from any location
LIBRARY_ROOT=$(find_library_root)
docker run -v ${LIBRARY_ROOT}/common:/common
```

**Advantages:**
- Move library anywhere - still works
- Nest deployments - still works
- Rename directories - still works
- Clone and deploy - self-configures

## Implementation Checklist

When deploying a new Rio environment:

1. ✅ Ensure `.rio-library-root` exists at library root
2. ✅ Place `find_library_root.sh` at library root
3. ✅ Place `init_environment.sh` at library root
4. ✅ Create templates in `templates/` directory
5. ✅ Run `init_environment.sh` before starting containers
6. ✅ Verify symlinks were created correctly
7. ✅ Verify `docker-compose.yml` was generated
8. ✅ Check that `$LIBRARY_ROOT` and `$CONTEXT_PATH` are set

## Troubleshooting

### "ERROR: .rio-library-root not found"
- The marker file is missing or you're outside the library directory
- Solution: Ensure you're running from within the library structure

### Symlinks point to wrong locations
- Initialization script hasn't run or failed
- Solution: Run `init_environment.sh` manually and check for errors

### Docker compose file not generated
- Template file missing or `envsubst` not installed
- Solution: Check that `templates/docker-compose.template.yml` exists

### Variables not set in container
- Environment initialization didn't export variables
- Solution: Source `init_environment.sh` before running docker compose

## Summary

Rio's self-discovering orchestration eliminates the brittleness of hardcoded paths by:

1. **Dynamic root discovery** - traverse upward to find `.rio-library-root`
2. **Runtime path calculation** - compute context paths relative to discovered root
3. **Self-healing symlinks** - recreate broken links on every initialization
4. **Template-based configuration** - generate configs from discovered variables
5. **Fractal architecture** - nest infinitely without breaking references

This architecture makes Rio deployments resilient, portable, and methodology-neutral.
