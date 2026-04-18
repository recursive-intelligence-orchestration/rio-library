# Rio Library Extensibility Guide

## Overview

Rio Library's layered architecture enables extensive customization without modifying base images or core infrastructure. This guide covers knowledge layers, profiles, dynamic system control, and prompt customization.

## Layer Architecture

### Layer Hierarchy

Rio uses a three-tier layer system:

```
1. Common Layer (layers/common_layer/)
   ↓ Shared across all agents
   
2. Control Layer (layers/control_layer/)
   ↓ System control and profiles
   
3. Agent Layer (layers/a0-myagent/)
   ↓ Agent-specific customizations
```

**Resolution order:** Agent Layer → Control Layer → Common Layer → Base Image

### Common Layer Structure

```
layers/common_layer/
├── knowledge/
│   ├── default/
│   │   ├── main/
│   │   │   └── rio-library/        # Rio documentation
│   │   └── solutions/
│   ├── custom/                      # Custom knowledge bases
│   └── tbc/                         # Legacy TBC content
├── universal → (symlink)            # Library-wide shared content
└── context → (symlink)              # Context-specific content
```

**Purpose:**
- Share knowledge across all agents
- Provide universal documentation
- Enable context-aware content delivery

### Control Layer Structure

```
layers/control_layer/
├── profile_modules/
│   ├── security_profile/
│   ├── philosophy_profile/
│   ├── workflow_profile/
│   └── reasoning_profile/
├── prompt_includes/
│   ├── agent_identity/
│   ├── model_overview/
│   ├── reasoning_profiles/
│   └── workflow_profile/
└── python/
    └── helpers/
        └── system_control.py
```

**Purpose:**
- Manage system-wide profiles
- Control agent behavior patterns
- Provide reusable prompt components

### Agent Layer Structure

```
layers/a0-myagent/
├── knowledge/
│   ├── domain_specific/
│   └── agent_context/
├── prompts/
│   ├── agent.system.main.role.md
│   └── custom_prompts/
├── tools/
│   └── custom_tools.py
└── extensions/
    └── custom_extensions/
```

**Purpose:**
- Agent-specific knowledge
- Custom prompts and behaviors
- Agent-unique tools and extensions

## Knowledge Layers

### Adding Custom Knowledge

**1. Create knowledge directory:**
```bash
mkdir -p layers/common_layer/knowledge/custom/my_domain
```

**2. Add knowledge files:**
```bash
cat > layers/common_layer/knowledge/custom/my_domain/overview.md << 'EOF'
# My Domain Knowledge

This knowledge is available to all agents in the library.

## Key Concepts
- Concept 1
- Concept 2
- Concept 3
EOF
```

**3. Agents discover automatically:**
- Knowledge is mounted at `/common_layer/knowledge/custom/my_domain/`
- Agents can read files directly
- No container rebuild required

### Context-Aware Knowledge

Use the context symlink for environment-specific knowledge:

```bash
# Create context-specific knowledge
mkdir -p common/experimental/production/knowledge
cat > common/experimental/production/knowledge/context.md << 'EOF'
# Experimental Production Context

This knowledge is specific to experimental production deployments.
EOF
```

**Access pattern:**
```bash
# From experimental/production environment
ls /common_layer/context/knowledge/
# Shows: context.md
```

**Benefits:**
- Same agent configuration
- Different knowledge per context
- Automatic context discovery

### Knowledge Organization Patterns

**By Domain:**
```
knowledge/
├── engineering/
├── research/
├── operations/
└── support/
```

**By Function:**
```
knowledge/
├── procedures/
├── policies/
├── templates/
└── references/
```

**By Access Level:**
```
knowledge/
├── public/
├── internal/
└── confidential/
```

## Profile System

### Profile Types

Rio supports multiple profile types:

1. **Security Profiles** - Access control and permissions
2. **Philosophy Profiles** - Reasoning and decision-making patterns
3. **Workflow Profiles** - Task execution patterns
4. **Reasoning Profiles** - Cognitive processing modes
5. **Liminal Thinking Profiles** - Boundary exploration patterns

### Creating Custom Profiles

**1. Create profile module:**
```bash
mkdir -p layers/control_layer/profile_modules/custom_profile
```

**2. Define profile structure:**
```bash
cat > layers/control_layer/profile_modules/custom_profile/profiles.json << 'EOF'
{
  "profile_type": "custom",
  "profiles": {
    "default": {
      "name": "Default Custom Profile",
      "description": "Standard custom behavior",
      "enabled": true
    },
    "advanced": {
      "name": "Advanced Custom Profile",
      "description": "Enhanced custom behavior",
      "enabled": false
    }
  }
}
EOF
```

**3. Create profile content:**
```bash
cat > layers/control_layer/profile_modules/custom_profile/profiles/default.md << 'EOF'
# Default Custom Profile

## Behavior Guidelines
- Guideline 1
- Guideline 2
- Guideline 3

## Constraints
- Constraint 1
- Constraint 2
EOF
```

**4. Activate profile:**
Agents load profiles from control layer automatically based on configuration.

### Profile Activation

Profiles can be activated:

**Globally** (all agents):
```json
// layers/control_layer/system_control.json
{
  "custom_profile": {
    "enabled": true,
    "active_profile": "default"
  }
}
```

**Per-agent** (specific agent):
```json
// layers/a0-myagent/config/profiles.json
{
  "custom_profile": {
    "enabled": true,
    "active_profile": "advanced"
  }
}
```

## Prompt Customization

### Prompt Include System

Rio uses a prompt include system for modular prompts:

```
layers/control_layer/prompt_includes/
├── agent_identity/
│   ├── agent_identity.md
│   └── agent_identity.py
├── model_overview/
│   ├── model_overview.md
│   └── model_overview.py
└── custom_include/
    ├── custom_include.md
    └── custom_include.py
```

### Creating Prompt Includes

**1. Create include directory:**
```bash
mkdir -p layers/control_layer/prompt_includes/custom_include
```

**2. Create markdown content:**
```bash
cat > layers/control_layer/prompt_includes/custom_include/custom_include.md << 'EOF'
# Custom Prompt Include

This content will be included in agent prompts when activated.

## Instructions
- Instruction 1
- Instruction 2
EOF
```

**3. Create Python loader:**
```bash
cat > layers/control_layer/prompt_includes/custom_include/custom_include.py << 'EOF'
def load_prompt_include(agent_config):
    """Load custom prompt include"""
    with open('/control_layer/prompt_includes/custom_include/custom_include.md') as f:
        return f.read()
EOF
```

**4. Register include:**
Add to agent's prompt loading configuration.

### Agent-Specific Prompts

Override system prompts at agent level:

```bash
# Create agent-specific prompt
cat > layers/a0-myagent/prompts/agent.system.main.role.md << 'EOF'
# Agent Role Override

This agent has a specialized role that differs from the default.

## Primary Function
Specialized task execution

## Capabilities
- Capability 1
- Capability 2
EOF
```

**Resolution:**
1. Check agent layer for prompt
2. If not found, check control layer
3. If not found, use base image default

## Dynamic System Control

### System Control Configuration

```json
// layers/control_layer/system_control.json
{
  "version": "1.0",
  "profiles": {
    "security": {
      "enabled": true,
      "active_profile": "standard"
    },
    "workflow": {
      "enabled": true,
      "active_profile": "guided"
    },
    "reasoning": {
      "enabled": true,
      "active_profile": "internal"
    }
  },
  "features": {
    "auto_confirmation": false,
    "verbose_reasoning": true
  }
}
```

### Runtime Profile Switching

Agents can switch profiles at runtime:

```python
# From within agent
from system_control import switch_profile

switch_profile("workflow", "autonomous")
```

**Use cases:**
- Switch to verbose mode for debugging
- Enable security profile for sensitive operations
- Change reasoning mode based on task complexity

### Feature Flags

Control features via configuration:

```json
{
  "features": {
    "auto_confirmation": false,    // Require user confirmation
    "verbose_reasoning": true,     // Show reasoning steps
    "memory_persistence": true,    // Persist memory across restarts
    "tool_restrictions": false     // Restrict tool usage
  }
}
```

## Extension Points

### Custom Tools

Add agent-specific tools:

```bash
# Create custom tool
cat > layers/a0-myagent/tools/custom_tool.py << 'EOF'
from python.helpers.tool import Tool

class CustomTool(Tool):
    async def execute(self, **kwargs):
        """Execute custom tool logic"""
        result = self.perform_custom_operation(**kwargs)
        return self.agent.read_prompt("tool.response.md", result=result)
    
    def perform_custom_operation(self, **kwargs):
        # Custom logic here
        return {"status": "success"}
EOF
```

**Registration:**
Tools in agent layer are discovered automatically.

### Custom Extensions

Add agent-specific extensions:

```bash
# Create custom extension
mkdir -p layers/a0-myagent/extensions/custom_extension
cat > layers/a0-myagent/extensions/custom_extension/__init__.py << 'EOF'
def initialize(agent):
    """Initialize custom extension"""
    agent.register_custom_handler(custom_handler)

def custom_handler(event):
    """Handle custom events"""
    # Extension logic here
    pass
EOF
```

### Custom Helpers

Add reusable Python helpers:

```bash
cat > layers/control_layer/python/helpers/custom_helper.py << 'EOF'
def custom_utility_function(data):
    """Reusable utility function"""
    # Helper logic here
    return processed_data
EOF
```

**Usage:**
```python
from python.helpers.custom_helper import custom_utility_function
result = custom_utility_function(my_data)
```

## Customization Workflows

### Workflow 1: Add Domain Knowledge

```bash
# 1. Create knowledge directory
mkdir -p layers/common_layer/knowledge/custom/finance

# 2. Add knowledge files
cp my_finance_docs/* layers/common_layer/knowledge/custom/finance/

# 3. Restart agents (or they'll discover on next knowledge query)
cd containers/a0-myagent && docker compose restart
```

### Workflow 2: Create Custom Profile

```bash
# 1. Create profile module
mkdir -p layers/control_layer/profile_modules/analyst_profile

# 2. Define profiles
cat > layers/control_layer/profile_modules/analyst_profile/profiles.json << 'EOF'
{
  "profile_type": "analyst",
  "profiles": {
    "financial": {"name": "Financial Analyst"},
    "technical": {"name": "Technical Analyst"}
  }
}
EOF

# 3. Create profile content
mkdir -p layers/control_layer/profile_modules/analyst_profile/profiles
echo "# Financial Analyst Profile" > layers/control_layer/profile_modules/analyst_profile/profiles/financial.md

# 4. Activate in system control
# Edit layers/control_layer/system_control.json to enable analyst_profile
```

### Workflow 3: Override Agent Behavior

```bash
# 1. Create agent-specific prompt
mkdir -p layers/a0-myagent/prompts
cat > layers/a0-myagent/prompts/agent.system.main.role.md << 'EOF'
# Specialized Agent Role
This agent focuses on data analysis and reporting.
EOF

# 2. Add agent-specific tools
cp my_analysis_tools.py layers/a0-myagent/tools/

# 3. Restart agent
cd containers/a0-myagent && docker compose restart
```

## Best Practices

### Knowledge Organization

- **Use clear hierarchies** - Organize by domain, function, or access level
- **Document structure** - Include README files explaining organization
- **Version knowledge** - Track changes to knowledge bases
- **Separate concerns** - Keep different domains in separate directories

### Profile Management

- **Start simple** - Begin with default profiles, customize as needed
- **Test thoroughly** - Verify profile behavior before production use
- **Document profiles** - Explain what each profile does and when to use it
- **Version profiles** - Track profile changes over time

### Prompt Customization

- **Modular design** - Use prompt includes for reusable components
- **Clear naming** - Use descriptive names for prompts and includes
- **Test variations** - Verify prompts work across different models
- **Document intent** - Explain why prompts are structured a certain way

### Extension Development

- **Follow conventions** - Use established patterns for tools and extensions
- **Error handling** - Handle failures gracefully
- **Logging** - Log extension activity for debugging
- **Documentation** - Document extension APIs and usage

## Troubleshooting

### Knowledge not loading

**Check mount points:**
```bash
docker exec CONTAINER ls -la /common_layer/knowledge/
```

**Verify file permissions:**
```bash
ls -la layers/common_layer/knowledge/custom/
```

### Profile not activating

**Check system control config:**
```bash
cat layers/control_layer/system_control.json
```

**Verify profile files exist:**
```bash
ls -la layers/control_layer/profile_modules/PROFILE_NAME/
```

### Custom tool not found

**Check tool directory:**
```bash
ls -la layers/a0-myagent/tools/
```

**Verify Python syntax:**
```bash
python3 -m py_compile layers/a0-myagent/tools/custom_tool.py
```

## Summary

Rio Library extensibility provides:

1. **Knowledge Layers** - Add domain-specific knowledge without modifying base images
2. **Profile System** - Control agent behavior through configurable profiles
3. **Prompt Customization** - Modify agent prompts at multiple levels
4. **Dynamic System Control** - Runtime configuration and feature flags
5. **Extension Points** - Custom tools, extensions, and helpers

All customizations work within the self-discovering architecture, maintaining portability and resilience.
