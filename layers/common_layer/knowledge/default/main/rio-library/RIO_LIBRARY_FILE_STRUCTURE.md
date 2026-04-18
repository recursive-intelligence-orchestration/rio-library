# Rio Library File Structure Reference

## Overview

This document describes the actual directory structure of Rio Library after installation and deployment. Use this to understand where files live and what gets created vs what's in git.

## Library Root Structure

```
rio-library/                          # Library root (contains .rio-library-root)
├── .rio-library-root                 # Genesis marker (in git)
├── .gitignore                        # Git ignore rules (in git)
├── README.md                         # Main documentation (in git)
├── LICENSE                           # License file (in git)
├── find_library_root.sh              # Root discovery script (in git, executable)
├── init_environment.sh               # Environment initialization (in git, executable)
├── create_agent.sh                   # Agent creation script (in git, executable)
├── create_agent.md                   # Script documentation (in git)
├── templates/                        # Configuration templates (in git)
│   └── docker-compose.template.yml   # Docker Compose template
├── containers/                       # Agent container configurations
│   ├── a0-template/                  # Template agent (in git)
│   │   ├── .env                      # Container environment (in git)
│   │   ├── .env.example              # Example environment (in git)
│   │   ├── docker-compose.yml        # Generated compose file (NOT in git)
│   │   └── a0/                       # Agent Zero source (git submodule)
│   └── a0-myagent/                   # Deployed agent (NOT in git)
│       ├── .env                      # Generated container env
│       ├── .env.example              # Copied from template
│       └── docker-compose.yml        # Generated from template
├── layers/                           # Layer customizations
│   ├── a0-template/                  # Template layer (in git)
│   │   ├── .env                      # Layer environment (in git)
│   │   ├── agents/                   # Agent profiles
│   │   ├── knowledge/                # Agent-specific knowledge
│   │   ├── prompts/                  # Custom prompts
│   │   ├── tools/                    # Custom tools
│   │   └── memory/                   # Agent memory (NOT in git)
│   ├── a0-myagent/                   # Deployed agent layer (NOT in git)
│   │   ├── .env                      # Generated layer env
│   │   ├── agents/                   # Copied from template
│   │   ├── memory/                   # Agent persistent memory
│   │   └── tmp/                      # Agent temporary files
│   ├── common_layer/                 # Shared layer (in git)
│   │   ├── knowledge/                # Universal knowledge
│   │   │   ├── default/
│   │   │   │   └── main/
│   │   │   │       └── rio-library/  # Rio documentation
│   │   │   ├── custom/               # Custom knowledge bases
│   │   │   └── tbc/                  # Legacy content
│   │   ├── universal -> (symlink)    # Generated symlink (NOT in git)
│   │   └── context -> (symlink)      # Generated symlink (NOT in git)
│   └── control_layer/                # System control (in git)
│       ├── profile_modules/          # Profile definitions
│       ├── prompt_includes/          # Reusable prompt components
│       └── python/                   # Helper scripts
└── volumes/                          # Persistent data (in git structure, NOT data)
    ├── common/                       # Shared volumes
    ├── private/                      # Private data
    ├── public/                       # Public data
    └── shared/                       # Shared working data
```

## What's in Git vs Generated

### In Git (Committed)

**Root level:**
- `.rio-library-root` - Genesis marker
- `*.sh` scripts - Discovery, initialization, creation
- `README.md` - Documentation
- `LICENSE` - License file
- `.gitignore` - Ignore rules

**Templates:**
- `templates/docker-compose.template.yml` - Compose template
- Any other `*.template.*` files

**Container templates:**
- `containers/a0-template/` - Template agent directory
- `containers/a0-template/.env` - Template environment
- `containers/a0-template/.env.example` - Example config

**Layers:**
- `layers/a0-template/` - Template layer
- `layers/common_layer/` - Shared layer (except symlinks)
- `layers/control_layer/` - Control layer
- All knowledge, prompts, tools in layers

**Volume structure:**
- `volumes/*/` directories (empty, just structure)
- `.gitkeep` files to preserve empty directories

### Generated (NOT in Git)

**Symlinks:**
- `layers/common_layer/universal` - Points to universal content
- `layers/common_layer/context` - Points to context-specific content

**Docker Compose files:**
- `containers/*/docker-compose.yml` - Generated from template

**Deployed agents:**
- `containers/a0-myagent/` - Entire directory
- `layers/a0-myagent/` - Entire directory

**Agent data:**
- `layers/*/memory/` - Agent memory
- `layers/*/tmp/` - Temporary files
- `volumes/*/` contents - Persistent data

## Directory Purposes

### `/containers/<agent>/`

**Purpose:** Docker orchestration configuration for specific agent

**Contains:**
- `.env` - Container-level environment variables (PORT_BASE, CONTAINER_NAME, etc.)
- `.env.example` - Example configuration
- `docker-compose.yml` - Generated Docker Compose configuration
- `a0/` - Agent Zero source code (git submodule)

**Host path:** `${LIBRARY_ROOT}/containers/<agent>/`

**Not mounted in container** (orchestration only)

---

### `/layers/<agent>/`

**Purpose:** Agent-specific customizations and persistent data

**Contains:**
- `.env` - Agent runtime environment (AUTH_LOGIN, AUTH_PASSWORD, etc.)
- `agents/` - Agent profile definitions
- `knowledge/` - Agent-specific knowledge
- `prompts/` - Custom prompts
- `tools/` - Custom tools
- `memory/` - Persistent agent memory
- `tmp/` - Temporary runtime files (settings.json, etc.)

**Host path:** `${LIBRARY_ROOT}/layers/<agent>/`

**Container mount:** `/agent_layer` (read-only for most, read-write for memory/tmp)

---

### `/layers/common_layer/`

**Purpose:** Shared resources available to all agents

**Contains:**
- `knowledge/` - Universal knowledge bases
  - `default/main/rio-library/` - Rio documentation
  - `custom/` - Custom knowledge
- `universal` (symlink) - Points to library-wide content
- `context` (symlink) - Points to context-specific content

**Host path:** `${LIBRARY_ROOT}/layers/common_layer/`

**Container mount:** `/common_layer` (read-only)

---

### `/layers/control_layer/`

**Purpose:** System-wide control and profiles

**Contains:**
- `profile_modules/` - Profile definitions (security, workflow, reasoning, etc.)
- `prompt_includes/` - Reusable prompt components
- `python/helpers/` - Helper scripts (system_control.py, etc.)

**Host path:** `${LIBRARY_ROOT}/layers/control_layer/`

**Container mount:** `/control_layer` (read-only)

---

### `/volumes/`

**Purpose:** Persistent data storage

**Contains:**
- `common/` - Shared across all agents
- `private/` - Private to specific agents
- `public/` - Publicly accessible
- `shared/` - Shared working data

**Host path:** `${LIBRARY_ROOT}/volumes/`

**Container mounts:** Various, depending on agent configuration

---

## Path Mappings (Host to Container)

### Agent Container Mounts

```yaml
# From docker-compose.yml
volumes:
  # Agent's own container configuration (read-only)
  - ${LIBRARY_ROOT}/containers/${AGENT_NAME}:/agent_container:ro
  
  # Agent's specific layer (read-only except memory/tmp)
  - ${LIBRARY_ROOT}/layers/${AGENT_NAME}:/agent_layer:ro
  
  # Common shared layer (read-only)
  - ${LIBRARY_ROOT}/layers/common_layer:/common_layer:ro
  
  # Control layer (read-only)
  - ${LIBRARY_ROOT}/layers/control_layer:/control_layer:ro
  
  # Agent memory (read-write)
  - ${LIBRARY_ROOT}/layers/${AGENT_NAME}/memory:/a0/memory:rw
  
  # Agent tmp (read-write)
  - ${LIBRARY_ROOT}/layers/${AGENT_NAME}/tmp:/a0/tmp:rw
```

### Example Path Resolution

**Scenario:** Agent `a0-myagent` accessing Rio documentation

**Host path:**
```
/mnt/rootfs/rio-library/layers/common_layer/knowledge/default/main/rio-library/README.md
```

**Container path:**
```
/common_layer/knowledge/default/main/rio-library/README.md
```

**Agent accesses via:**
```python
with open('/common_layer/knowledge/default/main/rio-library/README.md') as f:
    content = f.read()
```

---

## File Lifecycle

### Fresh Installation

1. **Clone repository:**
   ```bash
   git clone https://github.com/recursive-intelligence-orchestration/rio-library.git
   ```
   
   **Creates:**
   - All git-tracked files
   - Directory structure
   - Scripts (not yet executable)

2. **Make scripts executable:**
   ```bash
   chmod +x *.sh
   ```
   
   **Modifies:**
   - Script permissions

3. **Run initialization:**
   ```bash
   ./init_environment.sh
   ```
   
   **Creates:**
   - `layers/common_layer/universal` (symlink)
   - `layers/common_layer/context` (symlink)
   
   **Exports:**
   - `$LIBRARY_ROOT`
   - `$CONTEXT_PATH`
   - `$GENESIS_UUID`

### Agent Creation

4. **Create agent:**
   ```bash
   ./create_agent.sh a0-template a0-myagent port_base=500
   ```
   
   **Creates:**
   - `containers/a0-myagent/` (copied from template)
   - `containers/a0-myagent/.env` (generated)
   - `containers/a0-myagent/docker-compose.yml` (generated)
   - `layers/a0-myagent/` (copied from template)
   - `layers/a0-myagent/.env` (generated)
   - `layers/a0-myagent/memory/` (empty directory)
   - `layers/a0-myagent/tmp/` (empty directory)

### Agent Startup

5. **Start agent:**
   ```bash
   cd containers/a0-myagent
   docker compose up -d
   ```
   
   **Creates:**
   - Docker container
   - Bind mounts (host directories → container paths)
   - Network interfaces
   - Port mappings

### Agent Runtime

6. **Agent runs:**
   
   **Creates in `/a0/memory/`:**
   - Conversation history
   - Learned knowledge
   - Agent state
   
   **Creates in `/a0/tmp/`:**
   - `settings.json` (runtime configuration)
   - Temporary files
   - Cache

## .gitignore Rules

Rio Library's `.gitignore` should include:

```gitignore
# Generated files
docker-compose.yml
*.pyc
__pycache__/

# Symlinks
layers/common_layer/universal
layers/common_layer/context

# Deployed agents (keep template only)
containers/a0-*
!containers/a0-template/
layers/a0-*
!layers/a0-template/

# Agent data
*/memory/
*/tmp/
*.log

# Volume data
volumes/*/
!volumes/*/.gitkeep

# Environment files with secrets
.env.local
.env.*.local

# OS files
.DS_Store
Thumbs.db
```

## Storage Considerations

### Persistent Data Locations

**Agent memory:**
- Location: `layers/<agent>/memory/`
- Size: Grows with agent usage
- Backup: Copy entire directory

**Agent configuration:**
- Location: `layers/<agent>/.env`
- Size: < 1KB
- Backup: Copy file

**Agent settings:**
- Location: `layers/<agent>/tmp/settings.json`
- Size: < 10KB
- Backup: Copy file

### Ephemeral Data Locations

**Docker containers:**
- Location: Docker storage
- Size: Varies by image
- Recreated on: Container rebuild

**Generated configs:**
- Location: `containers/<agent>/docker-compose.yml`
- Size: < 10KB
- Recreated on: `init_environment.sh` + `envsubst`

**Symlinks:**
- Location: `layers/common_layer/`
- Size: Negligible
- Recreated on: `init_environment.sh`

## Backup Strategy

### Minimal Backup (Configuration Only)

```bash
# Backup agent configuration
tar czf agent-config-backup.tar.gz \
  layers/a0-myagent/.env \
  layers/a0-myagent/agents/ \
  layers/a0-myagent/prompts/ \
  layers/a0-myagent/tmp/settings.json
```

### Full Backup (Including Memory)

```bash
# Backup agent with memory
tar czf agent-full-backup.tar.gz \
  layers/a0-myagent/
```

### Library Backup (All Agents)

```bash
# Backup entire library
tar czf rio-library-backup.tar.gz \
  --exclude='containers/*/a0' \
  --exclude='*.pyc' \
  --exclude='__pycache__' \
  rio-library/
```

## Disk Usage Estimates

**Fresh installation:**
- Git repository: ~50MB
- Agent Zero source (per agent): ~100MB
- Total: ~150MB

**After deploying 3 agents:**
- Repository: ~50MB
- Agent sources (3 × 100MB): ~300MB
- Agent memory (varies): ~10-100MB per agent
- Total: ~400-650MB

**Growth over time:**
- Agent memory grows with usage
- Logs accumulate if not rotated
- Docker images consume space

## Summary

Rio Library's file structure separates:

1. **Git-tracked** - Templates, scripts, shared layers
2. **Generated** - Symlinks, docker-compose files
3. **Deployed** - Agent containers and layers
4. **Persistent** - Agent memory and configuration
5. **Ephemeral** - Docker containers, temporary files

Understanding this structure helps with:
- Backup and recovery
- Troubleshooting mount issues
- Managing disk space
- Version control
- Deployment automation
