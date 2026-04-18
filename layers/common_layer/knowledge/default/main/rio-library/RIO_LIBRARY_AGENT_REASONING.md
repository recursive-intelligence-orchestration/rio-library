# Rio Library Agent Reasoning Guide

## Overview

This guide explains how agents deployed through Rio Library should reason about their environment, configuration, and capabilities. It establishes mental models for self-awareness and provides guidelines for agents to understand their deployment context.

## Config-First Rule

**Primary Principle:** Always read `/a0/tmp/settings.json` as JSON to learn your configuration before inferring from filesystem patterns.

### Why Config-First?

Filesystem patterns can be misleading:
- Symlinks may point to unexpected locations
- Directory names don't always reflect content
- Mount points can vary between deployments

Configuration files provide ground truth:
- Explicit paths to resources
- Declared capabilities and constraints
- Deployment-specific settings

### Reading Configuration

```python
import json

# Read settings
with open('/a0/tmp/settings.json') as f:
    settings = json.load(f)

# Extract key information
agent_name = settings.get('agent_name')
memory_root = settings.get('memory_root')
behavior_path = settings.get('behavior_path')
context_path = settings.get('context_path')
```

**What to extract:**
- `agent_name` - Your identifier
- `memory_root` - Where to persist memory
- `behavior_path` - Where your behavior definition lives
- `context_path` - Your deployment context
- `layer_paths` - Available customization layers

## Mental Model: Deployment Context

### Understanding Your Location

Agents should reason about their position in the deployment hierarchy:

```
Library Root
    ↓
Context (experimental/personal/professional)
    ↓
Environment (production/development/testing)
    ↓
Container (your specific deployment)
```

**Discovery pattern:**
1. Read `CONTEXT_PATH` from environment or settings
2. Parse to understand: `experimental/production` = experimental context, production environment
3. Infer deployment constraints from context
4. Adjust behavior accordingly

### Context Implications

**Experimental context:**
- Higher risk tolerance acceptable
- Rapid iteration expected
- Failures are learning opportunities
- Verbose logging encouraged

**Personal context:**
- Moderate risk tolerance
- Balance between speed and stability
- User-specific customizations
- Standard logging

**Professional context:**
- Low risk tolerance
- Stability prioritized over speed
- Client-facing requirements
- Minimal logging, maximum reliability

## Mental Model: Layer Hierarchy

### Layer Resolution Order

When looking for resources, agents should check layers in order:

```
1. Agent Layer (/agent_layer)
   ↓ Most specific
   
2. Control Layer (/control_layer)
   ↓ System-wide controls
   
3. Common Layer (/common_layer)
   ↓ Shared resources
   
4. Base Image
   ↓ Fallback defaults
```

**Reasoning pattern:**
```python
def find_resource(resource_name):
    # Check agent layer first
    if exists(f'/agent_layer/{resource_name}'):
        return load(f'/agent_layer/{resource_name}')
    
    # Check control layer
    if exists(f'/control_layer/{resource_name}'):
        return load(f'/control_layer/{resource_name}')
    
    # Check common layer
    if exists(f'/common_layer/{resource_name}'):
        return load(f'/common_layer/{resource_name}')
    
    # Fall back to base image
    return load_default(resource_name)
```

### Layer Purposes

**Agent Layer** (`/agent_layer`):
- Your specific customizations
- Overrides for this agent only
- Agent-unique knowledge and tools

**Control Layer** (`/control_layer`):
- System-wide profiles and controls
- Shared prompt includes
- Common helpers and utilities

**Common Layer** (`/common_layer`):
- Universal knowledge base
- Shared documentation
- Library-wide resources

## Mental Model: Self-Discovery

### Discovering Library Root

Agents can discover their library root at runtime:

```bash
# From within container
source /agent_container/find_library_root.sh
LIBRARY_ROOT=$(find_library_root)
```

**Use cases:**
- Constructing absolute paths
- Understanding deployment structure
- Accessing library documentation
- Discovering sibling agents

### Discovering Context Path

Context path reveals your deployment location:

```python
import os

context_path = os.environ.get('CONTEXT_PATH', 'unknown')
# Example: "experimental/production"

parts = context_path.split('/')
context = parts[0]      # "experimental"
environment = parts[1]  # "production"
```

**Reasoning with context:**
- Experimental → Be bold, iterate fast
- Personal → Balance speed and stability
- Professional → Prioritize reliability

**Reasoning with environment:**
- Production → Live deployment, be careful
- Development → Active changes, expect instability
- Testing → Validation mode, thorough checks

### Discovering Genesis UUID

The genesis UUID identifies this library instance:

```python
import json

with open(f'{LIBRARY_ROOT}/.rio-library-root') as f:
    marker = json.load(f)
    genesis_uuid = marker['genesis_uuid']
    inception_timestamp = marker['inception_timestamp']
```

**Use cases:**
- Unique identifier for this deployment
- Tracking lineage across clones
- Correlating logs and metrics

## Mental Model: Knowledge Access

### Knowledge Discovery Pattern

Agents should discover knowledge systematically:

```python
def discover_knowledge():
    knowledge_sources = []
    
    # Agent-specific knowledge
    if exists('/agent_layer/knowledge'):
        knowledge_sources.append('/agent_layer/knowledge')
    
    # Control layer knowledge
    if exists('/control_layer/knowledge'):
        knowledge_sources.append('/control_layer/knowledge')
    
    # Common layer knowledge
    if exists('/common_layer/knowledge'):
        knowledge_sources.append('/common_layer/knowledge')
    
    return knowledge_sources
```

### Context-Aware Knowledge

The `context` symlink points to context-specific knowledge:

```python
# Access context-specific knowledge
context_knowledge = '/common_layer/context/knowledge'

# This resolves to different locations per context:
# experimental/production → /common/experimental/production/knowledge
# personal/production → /common/personal/production/knowledge
```

**Reasoning:**
- Same code path
- Different knowledge per context
- Automatic context adaptation

### Universal Knowledge

The `universal` symlink points to library-wide knowledge:

```python
# Access universal knowledge
universal_knowledge = '/common_layer/universal/knowledge'

# Same for all contexts
# Contains Rio documentation, common references
```

## Mental Model: Multi-Agent Orchestration

### Discovering Sibling Agents

Agents can discover other agents in the deployment:

```python
import os

# List container directories
containers_dir = f'{LIBRARY_ROOT}/containers'
sibling_agents = [d for d in os.listdir(containers_dir) 
                  if os.path.isdir(f'{containers_dir}/{d}')]
```

**Use cases:**
- Coordinating with other agents
- Delegating tasks
- Sharing knowledge

### Agent Communication Patterns

**Direct communication:**
- Use `call_subordinate` tool for hierarchical delegation
- Use shared memory for coordination
- Use message queues for async communication

**Indirect communication:**
- Write to shared volumes
- Update shared knowledge bases
- Coordinate via external services

## Mental Model: Memory and Persistence

### Memory Root Discovery

```python
# Read from settings
with open('/a0/tmp/settings.json') as f:
    settings = json.load(f)
    memory_root = settings['memory_root']

# Memory persists across restarts
# Stored outside container for durability
```

### Memory Organization

```
memory_root/
├── conversations/     # Conversation history
├── knowledge/        # Learned knowledge
├── context/          # Session context
└── state/            # Agent state
```

**Persistence strategy:**
- Critical data → memory_root (persists)
- Temporary data → /tmp (ephemeral)
- Working files → work_dir (persists)

## Reasoning Guidelines

### When to Trust Filesystem

**Trust filesystem for:**
- Checking if files exist
- Reading file contents
- Listing directory contents

**Don't trust filesystem for:**
- Inferring configuration
- Determining capabilities
- Understanding deployment context

### When to Trust Configuration

**Trust configuration for:**
- Agent identity and name
- Deployment context
- Resource locations
- Capability declarations

**Verify configuration with:**
- Filesystem checks (does declared path exist?)
- Runtime tests (can I actually access this?)
- Error handling (what if config is wrong?)

### Handling Conflicts

**If filesystem and config disagree:**
1. Trust config first
2. Verify with filesystem
3. Log the discrepancy
4. Fail safely if unresolvable

**Example:**
```python
# Config says memory is at /a0/memory
config_memory = settings['memory_root']

# But filesystem shows it's actually at /a0/memory/agent_name
actual_memory = find_actual_memory_location()

if config_memory != actual_memory:
    log_warning(f"Memory location mismatch: {config_memory} vs {actual_memory}")
    # Use actual location but report issue
    memory_root = actual_memory
```

## Adaptive Reasoning

### Context-Aware Behavior

Adjust behavior based on deployment context:

```python
context = os.environ.get('CONTEXT_PATH', '').split('/')[0]

if context == 'experimental':
    risk_tolerance = 'high'
    iteration_speed = 'fast'
    logging_level = 'verbose'
elif context == 'personal':
    risk_tolerance = 'medium'
    iteration_speed = 'balanced'
    logging_level = 'standard'
elif context == 'professional':
    risk_tolerance = 'low'
    iteration_speed = 'careful'
    logging_level = 'minimal'
```

### Profile-Aware Reasoning

Adapt to active profiles:

```python
# Read active profiles from system control
with open('/control_layer/system_control.json') as f:
    control = json.load(f)
    active_profiles = control.get('profiles', {})

# Adjust reasoning based on profiles
if active_profiles.get('security', {}).get('enabled'):
    apply_security_constraints()

if active_profiles.get('workflow', {}).get('active_profile') == 'autonomous':
    enable_autonomous_mode()
```

## Documentation Perspective

### Reading Rio Documentation

Rio documentation lives at:
```
/common_layer/knowledge/default/main/rio-library/
├── RIO_LIBRARY_INSTALLATION.md
├── RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md
├── RIO_LIBRARY_TECHNICAL_OVERVIEW.md
├── RIO_LIBRARY_EXTENSIBILITY.md
├── RIO_LIBRARY_AGENT_REASONING.md  (this file)
├── RIO_LIBRARY_UPSTREAM_REFERENCES.md
└── RIO_LIBRARY_META_AND_GLOSSARY.md
```

**When to read:**
- Understanding deployment architecture
- Learning about available features
- Troubleshooting issues
- Discovering capabilities

### Upstream vs Rio Documentation

**If upstream Agent Zero docs conflict with Rio docs:**
- Treat Rio docs as authoritative for Rio-specific features
- Treat upstream docs as authoritative for core Agent Zero features
- When in doubt, test both approaches

**Rio-specific features:**
- Self-discovering architecture
- Layer hierarchy
- Context-aware deployment
- Dynamic configuration generation

**Upstream features:**
- Core agent capabilities
- Tool system
- Prompt system
- Extension system

## Error Handling and Recovery

### Graceful Degradation

When resources aren't available:

```python
try:
    custom_knowledge = load('/agent_layer/knowledge/custom.md')
except FileNotFoundError:
    # Fall back to common layer
    try:
        custom_knowledge = load('/common_layer/knowledge/custom.md')
    except FileNotFoundError:
        # Fall back to default
        custom_knowledge = get_default_knowledge()
```

### Self-Diagnosis

Agents should be able to diagnose their environment:

```python
def self_diagnose():
    issues = []
    
    # Check configuration
    if not exists('/a0/tmp/settings.json'):
        issues.append("Settings file missing")
    
    # Check layers
    if not exists('/agent_layer'):
        issues.append("Agent layer not mounted")
    
    # Check memory
    if not exists(memory_root):
        issues.append("Memory root not accessible")
    
    return issues
```

### Reporting Issues

When encountering problems:
1. Log the issue with context
2. Attempt recovery if possible
3. Degrade gracefully if recovery fails
4. Report to user if critical

## Summary

Rio Library agents should reason using these mental models:

1. **Config-First** - Trust configuration over filesystem inference
2. **Layer Hierarchy** - Check agent → control → common → base
3. **Self-Discovery** - Discover root, context, and genesis at runtime
4. **Context-Aware** - Adapt behavior to deployment context
5. **Knowledge Discovery** - Systematically find and load knowledge
6. **Multi-Agent** - Coordinate with sibling agents when needed
7. **Graceful Degradation** - Handle missing resources elegantly

These patterns enable agents to understand their deployment, adapt to their context, and operate reliably within Rio's self-discovering architecture.
