# Rio Library Meta and Glossary

## Project Meta

### Version Information

- **Library Name**: rio-library
- **Architectural Epoch**: rio-v0
- **Genesis UUID**: b5ae486e-1b42-4fa5-a47e-73f793bb1a0e
- **Inception**: 2026-04-02T21:29:30Z
- **Organization**: recursive-intelligence-orchestration
- **Network**: recursive-field
- **Discipline**: field-architecture

### Author and Attribution

- **Author**: Jazen Cosby
- **License**: Proprietary
- **Classification**: Template

### Repository

- **GitHub**: https://github.com/recursive-intelligence-orchestration/rio-library
- **Clone**: `git clone https://github.com/recursive-intelligence-orchestration/rio-library.git`

### Based On

Rio Library appropriates the architectural patterns from TBC Library (The Boot Code Library) but establishes its own identity and methodology-neutral infrastructure. Rio is not a fork - it is a fresh implementation that harvests TBC's structural patterns while serving as universal substrate.

### Design Philosophy

Rio Library is built on the principle that infrastructure should be methodology-neutral. The library provides self-discovering deployment patterns without imposing constraints on the frameworks or methodologies deployed through it.

## Documentation Status

### Current Documentation

All Rio Library reference documentation is complete and available:

- ✅ [README.md](../../../../../README.md) - Overview and quick start
- ✅ [RIO_LIBRARY_INSTALLATION.md](RIO_LIBRARY_INSTALLATION.md) - Installation guide
- ✅ [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md](RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md) - Self-discovering architecture
- ✅ [RIO_LIBRARY_TECHNICAL_OVERVIEW.md](RIO_LIBRARY_TECHNICAL_OVERVIEW.md) - Technical architecture
- ✅ [RIO_LIBRARY_EXTENSIBILITY.md](RIO_LIBRARY_EXTENSIBILITY.md) - Customization guide
- ✅ [RIO_LIBRARY_AGENT_REASONING.md](RIO_LIBRARY_AGENT_REASONING.md) - Agent mental models
- ✅ [RIO_LIBRARY_UPSTREAM_REFERENCES.md](RIO_LIBRARY_UPSTREAM_REFERENCES.md) - Upstream Agent Zero references
- ✅ [RIO_LIBRARY_META_AND_GLOSSARY.md](RIO_LIBRARY_META_AND_GLOSSARY.md) - This file

### Documentation Evolution

As Rio Library evolves, documentation will be updated to reflect:
- New features and capabilities
- Architectural refinements
- Community contributions
- Lessons learned from deployments

## Glossary

### Core Concepts

**Agent**
- An instance of Agent Zero deployed through Rio Library
- Has unique name, configuration, and deployment context
- Runs in isolated Docker container with bind mounts to layers

**Agent Zero**
- Open-source agentic framework by Jan
- Base engine for Rio deployments
- Provides core agent loop, tools, and extension system

**Architectural Epoch**
- Version identifier for Rio's architecture (currently rio-v0)
- Indicates compatibility and feature set
- Changes when fundamental architecture evolves

**Bind Mount**
- Docker volume mount that maps host directory to container path
- Provides direct, transparent access to configuration and layers
- Read-only for configuration, read-write for data

**Common Layer**
- Shared layer accessible to all agents
- Contains universal knowledge and resources
- Located at `layers/common_layer/`

**Context**
- Organizational boundary for deployments
- Examples: experimental, personal, professional
- Determines risk tolerance and deployment constraints

**Context Path**
- Relative path from library root to deployment location
- Example: `experimental/production`
- Used for context-aware configuration and knowledge

**Control Layer**
- System-wide control and profile layer
- Contains profiles, prompt includes, and system control
- Located at `layers/control_layer/`

**Dynamic Generation**
- Creating configuration files from templates at runtime
- Uses discovered variables for path substitution
- Enables portable, context-aware configurations

**Environment**
- Deployment stage within a context
- Examples: production, development, testing
- Determines stability requirements and testing rigor

**Fractal Architecture**
- Infinitely nestable deployment structure
- Contexts contain environments contain containers
- Self-discovering at any nesting depth

**Genesis Marker**
- `.rio-library-root` file at library root
- Contains genesis UUID and metadata
- Anchor point for root discovery

**Genesis UUID**
- Unique identifier for this library instance
- Generated at library creation
- Permanent, never changes

**Layer**
- Customization level in Rio's hierarchy
- Types: common, control, agent
- Resolved in order: agent → control → common → base

**Layer Hierarchy**
- Resolution order for resources
- Agent layer (most specific) → Control layer → Common layer → Base image (fallback)

**Library Root**
- Top-level directory containing `.rio-library-root`
- Discovered dynamically at runtime
- All paths calculated relative to this root

**Methodology Neutral**
- Infrastructure that doesn't impose framework constraints
- Serves any methodology: FAR, enterprise workflows, custom frameworks
- Content-agnostic substrate

**PORT_BASE**
- Base port number for agent deployment
- Pattern: PORT_BASE=500 → HTTP:50080, SSH:50022, HTTPS:50043
- Ensures unique ports per agent

**Profile**
- Configurable behavior pattern
- Types: security, philosophy, workflow, reasoning, liminal thinking
- Can be activated/deactivated at runtime

**Recursive Intelligence Orchestration (RIO)**
- Full name of the project
- Methodology-neutral deployment infrastructure
- Self-discovering, fractal architecture

**Root Discovery**
- Process of finding library root from any directory
- Traverses upward looking for `.rio-library-root`
- Returns absolute path to library root

**Self-Discovering**
- Architecture that discovers its own structure at runtime
- No hardcoded absolute paths
- Adapts to directory moves and renames

**Self-Healing**
- Automatic repair of broken references
- Symlinks recreated on initialization
- Configurations regenerated from templates

**Symlink**
- Symbolic link pointing to another location
- Dynamic symlinks created by `init_environment.sh`
- Examples: `universal`, `context` in common layer

**Template**
- Configuration file with variable placeholders
- Uses `${VARIABLE}` syntax
- Processed by `envsubst` to generate actual config

### Scripts and Tools

**create_agent.sh**
- Script to create new agent from template
- Clones configuration and layers
- Generates agent-specific settings

**find_library_root.sh**
- Script to discover library root
- Traverses upward to find `.rio-library-root`
- Returns absolute path to root

**init_environment.sh**
- Environment initialization script
- Discovers root, calculates paths, exports variables
- Creates symlinks and generates configurations

**envsubst**
- Environment variable substitution tool
- Replaces `${VARIABLE}` with actual values
- Used to generate configs from templates

### File Locations

**`.rio-library-root`**
- Genesis marker file at library root
- Contains metadata and genesis UUID
- Anchor for root discovery

**`/a0/tmp/settings.json`**
- Agent configuration file inside container
- Ground truth for agent settings
- Read this first (Config-First Rule)

**`/agent_container`**
- Mount point for agent's container configuration
- Maps to `${LIBRARY_ROOT}/containers/${AGENT_NAME}`
- Read-only

**`/agent_layer`**
- Mount point for agent's specific layer
- Maps to `${LIBRARY_ROOT}/layers/${AGENT_NAME}`
- Read-only

**`/common_layer`**
- Mount point for common shared layer
- Maps to `${LIBRARY_ROOT}/layers/common_layer`
- Read-only

**`/control_layer`**
- Mount point for control layer
- Maps to `${LIBRARY_ROOT}/layers/control_layer`
- Read-only

### Environment Variables

**LIBRARY_ROOT**
- Absolute path to library root
- Discovered by `find_library_root.sh`
- Exported by `init_environment.sh`

**CONTEXT_PATH**
- Relative path from root to deployment
- Example: `experimental/production`
- Exported by `init_environment.sh`

**GENESIS_UUID**
- Unique identifier for this library
- Read from `.rio-library-root`
- Exported by `init_environment.sh`

**PORT_BASE**
- Base port number for this agent
- Set in agent's `.env` file
- Used to calculate HTTP, SSH, HTTPS ports

**AGENT_NAME**
- Internal identifier for agent
- Set in agent's `.env` file
- Used in paths and configurations

### Acronyms

**FAR**
- Field Architecture of Resonance
- Methodology that can be deployed through Rio
- Example of methodology-specific content

**RIO**
- Recursive Intelligence Orchestration
- The library and infrastructure project
- Methodology-neutral substrate

**TBC**
- The Boot Code
- Original library that Rio's architecture is based on
- Rio is not a fork, but appropriates structural patterns

**UUID**
- Universally Unique Identifier
- Used for genesis identification
- Example: b5ae486e-1b42-4fa5-a47e-73f793bb1a0e

## Common Patterns

### Discovery Pattern

```bash
# 1. Discover library root
LIBRARY_ROOT=$(./find_library_root.sh)

# 2. Calculate context path
CONTEXT_PATH="${PWD#$LIBRARY_ROOT/}"

# 3. Read genesis metadata
GENESIS_UUID=$(python3 -c "import json; print(json.load(open('$LIBRARY_ROOT/.rio-library-root'))['genesis_uuid'])")
```

### Layer Resolution Pattern

```python
# Check layers in order
for layer in ['/agent_layer', '/control_layer', '/common_layer']:
    resource_path = f'{layer}/{resource_name}'
    if exists(resource_path):
        return load(resource_path)
# Fall back to base image
return load_default(resource_name)
```

### Port Calculation Pattern

```bash
PORT_BASE=500
HTTP_PORT="${PORT_BASE}80"    # 50080
SSH_PORT="${PORT_BASE}22"     # 50022
HTTPS_PORT="${PORT_BASE}43"   # 50043
```

### Template Substitution Pattern

```bash
# Export variables
export LIBRARY_ROOT CONTEXT_PATH GENESIS_UUID

# Generate configuration
envsubst < template.yml > output.yml
```

## Troubleshooting Terms

**"ERROR: .rio-library-root not found"**
- Running discovery from outside library directory
- Solution: Ensure you're within library structure

**"Broken symlink"**
- Symlink points to non-existent location
- Solution: Run `init_environment.sh` to recreate

**"Port already in use"**
- Another agent using same PORT_BASE
- Solution: Use unique PORT_BASE for each agent

**"Configuration mismatch"**
- Settings file doesn't match actual filesystem
- Solution: Follow Config-First Rule, verify with filesystem

**"Layer not found"**
- Expected layer directory doesn't exist
- Solution: Check bind mounts in docker-compose.yml

## Best Practices

### Naming Conventions

- **Agents**: `a0-descriptive-name` (e.g., `a0-research`, `a0-analysis`)
- **Contexts**: lowercase, descriptive (e.g., `experimental`, `personal`)
- **Environments**: lowercase, standard (e.g., `production`, `development`)
- **Layers**: `snake_case` (e.g., `common_layer`, `control_layer`)

### Directory Organization

- Keep contexts at library root level
- Keep environments within contexts
- Keep containers within environments
- Keep layers at library root level

### Configuration Management

- Use templates for all generated configs
- Never hardcode absolute paths
- Export discovered variables before generation
- Verify generated configs after creation

### Documentation

- Document custom profiles and their purposes
- Document custom knowledge organization
- Document deployment-specific configurations
- Keep documentation close to code

## Future Directions

### Planned Enhancements

- Additional profile types
- Enhanced multi-agent coordination
- Distributed deployment support
- Advanced context isolation

### Community Contributions

Rio Library welcomes contributions that:
- Maintain methodology neutrality
- Preserve self-discovering architecture
- Enhance portability and resilience
- Improve documentation

## Final Thoughts

Rio Library represents a shift from hardcoded, brittle deployments to self-discovering, resilient infrastructure. By eliminating absolute paths and embracing dynamic discovery, Rio enables:

- **Portability** - Move deployments anywhere
- **Resilience** - Survive directory changes
- **Scalability** - Nest infinitely without breaking
- **Neutrality** - Serve any methodology

The architecture is designed to spread like a pattern - a reusable substrate that adapts to whatever flows through it.

## Contact and Support

For issues, questions, or contributions:
- **GitHub Issues**: https://github.com/recursive-intelligence-orchestration/rio-library/issues
- **Documentation**: This directory (`layers/common_layer/knowledge/default/main/rio-library/`)
- **Author**: Jazen Cosby

---

**End of Rio Library Documentation**

This completes the reference documentation for Rio Library rio-v0. All documentation is subject to evolution as the library grows and the community contributes.
