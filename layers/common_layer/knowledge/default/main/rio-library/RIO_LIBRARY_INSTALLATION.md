# Rio Library Installation Guide

## Overview

This guide covers installation, configuration, and deployment workflows for Rio Library. Rio uses self-discovering infrastructure that eliminates hardcoded paths, enabling portable and resilient deployments.

## Prerequisites

Before installing Rio Library, ensure you have:

- **Docker and Docker Compose**: For container orchestration
  - Docker Engine 20.10+ or compatible
  - Docker Compose v2.0+ or docker-compose 1.29+
- **Git**: For cloning the repository
  - Version 2.0+ recommended
- **rsync**: For layer directory operations
  - Used by `create_agent.sh` for safe file copying
- **Python 3**: For initialization scripts
  - Version 3.7+ required for JSON parsing in `init_environment.sh`
- **Agent Zero image**: v0.9.7 or newer
  - Upstream image must support `**kwargs` for prompt loading
- **Basic shell knowledge**: Familiarity with command-line operations
  - `cd`, `cp`, `sed`, environment variables
- **Permissions**: Ability to run Docker commands
  - May require sudo on some systems
  - User must be in `docker` group or have equivalent permissions

## Quick Installation

### 1. Clone the Repository

```bash
git clone https://github.com/recursive-intelligence-orchestration/rio-library.git
cd rio-library
```

### 2. Verify Library Root Marker

```bash
cat .rio-library-root
```

You should see the genesis marker with UUID and metadata. This confirms you're in a valid Rio library.

### 3. Initialize Environment

```bash
./init_environment.sh
```

This discovers the library root, calculates context paths, and creates dynamic symlinks.

### 4. Create Your First Agent

```bash
./create_agent.sh a0-template a0-myagent \
  dest_display="My Agent" port_base=500 \
  auth_login=myuser auth_password=mypassword
```

### 5. Start the Agent

```bash
cd containers/a0-myagent
docker compose up -d
```

### 6. Access the Agent

For `PORT_BASE=500`:
- **HTTP**: http://localhost:50080
- **SSH**: ssh://localhost:50022
- **HTTPS** (nginx): https://localhost:50043

## Detailed Installation

### Understanding the Directory Structure

```
rio-library/
├── .rio-library-root              # Genesis marker - anchor for discovery
├── find_library_root.sh           # Root discovery function
├── init_environment.sh            # Self-healing initialization
├── create_agent.sh                # Agent creation script
├── templates/                     # Configuration templates
│   └── docker-compose.template.yml
├── containers/                    # Agent container configurations
│   ├── a0-template/              # Template agent
│   └── a0-myagent/               # Your deployed agents
├── layers/                        # Layered customizations
│   ├── a0-template/              # Template layer
│   ├── common_layer/             # Shared resources
│   └── control_layer/            # System control
└── volumes/                       # Persistent data
    ├── common/
    ├── private/
    ├── public/
    └── shared/
```

### Library Root Discovery

Rio's self-discovering architecture relies on the `.rio-library-root` marker:

```bash
# From any directory within the library, discover the root
LIBRARY_ROOT=$(./find_library_root.sh)
echo "Library root: $LIBRARY_ROOT"
```

**How it works:**
1. Traverses upward from current directory
2. Checks each level for `.rio-library-root`
3. Returns absolute path when found
4. Fails safely if not found

This means you can:
- Move the entire library to any location
- Nest deployments arbitrarily deep
- Run scripts from any subdirectory

### Environment Initialization

The `init_environment.sh` script prepares your environment:

```bash
#!/bin/bash
./init_environment.sh
```

**What it does:**
1. **Discovers library root** using `find_library_root.sh`
2. **Calculates context path** relative to root
3. **Reads genesis metadata** from `.rio-library-root`
4. **Exports variables**: `$LIBRARY_ROOT`, `$CONTEXT_PATH`, `$GENESIS_UUID`
5. **Creates dynamic symlinks** in `layers/common_layer/`
6. **Generates docker-compose.yml** from template

**When to run:**
- Before first deployment
- After moving the library to a new location
- After directory structure changes
- When symlinks are broken

### Agent Creation Workflow

The `create_agent.sh` script clones and configures new agents:

```bash
./create_agent.sh SOURCE_AGENT DEST_AGENT [OPTIONS]
```

**Required arguments:**
- `SOURCE_AGENT`: Template to clone from (usually `a0-template`)
- `DEST_AGENT`: Name for new agent (e.g., `a0-myagent`)

**Optional arguments:**
- `dest_display="Display Name"`: Human-readable name
- `port_base=NNN`: Base port number (e.g., 500 → ports 50080, 50022, 50043)
- `auth_login=username`: Initial login username
- `auth_password=password`: Initial login password
- `memory_subdir=name`: Subdirectory for agent memory

**Example:**
```bash
./create_agent.sh a0-template a0-research \
  dest_display="Research Agent" \
  port_base=600 \
  auth_login=researcher \
  auth_password=secure_pass_123 \
  memory_subdir=research
```

**What it does:**
1. Copies container configuration from source to destination
2. Copies layer customizations
3. Updates agent name and display name
4. Configures ports based on `port_base`
5. Sets authentication credentials
6. Creates agent-specific directories

### Port Configuration

Rio uses a `PORT_BASE` pattern for port allocation:

```
PORT_BASE=500 →
  HTTP:  50080  (PORT_BASE + "80")
  SSH:   50022  (PORT_BASE + "22")
  HTTPS: 50043  (PORT_BASE + "43")

PORT_BASE=600 →
  HTTP:  60080
  SSH:   60022
  HTTPS: 60043
```

**Port allocation strategy:**
- Each agent gets a unique `PORT_BASE`
- Prevents port conflicts between agents
- Easy to remember and calculate
- Consistent pattern across deployments

### Docker Compose Configuration

Rio generates `docker-compose.yml` files dynamically from templates:

**Template** (`templates/docker-compose.template.yml`):
```yaml
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

**Generated** (`containers/a0-myagent/docker-compose.yml`):
```yaml
services:
  agent:
    image: frdocker/agent-zero:latest
    environment:
      - LIBRARY_ROOT=/mnt/rootfs/rio-library
      - CONTEXT_PATH=experimental/production
      - GENESIS_UUID=b5ae486e-1b42-4fa5-a47e-73f793bb1a0e
    volumes:
      - /mnt/rootfs/rio-library/common/universal:/a0/knowledge/universal:ro
      - /mnt/rootfs/rio-library/common/experimental/production:/a0/knowledge/context:ro
    restart: unless-stopped
```

**Key features:**
- No hardcoded paths in templates
- Variables substituted at initialization
- Same template works across all contexts
- Configurations adapt to directory moves

## Advanced Configuration

### Custom Contexts

Rio supports fractal deployment with contexts:

```
rio-library/
├── experimental/     # Rapid iteration, high-risk testing
│   ├── production/
│   ├── development/
│   └── testing/
├── personal/         # Individual deployments
│   ├── production/
│   ├── development/
│   └── testing/
└── professional/     # Production, client-facing
    ├── production/
    ├── development/
    └── testing/
```

**Creating a new context:**
```bash
mkdir -p experimental/production/containers
mkdir -p experimental/production/layers
cd experimental/production
../../init_environment.sh
```

The initialization script will:
- Discover the library root (two levels up)
- Calculate context path: `experimental/production`
- Create symlinks pointing to correct locations
- Generate configurations with context-aware paths

### Layer Customization

Rio uses a layered architecture for customization:

**Common Layer** (`layers/common_layer/`):
- Shared across all agents
- Universal knowledge and resources
- System-wide configurations

**Agent Layer** (`layers/a0-myagent/`):
- Specific to one agent
- Custom prompts and behaviors
- Agent-specific knowledge

**Control Layer** (`layers/control_layer/`):
- System control and profiles
- Security configurations
- Workflow definitions

**Customization workflow:**
1. Copy files to appropriate layer
2. Agent discovers layer via bind mounts
3. Agent loads customizations at runtime
4. No container rebuild required

### Environment Variables

Rio uses environment variables for configuration:

**Discovered variables** (set by `init_environment.sh`):
- `LIBRARY_ROOT`: Absolute path to library root
- `CONTEXT_PATH`: Relative path from root to current context
- `GENESIS_UUID`: Unique identifier for this library instance

**Agent-specific variables** (set in `.env` files):
- `PORT_BASE`: Base port number for this agent
- `AGENT_NAME`: Internal agent identifier
- `AGENT_DISPLAY_NAME`: Human-readable name
- `AUTH_LOGIN`: Initial login username
- `AUTH_PASSWORD`: Initial login password

### Bind Mounts

Rio uses bind mounts for direct access:

```yaml
volumes:
  # Agent's own container configuration
  - ${LIBRARY_ROOT}/containers/${AGENT_NAME}:/agent_container:ro
  
  # Agent's specific layer
  - ${LIBRARY_ROOT}/layers/${AGENT_NAME}:/agent_layer:ro
  
  # Common shared layer
  - ${LIBRARY_ROOT}/layers/common_layer:/common_layer:ro
  
  # Control layer for system control
  - ${LIBRARY_ROOT}/layers/control_layer:/control_layer:ro
```

**Benefits:**
- Agents can read their own configuration
- Changes to layers are immediately visible
- No container rebuild for configuration changes
- Agents understand their deployment context

## Verification

### Verify Installation

```bash
# Check library root marker exists
test -f .rio-library-root && echo "✓ Library root marker found"

# Check discovery script exists and is executable
test -x find_library_root.sh && echo "✓ Discovery script ready"

# Check initialization script exists and is executable
test -x init_environment.sh && echo "✓ Initialization script ready"

# Test root discovery
./find_library_root.sh && echo "✓ Root discovery working"
```

### Verify Environment

```bash
# Run initialization
./init_environment.sh

# Check exported variables
echo "LIBRARY_ROOT: $LIBRARY_ROOT"
echo "CONTEXT_PATH: $CONTEXT_PATH"
echo "GENESIS_UUID: $GENESIS_UUID"

# Check symlinks were created
ls -la layers/common_layer/universal
ls -la layers/common_layer/context
```

### Verify Agent Deployment

```bash
# Check agent container exists
ls containers/a0-myagent/

# Check docker-compose.yml was generated
test -f containers/a0-myagent/docker-compose.yml && echo "✓ Compose file generated"

# Check agent is running
docker ps | grep a0-myagent
```

## Troubleshooting

### "ERROR: .rio-library-root not found"

**Cause**: Running scripts from outside the library directory

**Solution**:
```bash
cd /path/to/rio-library
./find_library_root.sh
```

### Symlinks point to wrong locations

**Cause**: Initialization script hasn't run or library was moved

**Solution**:
```bash
./init_environment.sh
ls -la layers/common_layer/
```

### Docker compose file not generated

**Cause**: Template missing or `envsubst` not installed

**Solution**:
```bash
# Check template exists
ls templates/docker-compose.template.yml

# Install envsubst (part of gettext package)
sudo apt-get install gettext-base  # Debian/Ubuntu
sudo yum install gettext            # RHEL/CentOS
```

### Port conflicts

**Cause**: Multiple agents using same `PORT_BASE`

**Solution**:
```bash
# Use unique PORT_BASE for each agent
./create_agent.sh a0-template a0-agent1 port_base=500
./create_agent.sh a0-template a0-agent2 port_base=600
./create_agent.sh a0-template a0-agent3 port_base=700
```

### Agent can't access knowledge

**Cause**: Bind mounts not configured correctly

**Solution**:
```bash
# Check volumes in docker-compose.yml
grep -A 10 "volumes:" containers/a0-myagent/docker-compose.yml

# Verify paths exist on host
ls -la ${LIBRARY_ROOT}/layers/common_layer/
```

## Migration from TBC Library

If migrating from TBC Library:

1. **Clone Rio Library** to a new location (don't overwrite TBC)
2. **Copy agent configurations** from TBC `containers/` to Rio `containers/`
3. **Copy layer customizations** from TBC `layers/` to Rio `layers/`
4. **Run initialization** to generate new configurations
5. **Update port bases** to avoid conflicts with running TBC agents
6. **Test in development** before switching production

**Do not:**
- Copy `.git` directory (Rio has its own history)
- Copy hardcoded paths (Rio uses dynamic discovery)
- Run both libraries from same directory

## Next Steps

After installation:

1. **Read** [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md](RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md) to understand self-discovering architecture
2. **Explore** [RIO_LIBRARY_EXTENSIBILITY.md](RIO_LIBRARY_EXTENSIBILITY.md) for customization options
3. **Review** [RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md](RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md) for architecture details
4. **Configure** your agents using the Web UI Settings panel
5. **Deploy** to your chosen context (experimental, personal, or professional)

## Summary

Rio Library installation follows these key steps:

1. ✅ Clone repository
2. ✅ Verify `.rio-library-root` marker
3. ✅ Run `init_environment.sh` to discover root and create symlinks
4. ✅ Create agents with `create_agent.sh`
5. ✅ Start agents with `docker compose up -d`
6. ✅ Access via HTTP/SSH/HTTPS on configured ports

The self-discovering architecture ensures deployments are portable, resilient, and methodology-neutral.
