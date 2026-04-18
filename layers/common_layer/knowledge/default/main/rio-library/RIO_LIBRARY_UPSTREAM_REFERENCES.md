# Rio Library Upstream References

## Overview

This document indexes upstream Agent Zero documentation topics and explains how they relate to Rio Library's self-discovering architecture. Use this as a bridge between core Agent Zero concepts and Rio-specific implementations.

## Agent Zero Core Documentation

### Official Repository
- **URL**: https://github.com/agent0ai/agent-zero
- **Documentation**: `/a0/docs` (inside containers)
- **Version**: v0.9.7+

### Key Upstream Topics

#### 1. Agent Configuration (`/a0/docs/configuration.md`)

**Upstream concept:** Agent configuration via environment variables and settings files

**Rio implementation:**
- Configuration discovered dynamically via `init_environment.sh`
- Settings generated from templates using discovered variables
- Context-aware configuration per deployment

**Rio-specific additions:**
- `LIBRARY_ROOT` - Discovered library root path
- `CONTEXT_PATH` - Deployment context (e.g., experimental/production)
- `GENESIS_UUID` - Unique library instance identifier

**Example:**
```bash
# Upstream: Hardcoded paths
AGENT_MEMORY=/opt/agent/memory

# Rio: Discovered paths
AGENT_MEMORY=${LIBRARY_ROOT}/volumes/memory/${AGENT_NAME}
```

#### 2. Prompts and Behaviors (`/a0/docs/prompts.md`)

**Upstream concept:** Customizable prompts for agent behavior

**Rio implementation:**
- Prompts loaded from layered hierarchy
- Agent layer → Control layer → Common layer → Base image
- Dynamic prompt includes from control layer

**Rio-specific additions:**
- Profile-based prompt loading
- Context-aware prompt selection
- Prompt includes system for modularity

**Example:**
```python
# Upstream: Single prompt file
prompt = load('/a0/prompts/agent.system.main.role.md')

# Rio: Layered prompt resolution
prompt = find_in_layers('prompts/agent.system.main.role.md')
```

#### 3. Tools and Extensions (`/a0/docs/tools.md`)

**Upstream concept:** Extensible tool system for agent capabilities

**Rio implementation:**
- Tools discovered from agent layer
- Shared tools in control layer
- Universal tools in common layer

**Rio-specific additions:**
- Layer-based tool discovery
- Context-aware tool availability
- Profile-controlled tool restrictions

**Example:**
```python
# Upstream: Tools in base image
from tools import base_tool

# Rio: Tools from layers
from agent_layer.tools import custom_tool
from control_layer.tools import shared_tool
```

#### 4. Memory and Persistence (`/a0/docs/memory.md`)

**Upstream concept:** Agent memory for conversation history and learned knowledge

**Rio implementation:**
- Memory root discovered from settings
- Persistent volumes outside containers
- Context-specific memory isolation

**Rio-specific additions:**
- `memory_subdir` for agent-specific memory directories
- Shared memory volumes for multi-agent coordination
- Context-isolated memory spaces

**Example:**
```bash
# Upstream: Fixed memory location
MEMORY_ROOT=/a0/memory

# Rio: Discovered memory location
MEMORY_ROOT=${LIBRARY_ROOT}/volumes/memory/${AGENT_NAME}
```

#### 5. Multi-Agent Orchestration (`/a0/docs/multi-agent.md`)

**Upstream concept:** Hierarchical agent coordination

**Rio implementation:**
- Agents discover siblings via library structure
- Shared knowledge through common layer
- Context-aware agent grouping

**Rio-specific additions:**
- Library-wide agent discovery
- Context-based agent isolation
- Shared volumes for coordination

**Example:**
```python
# Upstream: Hardcoded subordinate agents
subordinates = ['agent1', 'agent2']

# Rio: Discovered subordinates
subordinates = discover_agents_in_context(CONTEXT_PATH)
```

## Rio-Specific Concepts

### Self-Discovering Architecture

**Not in upstream:** Dynamic root discovery via `.rio-library-root` marker

**Rio innovation:**
- Traverse upward to find library root
- Calculate paths relative to discovered root
- No hardcoded absolute paths

**Documentation:** See [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md](RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md)

### Fractal Deployment

**Not in upstream:** Infinitely nestable contexts and environments

**Rio innovation:**
- Contexts: experimental, personal, professional
- Environments: production, development, testing
- Arbitrary nesting without breaking references

**Documentation:** See [RIO_LIBRARY_TECHNICAL_OVERVIEW.md](RIO_LIBRARY_TECHNICAL_OVERVIEW.md)

### Layer Hierarchy

**Extends upstream:** Agent Zero's extension system

**Rio enhancement:**
- Common layer for shared resources
- Control layer for system-wide controls
- Agent layer for specific customizations
- Automatic layer resolution

**Documentation:** See [RIO_LIBRARY_EXTENSIBILITY.md](RIO_LIBRARY_EXTENSIBILITY.md)

### Template-Based Configuration

**Not in upstream:** Dynamic configuration generation from templates

**Rio innovation:**
- Docker Compose files generated from templates
- Variables substituted at initialization
- Same template works across all contexts

**Documentation:** See [RIO_LIBRARY_INSTALLATION.md](RIO_LIBRARY_INSTALLATION.md)

### Profile System

**Extends upstream:** Agent Zero's behavior customization

**Rio enhancement:**
- Security profiles
- Philosophy profiles
- Workflow profiles
- Reasoning profiles
- Runtime profile switching

**Documentation:** See [RIO_LIBRARY_EXTENSIBILITY.md](RIO_LIBRARY_EXTENSIBILITY.md)

## Compatibility Matrix

### Upstream Features Fully Compatible

These upstream features work without modification in Rio:

- ✅ Core agent loop
- ✅ Tool execution system
- ✅ Prompt loading (with Rio's layered enhancement)
- ✅ Extension system
- ✅ Memory persistence
- ✅ Multi-agent coordination
- ✅ Web UI
- ✅ SSH access

### Upstream Features Enhanced by Rio

These upstream features are enhanced by Rio's architecture:

- 🔧 **Configuration** - Dynamic discovery instead of hardcoded paths
- 🔧 **Prompts** - Layered resolution with profile support
- 🔧 **Tools** - Layer-based discovery and loading
- 🔧 **Knowledge** - Context-aware knowledge delivery
- 🔧 **Memory** - Flexible memory root configuration

### Rio-Only Features

These features exist only in Rio:

- 🆕 Self-discovering root via `.rio-library-root`
- 🆕 Fractal context/environment structure
- 🆕 Layer hierarchy (common/control/agent)
- 🆕 Template-based configuration generation
- 🆕 Profile system
- 🆕 Context-aware deployment

## Migration Guide: Upstream to Rio

### Converting Hardcoded Paths

**Before (upstream):**
```yaml
volumes:
  - /opt/agent-zero/knowledge:/a0/knowledge
```

**After (Rio):**
```yaml
volumes:
  - ${LIBRARY_ROOT}/layers/common_layer/knowledge:/a0/knowledge
```

### Converting Static Configuration

**Before (upstream):**
```bash
# .env file
AGENT_NAME=myagent
MEMORY_ROOT=/opt/agent-zero/memory
```

**After (Rio):**
```bash
# Generated from template
AGENT_NAME=myagent
MEMORY_ROOT=${LIBRARY_ROOT}/volumes/memory/${AGENT_NAME}
```

### Converting Prompt Loading

**Before (upstream):**
```python
prompt = load_file('/a0/prompts/system.md')
```

**After (Rio):**
```python
# Check layers in order
prompt = find_in_layers('prompts/system.md')
# Checks: agent_layer → control_layer → common_layer → base
```

## Conflict Resolution

### When Upstream and Rio Docs Conflict

**General rule:** Treat Rio docs as authoritative for Rio-specific features, upstream docs as authoritative for core Agent Zero features.

**Rio-specific features:**
- Self-discovering architecture
- Layer hierarchy
- Context deployment
- Template generation
- Profile system

**Core Agent Zero features:**
- Agent loop and execution
- Tool system internals
- Prompt syntax
- Extension API
- Memory format

### Testing Both Approaches

When uncertain which approach to use:

1. **Test Rio approach first** - It's designed for Rio deployments
2. **Fall back to upstream** - If Rio approach doesn't work
3. **Document the issue** - Help improve Rio documentation
4. **Report conflicts** - So they can be resolved

## Upstream Updates

### Tracking Upstream Changes

Rio is based on Agent Zero v0.9.7+. Monitor upstream for:

- New features that could be integrated
- Breaking changes that affect Rio
- Bug fixes that should be adopted
- Documentation updates

### Integrating Upstream Updates

When upstream Agent Zero updates:

1. **Review changelog** - Understand what changed
2. **Test compatibility** - Verify Rio still works
3. **Update documentation** - Reflect new upstream features
4. **Enhance if needed** - Add Rio-specific improvements

## Reference Quick Links

### Upstream Documentation

- **Agent Zero GitHub**: https://github.com/agent0ai/agent-zero
- **Agent Zero Docs**: `/a0/docs` (in container)
- **Agent Zero Wiki**: Check repository wiki for community docs

### Rio Documentation

- **Installation**: [RIO_LIBRARY_INSTALLATION.md](RIO_LIBRARY_INSTALLATION.md)
- **Self-Discovery**: [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md](RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md)
- **Technical Overview**: [RIO_LIBRARY_TECHNICAL_OVERVIEW.md](RIO_LIBRARY_TECHNICAL_OVERVIEW.md)
- **Extensibility**: [RIO_LIBRARY_EXTENSIBILITY.md](RIO_LIBRARY_EXTENSIBILITY.md)
- **Agent Reasoning**: [RIO_LIBRARY_AGENT_REASONING.md](RIO_LIBRARY_AGENT_REASONING.md)
- **Meta & Glossary**: [RIO_LIBRARY_META_AND_GLOSSARY.md](RIO_LIBRARY_META_AND_GLOSSARY.md)

## Summary

Rio Library builds on Agent Zero's foundation with:

1. **Self-discovering architecture** - No hardcoded paths
2. **Fractal deployment** - Infinitely nestable contexts
3. **Layer hierarchy** - Organized customization
4. **Template generation** - Dynamic configuration
5. **Profile system** - Behavior control

All while maintaining full compatibility with upstream Agent Zero core features.

When in doubt:
- **Rio docs** for deployment and architecture
- **Upstream docs** for core agent capabilities
- **Test both** when conflicts arise
