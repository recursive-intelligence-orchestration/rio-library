# rio-library
Agent Zero Deployment Library for Recursive Intelligence Orchestration

## Quick Start

If you're here to deploy Agent Zero quickly, this section shows how to start a **rio-library-layered** Agent Zero instance. In this setup, you get the standard engine plus self-revealing orchestration via bind mounts and dynamic profiles (System Control and profiles; see [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md → Direct Agent Access via Bind Mounts](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md#direct-agent-access-via-bind-mounts) and [RIO_LIBRARY_EXTENSIBILITY.md → Dynamic system control and profiles](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_EXTENSIBILITY.md#dynamic-system-control-and-profiles)).

1. From a **host shell** (outside any Agent Zero container), run the following commands:

   ```bash
   git clone https://github.com/recursive-intelligence-orchestration/rio-library.git
   cd rio-library
   ./create_agent.sh a0-template a0-myagent \
     dest_display="My Agent" port_base=500 \
     auth_login=myuser auth_password=mypassword
   ```

   This example uses `PORT_BASE=500`. If you omit `auth_login`/`auth_password`, the script will generate default credentials and print them in its output so you can log in on first boot; you should change them after verifying access, especially if the agent is reachable from a public network. To give each cloned agent its own memory directory under `/a0/memory/<name>`, you can optionally add `memory_subdir=<name>`; the script will set `agent_memory_subdir` in `/a0/tmp/settings.json` for that agent.
2. For `PORT_BASE=500`, access HTTP at `50080`, SSH at `50022`, and HTTPS via nginx at `50043` (other `PORT_BASE` values follow the same pattern).
3. After cloning from the `a0-template` container and starting the stack, open the Agent Zero Web UI in your browser, click the **Settings** (gear) button in the sidebar, and use:
   - the **Agent Settings** page to configure your **LLM models**; and
   - the **External Services** page for **API keys** and **Authentication**, setting a user and password (either by keeping or changing the credentials established via `AUTH_LOGIN`/`AUTH_PASSWORD` in `/a0/.env`, which `create_agent.sh` can set or auto-generate).

This is a streamlined path for quick deployment. Adapt the commands as needed for your environment. For full details, see [RIO_LIBRARY_INSTALLATION.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_INSTALLATION.md). Skip to [RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md) for architecture.

## Introduction

This README serves two interconnected purposes: (1) a practical guide for deploying and customizing Agent Zero instances using the rio-library's layered approach, and (2) an introduction to the narrative philosophy of Recursive Intelligence Orchestration, where technical systems and storytelling converge to enable organic, creative development. A key innovation is the self-revealing orchestration via bind mounts, granting agents direct, transparent access to their own layers and structure for autonomous operation.

This is a living framework, and this README is its living document: both a friendly welcome to the project and the primary set of instructions for how to work with it. Dive in, experiment, and contribute. It's not exhaustive; your innovations expand it.

> **Canonical source of this README**: This file lives at the root of the `rio-library` repository on GitHub: <https://github.com/recursive-intelligence-orchestration/rio-library>. If you are reading a copied or embedded version (for example, from a vector store or from inside a container), treat that repository and its `README.md` as the source of truth. Inside an Agent Zero container, this file is typically available under `/a0/knowledge/default/main/rio-library/README.md` as part of the rio-library knowledge tree.

## Documentation Structure

The rio-library documentation in this repository is currently organized into the following focused files for easier navigation:

| Document | Purpose |
|----------|---------|
| **README.md** (this file) | Overview, navigation, Quick Start, Prerequisites |
| [RIO_LIBRARY_QUICK_REFERENCE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_QUICK_REFERENCE.md) | Commands, ports, variables, workflows - quick lookup reference |
| [RIO_LIBRARY_INSTALLATION.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_INSTALLATION.md) | Automated and manual installation, configuration, verification |
| [RIO_LIBRARY_SCRIPT_REFERENCE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_SCRIPT_REFERENCE.md) | create_agent.sh usage, parameters, examples |
| [RIO_LIBRARY_FILE_STRUCTURE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_FILE_STRUCTURE.md) | Directory layout, what's in git vs generated, path mappings |
| [RIO_LIBRARY_TROUBLESHOOTING.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_TROUBLESHOOTING.md) | Common errors, diagnostics, solutions, recovery procedures |
| [RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md) | Self-discovering architecture, bind mounts, orchestration patterns |
| [RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md) | Docker Compose, technical architecture, component details |
| [RIO_LIBRARY_ARCHITECTURAL_DECISIONS.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_ARCHITECTURAL_DECISIONS.md) | WHY behind design decisions, trade-offs, alternatives rejected |
| [RIO_LIBRARY_EXTENSIBILITY.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_EXTENSIBILITY.md) | Knowledge layers, profiles, dynamic system control, customization |
| [RIO_LIBRARY_AGENT_REASONING.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_AGENT_REASONING.md) | Agent mental models, config-first rule, reasoning patterns |
| [RIO_LIBRARY_NARRATIVE_DRIVEN_DEVELOPMENT.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_NARRATIVE_DRIVEN_DEVELOPMENT.md) | Infrastructure as narrative, direct technical communication |
| [RIO_LIBRARY_UPSTREAM_REFERENCES.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_UPSTREAM_REFERENCES.md) | Agent Zero upstream integration, compatibility matrix |
| [RIO_LIBRARY_META_AND_GLOSSARY.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_META_AND_GLOSSARY.md) | Project metadata, glossary, versioning, attribution |

> **Note**: As rio-library evolves, this documentation layout may change; treat this table as a snapshot of the current organization rather than a fixed or exhaustive index.

## Reading as a human or an agent

- **Humans**: If you just want to get an agent running, read [Quick Start](#quick-start) and [Prerequisites](#prerequisites) in this file, then follow [RIO_LIBRARY_INSTALLATION.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_INSTALLATION.md). When you need more detail, use the documentation table above as your directory into the other files.
- **Agents**: Start with the **Config-First Rule** in [RIO_LIBRARY_AGENT_REASONING.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_AGENT_REASONING.md#config-first-rule): always read `/a0/tmp/settings.json` as JSON to learn your configuration (including where your `behaviour.md` lives) before inferring from filesystem patterns. That file is your primary mental model for perception, memory roots, and multi-agent orchestration. Use supporting docs (Self-Revealing Orchestration, Technical Deep Dive, Extensibility) as needed for path details and runtime profiles. If upstream `/a0/docs` instructions conflict with rio-library docs, treat rio-library as authoritative unless explicitly told otherwise.

> **Adaptability**: Treat obstacles as prompts to question assumptions and explore alternatives. Adaptability is key to unlocking the project's full potential.

## What is Agent Zero?

Agent Zero is an open-source, personal agentic framework that grows and learns with you. It acts as a dynamic AI assistant capable of handling tasks, managing conversations, and adapting through extensions and prompts. Think of it as a customizable AI 'engine' that can be extended for various roles (e.g., creative writing, technical analysis) without deep coding knowledge. For more details, visit [Agent Zero on GitHub](https://github.com/agent0ai/agent-zero).

## Project Vision

Rio Library provides self-discovering infrastructure for Agent Zero deployments. The architecture eliminates hardcoded paths through dynamic root discovery, enabling fractal deployment patterns that adapt to any organizational structure or methodology.

### Design Philosophy

Rio is built on the principle that infrastructure should be methodology-neutral. Whether deploying Field Architecture of Resonance, enterprise workflows, or custom frameworks, Rio provides the substrate without imposing constraints. The library discovers its own structure at runtime, self-heals broken references, and generates configurations dynamically.

### Architecture Principles

- **Self-Discovery**: Every component traverses upward to find `.rio-library-root`, calculating paths relative to discovered roots
- **Fractal Deployment**: Contexts and environments nest infinitely without breaking references
- **Dynamic Generation**: Docker Compose files, symlinks, and configurations generate from discovered variables
- **Methodology Agnostic**: The infrastructure carries whatever flows through it without imposing structure on content

## Prerequisites

At minimum, you'll need the following to get started (or equivalents for alternative setups). Adjust to your environment and goals as needed.

- **Docker and Docker Compose**: Installed and running (for container orchestration).
- **Git**: For cloning the repository.
- **rsync**: For safely copying and merging layer directories when using `create_agent.sh`.
- **Agent Zero image**: Version **v0.9.7 or newer**, or any image where the upstream `files.py` already supports `**kwargs` for prompt loading (this library assumes that behavior and does not layer its own `files.py`).
- **Basic Shell Knowledge**: Familiarity with command-line operations like `cd`, `cp`, `sed`.
- **Agent Zero Familiarity**: Basic understanding of Agent Zero's concepts (agents, prompts, extensions) is helpful but not required (links provided in [RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_TECHNICAL_DEEP_DIVE.md)).
- **Permissions**: Ability to run Docker commands (may need sudo on some systems).

## How to Use

Here's a practical workflow to get oriented after reviewing Quick Start:

1. **Deploy an Agent Instance**: Use the Quick Start or [RIO_LIBRARY_INSTALLATION.md](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_INSTALLATION.md) steps to bring up a container for a base agent (for example, `a0-template` cloned to `a0-myagent`).

2. **Explore the Layered Structure**: On the host, navigate key directories like `containers/` for compose files and runtime configuration, and `layers/` for shared and agent-specific customizations (these are mounted into the container as `/containers` and `/layers`).

3. **Customize Behavior and Settings**: In the host `containers/[agent]/` directory, edit the Docker Compose environment file and compose configuration (for example, `containers/a0-myagent/.env`, `containers/a0-myagent/.env.example`, and `containers/a0-myagent/docker-compose.yml`) to adjust ports and container-level settings, and use prompt files in the agent's layer directory to change behaviours. The in-container `/a0/.env` file is managed separately (see [RIO_LIBRARY_INSTALLATION.md → Advanced: Layer the /a0/.env file](layers/common_layer/knowledge/default/main/rio-library/RIO_LIBRARY_INSTALLATION.md#advanced-layer-the-a0env-file-via-rio-library-abstraction)).

Start with this workflow and iterate as you become more familiar with the structure and capabilities.
