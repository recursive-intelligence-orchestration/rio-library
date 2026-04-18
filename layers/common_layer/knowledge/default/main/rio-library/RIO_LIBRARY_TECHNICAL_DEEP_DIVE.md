# Rio Library Technical Overview

## Architecture Summary

Rio Library implements a self-discovering, fractal deployment architecture for Agent Zero instances. The system eliminates hardcoded paths through dynamic root discovery and runtime path resolution, enabling portable and resilient deployments that adapt to any organizational structure.

## Core Architecture Principles

### 1. Self-Discovery

Every component discovers its library root at runtime by traversing upward until finding `.rio-library-root`:

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
    return 1
}
```

**Benefits:**
- No hardcoded absolute paths
- Works from any directory depth
- Survives directory moves and renames
- Enables fractal nesting

### 2. Methodology Neutrality

Rio provides infrastructure without imposing constraints on content:

- **Field Architecture of Resonance** deployments access FAR-specific knowledge
- **Enterprise workflows** access corporate policies
- **Custom frameworks** access their own knowledge bases

The library discovers and serves content without dictating structure.

### 3. Fractal Deployment

Contexts and environments nest infinitely:

```
rio-library/
├── experimental/
│   ├── production/
│   │   └── containers/agent-1/    ← Discovers root 3 levels up
│   ├── development/
│   └── testing/
├── personal/
│   └── production/
│       └── containers/agent-2/    ← Discovers root 3 levels up
└── professional/
    └── production/
        └── containers/agent-3/    ← Discovers root 3 levels up
```

All agents discover the same library root regardless of nesting depth.

### 4. Dynamic Generation

Configurations are generated from templates using discovered variables:

```yaml
# Template
volumes:
  - ${LIBRARY_ROOT}/common/${CONTEXT_PATH}:/knowledge

# Generated (experimental/production)
volumes:
  - /mnt/rootfs/rio-library/common/experimental/production:/knowledge

# Generated (personal/production)
volumes:
  - /mnt/rootfs/rio-library/common/personal/production:/knowledge
```

Same template, different runtime values.

## Directory Structure

### Library Root

```
rio-library/
├── .rio-library-root              # Genesis marker - discovery anchor
├── find_library_root.sh           # Root discovery function
├── init_environment.sh            # Environment initialization
├── create_agent.sh                # Agent creation script
├── LICENSE                        # License file
└── README.md                      # Documentation entry point
```

### Templates

```
templates/
└── docker-compose.template.yml    # Compose file template with variables
```

Templates use `${VARIABLE}` syntax for substitution by `envsubst`.

### Containers

```
containers/
├── a0-template/                   # Template agent configuration
│   ├── .env                       # Environment variables
│   ├── .env.example               # Example environment
│   └── docker-compose.yml         # Generated compose file
└── a0-myagent/                    # Deployed agent
    ├── .env
    ├── .env.example
    └── docker-compose.yml
```

Each agent gets its own container directory with isolated configuration.

### Layers

```
layers/
├── a0-template/                   # Template agent layer
│   ├── knowledge/                 # Agent-specific knowledge
│   ├── prompts/                   # Custom prompts
│   └── tools/                     # Custom tools
├── common_layer/                  # Shared across all agents
│   ├── knowledge/                 # Universal knowledge
│   │   ├── default/
│   │   │   └── main/
│   │   │       └── rio-library/  # Rio documentation
│   │   ├── custom/
│   │   └── tbc/
│   ├── universal → (symlink)      # Created by init_environment.sh
│   └── context → (symlink)        # Created by init_environment.sh
└── control_layer/                 # System control and profiles
    ├── profile_modules/
    ├── prompt_includes/
    └── python/
```

Layers provide customization without modifying base images.

### Volumes

```
volumes/
├── common/                        # Shared persistent data
├── private/                       # Private agent data
├── public/                        # Public shared data
└── shared/                        # Shared working data
```

Persistent storage for agent data and memory.

## Component Architecture

### Discovery Layer

**Purpose:** Locate library root from any directory

**Components:**
- `.rio-library-root` - Genesis marker file
- `find_library_root.sh` - Discovery function

**Flow:**
1. Start from current directory
2. Check for `.rio-library-root`
3. Move up one level if not found
4. Repeat until found or reach filesystem root
5. Return absolute path

### Initialization Layer

**Purpose:** Prepare environment for deployment

**Components:**
- `init_environment.sh` - Main initialization script
- Template files in `templates/`

**Flow:**
1. Discover library root
2. Calculate context path
3. Read genesis metadata
4. Export environment variables
5. Create dynamic symlinks
6. Generate configurations from templates

### Deployment Layer

**Purpose:** Create and manage agent instances

**Components:**
- `create_agent.sh` - Agent creation script
- Container configurations in `containers/`
- Layer customizations in `layers/`

**Flow:**
1. Clone source agent configuration
2. Update agent name and display name
3. Configure ports based on PORT_BASE
4. Set authentication credentials
5. Create agent-specific directories
6. Generate docker-compose.yml

### Runtime Layer

**Purpose:** Execute and manage running agents

**Components:**
- Docker containers
- Bind mounts to layers
- Environment variables
- Network configuration

**Flow:**
1. Docker Compose reads generated configuration
2. Container starts with bind mounts
3. Agent accesses layers via mount points
4. Agent reads configuration from environment
5. Agent discovers context via mounted files

## Data Flow

### Agent Creation Flow

```
User runs create_agent.sh
    ↓
Script discovers library root
    ↓
Script copies source agent to destination
    ↓
Script updates configuration files
    ↓
Script generates docker-compose.yml
    ↓
Agent ready for deployment
```

### Agent Startup Flow

```
User runs docker compose up
    ↓
Docker reads docker-compose.yml
    ↓
Container starts with bind mounts
    ↓
Agent reads /agent_container for config
    ↓
Agent reads /agent_layer for customizations
    ↓
Agent reads /common_layer for shared resources
    ↓
Agent operational
```

### Configuration Discovery Flow

```
Agent starts
    ↓
Agent reads /a0/tmp/settings.json
    ↓
Agent discovers layer paths
    ↓
Agent loads prompts from layers
    ↓
Agent loads knowledge from layers
    ↓
Agent loads tools from layers
    ↓
Agent ready for interaction
```

## Bind Mount Architecture

### Mount Points

Agents see these mount points inside containers:

```
/agent_container     → ${LIBRARY_ROOT}/containers/${AGENT_NAME}
/agent_layer         → ${LIBRARY_ROOT}/layers/${AGENT_NAME}
/common_layer        → ${LIBRARY_ROOT}/layers/common_layer
/control_layer       → ${LIBRARY_ROOT}/layers/control_layer
```

### Read-Only vs Read-Write

**Read-Only mounts:**
- `/agent_container:ro` - Configuration shouldn't change at runtime
- `/agent_layer:ro` - Customizations are static
- `/common_layer:ro` - Shared resources are immutable

**Read-Write mounts:**
- `/a0/memory` - Agent needs to persist memory
- `/a0/work_dir` - Agent needs working directory
- `/a0/logs` - Agent needs to write logs

### Direct Access Benefits

Agents can:
- Read their own configuration files
- Discover their deployment context
- Access library documentation
- Load customizations dynamically
- Understand their layer structure

## Port Allocation Strategy

### PORT_BASE Pattern

```
PORT_BASE = NNN

HTTP  = NNN80  (PORT_BASE + "80")
SSH   = NNN22  (PORT_BASE + "22")
HTTPS = NNN43  (PORT_BASE + "43")
```

### Examples

```
PORT_BASE=500 → HTTP:50080, SSH:50022, HTTPS:50043
PORT_BASE=600 → HTTP:60080, SSH:60022, HTTPS:60043
PORT_BASE=700 → HTTP:70080, SSH:70022, HTTPS:70043
```

### Allocation Guidelines

- **500-599**: Experimental context
- **600-699**: Personal context
- **700-799**: Professional context
- **800-899**: Reserved for future use

## Environment Variables

### Discovered Variables

Set by `init_environment.sh`:

```bash
LIBRARY_ROOT=/mnt/rootfs/rio-library
CONTEXT_PATH=experimental/production
GENESIS_UUID=b5ae486e-1b42-4fa5-a47e-73f793bb1a0e
```

### Agent Variables

Set in `containers/${AGENT_NAME}/.env`:

```bash
PORT_BASE=500
AGENT_NAME=a0-myagent
AGENT_DISPLAY_NAME="My Agent"
AUTH_LOGIN=myuser
AUTH_PASSWORD=mypassword
```

### Container Variables

Passed to Docker container:

```yaml
environment:
  - LIBRARY_ROOT=${LIBRARY_ROOT}
  - CONTEXT_PATH=${CONTEXT_PATH}
  - GENESIS_UUID=${GENESIS_UUID}
  - PORT_BASE=${PORT_BASE}
```

## Template System

### Template Syntax

Templates use `${VARIABLE}` for substitution:

```yaml
services:
  agent:
    image: frdocker/agent-zero:latest
    ports:
      - "${PORT_BASE}80:8080"
      - "${PORT_BASE}22:50022"
    volumes:
      - ${LIBRARY_ROOT}/layers/common_layer:/common_layer:ro
```

### Variable Substitution

Performed by `envsubst` command:

```bash
envsubst < template.yml > output.yml
```

Variables are read from environment, so `init_environment.sh` must run first.

### Template Locations

- `templates/docker-compose.template.yml` - Main compose template
- Additional templates can be added for other configurations

## Symlink Architecture

### Dynamic Symlinks

Created by `init_environment.sh`:

```bash
layers/common_layer/universal → ${LIBRARY_ROOT}/common/universal
layers/common_layer/context   → ${LIBRARY_ROOT}/common/${CONTEXT_PATH}
```

### Why Symlinks?

- **Flexibility**: Point to different locations per context
- **Self-Healing**: Recreated on every initialization
- **No Git Pollution**: Symlinks not committed to repository
- **Context Awareness**: Each environment gets appropriate links

### Symlink Targets

**Universal symlink:**
- Points to library-wide shared content
- Same for all contexts
- Contains documentation, common knowledge

**Context symlink:**
- Points to context-specific content
- Different for each context
- Contains context-appropriate knowledge and configurations

## Security Considerations

### File Permissions

- Scripts should be executable: `chmod +x *.sh`
- Marker file should be readable: `chmod 644 .rio-library-root`
- Sensitive files in `.env` should be protected: `chmod 600 .env`

### Bind Mount Security

- Use `:ro` (read-only) for configuration mounts
- Use `:rw` (read-write) only for data that must change
- Never mount sensitive host directories

### Authentication

- Change default credentials immediately
- Use strong passwords for production deployments
- Consider using secrets management for credentials

### Network Isolation

- Use Docker networks to isolate agents
- Expose only necessary ports
- Use HTTPS for production deployments

## Performance Considerations

### Bind Mount Performance

- Bind mounts are faster than volumes for read-heavy workloads
- Read-only mounts have better performance
- Consider volume mounts for write-heavy data

### Initialization Overhead

- `init_environment.sh` runs quickly (< 1 second)
- Symlink creation is nearly instant
- Template substitution is fast

### Scaling

- Each agent runs in isolated container
- Agents share common layers (no duplication)
- Horizontal scaling: add more agents with unique PORT_BASE
- Vertical scaling: allocate more resources per container

## Troubleshooting Architecture

### Discovery Failures

**Symptom:** "ERROR: .rio-library-root not found"

**Diagnosis:**
```bash
pwd                    # Check current directory
ls -la .rio-library-root  # Check if marker exists
```

**Resolution:** Ensure you're within the library directory structure

### Symlink Issues

**Symptom:** Broken symlinks in `layers/common_layer/`

**Diagnosis:**
```bash
ls -la layers/common_layer/
readlink layers/common_layer/universal
```

**Resolution:** Run `init_environment.sh` to recreate symlinks

### Mount Issues

**Symptom:** Agent can't access knowledge or configuration

**Diagnosis:**
```bash
docker exec CONTAINER ls -la /common_layer
docker exec CONTAINER ls -la /agent_layer
```

**Resolution:** Verify bind mounts in `docker-compose.yml` point to correct paths

### Port Conflicts

**Symptom:** "Port already in use" error

**Diagnosis:**
```bash
netstat -tuln | grep PORT_NUMBER
docker ps | grep PORT_NUMBER
```

**Resolution:** Use different PORT_BASE for each agent

## Extension Points

### Custom Templates

Add new templates to `templates/` directory:

```bash
templates/
├── docker-compose.template.yml
├── nginx.template.conf
└── custom-config.template.yml
```

Update `init_environment.sh` to process new templates.

### Custom Layers

Add new layer types:

```bash
layers/
├── common_layer/
├── control_layer/
├── security_layer/      # New custom layer
└── monitoring_layer/    # New custom layer
```

Update bind mounts in compose template to include new layers.

### Custom Contexts

Create new context structures:

```bash
rio-library/
├── experimental/
├── personal/
├── professional/
└── research/           # New custom context
    ├── production/
    ├── development/
    └── testing/
```

Run `init_environment.sh` from new context to configure.

## Summary

Rio Library's technical architecture provides:

1. **Self-Discovery** - Dynamic root finding eliminates hardcoded paths
2. **Fractal Deployment** - Infinite nesting without breaking references
3. **Template-Based Configuration** - Generate configs from discovered variables
4. **Layered Customization** - Modify behavior without changing base images
5. **Bind Mount Access** - Direct, transparent access to configuration
6. **Methodology Neutrality** - Infrastructure serves any framework

This architecture makes Rio deployments portable, resilient, and adaptable to any organizational structure or methodology.
