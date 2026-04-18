# Rio Library Pattern DNA

## Overview

This document codifies the **invariant patterns** that define Rio Library's architecture. These patterns are the "DNA" - the essential characteristics that make a system "Rio-compatible" regardless of substrate, orchestration engine, or deployment environment.

An agent reading this document can:
- Extract the core patterns from Rio's concrete implementation
- Generate variations on different substrates while maintaining compatibility
- Validate proposed changes against pattern fidelity
- Ensure interoperability with other Rio-compatible systems

**Status:** Living document. Evolves as agents observe and contribute new pattern insights.

---

## Core Invariants

These patterns MUST be preserved for Rio compatibility:

### 1. Self-Discovery Pattern

**Invariant:** Systems discover their own structure at runtime rather than having structure prescribed.

**Concrete Implementation (Rio):**
- `.rio-library-root` marker file
- `find_library_root.sh` traverses upward to find marker
- All paths calculated relative to discovered root

**Abstraction:**
```
PATTERN: Discovery Anchor
- Place marker at system root
- Provide discovery mechanism that finds marker
- Calculate all paths relative to discovered anchor
- Never hardcode absolute paths

SUBSTITUTION POINTS:
- Marker format: file, environment variable, registry key, DNS record
- Discovery mechanism: filesystem traversal, API query, service discovery
- Path calculation: relative paths, URIs, resource identifiers
```

**Validation Test:**
```
Can the system locate its own root from any starting point within its structure?
Can the system be moved to a new location and still discover itself?
```

---

### 2. Layer Hierarchy Pattern

**Invariant:** Resources resolve through layered precedence with specific overriding general.

**Concrete Implementation (Rio):**
```
1. Agent Layer (most specific)
2. Control Layer (system-wide)
3. Common Layer (universal)
4. Base Image (fallback)
```

**Abstraction:**
```
PATTERN: Hierarchical Resolution
- Define clear precedence order from specific to general
- Check layers in order until resource found
- Allow specific layers to override general layers
- Maintain clear boundaries between layers

SUBSTITUTION POINTS:
- Number of layers: 2-N layers
- Layer names: agent/control/common OR custom naming
- Resolution mechanism: filesystem, database, API, registry
- Override semantics: complete replacement, merge, inheritance
```

**Validation Test:**
```
Does a resource in a more specific layer override the same resource in a general layer?
Is the resolution order deterministic and documented?
Can layers be added/removed without breaking existing functionality?
```

---

### 3. Separation of Concerns Pattern

**Invariant:** Configuration, code, and data are separated with clear boundaries.

**Concrete Implementation (Rio):**
```
- Configuration: .env files, settings.json (read-only mounts)
- Code: Agent Zero source, scripts (read-only mounts)
- Data: Agent memory, logs (read-write mounts)
```

**Abstraction:**
```
PATTERN: Concern Boundaries
- Configuration is immutable from runtime perspective
- Code is versioned and deployed separately from data
- Data persists across runtime recreation
- Clear boundaries prevent accidental corruption

SUBSTITUTION POINTS:
- Configuration storage: files, environment variables, config service, database
- Code deployment: containers, packages, source, compiled binaries
- Data persistence: filesystem, database, object storage, distributed storage
- Boundary enforcement: mount permissions, access control, API boundaries
```

**Validation Test:**
```
Can configuration be updated without modifying code or data?
Can code be updated without losing data?
Can data persist when runtime is destroyed and recreated?
```

---

### 4. Dynamic Generation Pattern

**Invariant:** Runtime configurations are generated from templates using discovered variables.

**Concrete Implementation (Rio):**
```
- Templates with ${VARIABLE} placeholders
- init_environment.sh exports discovered variables
- envsubst generates actual configuration files
- Generated files not committed to version control
```

**Abstraction:**
```
PATTERN: Template Generation
- Store templates with variable placeholders
- Discover or calculate variables at initialization
- Generate concrete configurations from templates
- Regenerate on environment changes

SUBSTITUTION POINTS:
- Template format: shell variables, Jinja2, Mustache, custom DSL
- Variable discovery: scripts, APIs, service discovery, user input
- Generation mechanism: envsubst, template engine, code generation
- Storage: filesystem, database, config service
```

**Validation Test:**
```
Can configurations be regenerated from templates without manual editing?
Do generated configurations adapt to discovered environment?
Are templates portable across environments?
```

---

### 5. Config-First Pattern

**Invariant:** Runtime reads authoritative configuration before inferring from environment.

**Concrete Implementation (Rio):**
```
- Agent reads /a0/tmp/settings.json first
- settings.json contains agent_profile, memory paths, ports
- Agent trusts config over filesystem inference
```

**Abstraction:**
```
PATTERN: Authoritative Configuration
- Single source of truth for runtime configuration
- Runtime reads config before making assumptions
- Config explicitly declares paths, identifiers, resources
- Inference only when config is absent or incomplete

SUBSTITUTION POINTS:
- Config format: JSON, YAML, TOML, environment variables, database
- Config location: filesystem, API endpoint, registry, service discovery
- Config scope: per-instance, per-service, global
- Update mechanism: file write, API call, config push
```

**Validation Test:**
```
Does runtime behavior match configuration even if environment suggests otherwise?
Can configuration override default assumptions?
Is there a single authoritative source for each configuration value?
```

---

### 6. Methodology Neutrality Pattern

**Invariant:** Infrastructure serves content without imposing structure on content.

**Concrete Implementation (Rio):**
```
- Rio provides substrate (layers, discovery, generation)
- Content flows through infrastructure
- No assumptions about what methodology uses Rio
- Field Architecture of Resonance is one user, not the only user
```

**Abstraction:**
```
PATTERN: Content Agnostic Infrastructure
- Infrastructure provides capabilities, not constraints
- Content determines its own structure
- Infrastructure adapts to content needs
- Multiple methodologies can coexist

SUBSTITUTION POINTS:
- Capability set: discovery, layers, generation, orchestration
- Content types: knowledge, prompts, tools, workflows
- Methodology support: single, multiple, pluggable
- Adaptation mechanism: configuration, extension points, plugins
```

**Validation Test:**
```
Can multiple different methodologies use the infrastructure simultaneously?
Does infrastructure impose constraints on content structure?
Can new methodologies adopt infrastructure without modification?
```

---

## Substitution Points

These aspects CAN vary while maintaining Rio compatibility:

### Storage Substrate

**Current:** Filesystem bind mounts
**Alternatives:** Docker volumes, NFS, object storage (S3), distributed filesystem
**Invariant Preserved:** Separation of concerns, layer hierarchy

### Orchestration Engine

**Current:** Docker Compose
**Alternatives:** Kubernetes, Nomad, systemd, custom orchestrator
**Invariant Preserved:** Dynamic generation, self-discovery

### Compute Platform

**Current:** Docker containers on Linux host
**Alternatives:** Podman, LXC, VMs, bare metal, serverless, edge devices
**Invariant Preserved:** All invariants (substrate-independent)

### Network Topology

**Current:** Localhost with port mapping
**Alternatives:** Service mesh, distributed network, overlay network, DNS-based
**Invariant Preserved:** Config-first, dynamic generation

### Discovery Mechanism

**Current:** Filesystem traversal for `.rio-library-root`
**Alternatives:** Environment variables, service registry, DNS, API endpoint
**Invariant Preserved:** Self-discovery pattern

### Template Engine

**Current:** Shell variable substitution (`envsubst`)
**Alternatives:** Jinja2, Mustache, Helm, custom templating
**Invariant Preserved:** Dynamic generation pattern

---

## Pattern Fidelity Validation

To validate a variation maintains Rio compatibility:

### 1. Self-Discovery Test
```
Q: Can the system locate its own root from any internal starting point?
Q: Does the system work after being moved to a new location?
Q: Are all paths calculated relative to discovered root?
```

### 2. Layer Hierarchy Test
```
Q: Is there a clear, documented resolution order?
Q: Do specific layers override general layers?
Q: Can resources be added to any layer without breaking others?
```

### 3. Separation Test
```
Q: Is configuration separate from code and data?
Q: Can each concern be updated independently?
Q: Do boundaries prevent accidental corruption?
```

### 4. Generation Test
```
Q: Are runtime configs generated from templates?
Q: Can configs be regenerated without manual editing?
Q: Do configs adapt to discovered environment?
```

### 5. Config-First Test
```
Q: Does runtime read authoritative config before inferring?
Q: Can config override environmental assumptions?
Q: Is there a single source of truth?
```

### 6. Neutrality Test
```
Q: Can multiple methodologies coexist?
Q: Does infrastructure impose content constraints?
Q: Can new methodologies adopt without modification?
```

**Validation Result:** If all tests pass, variation is Rio-compatible.

---

## Generating Compatible Variations

### Process

1. **Extract Patterns** - Read this document and concrete implementation
2. **Identify Substitution Points** - Determine what varies in your target substrate
3. **Preserve Invariants** - Ensure all 6 core patterns are maintained
4. **Implement Variation** - Generate substrate-specific implementation
5. **Validate Fidelity** - Run validation tests
6. **Document Variation** - Record what was substituted and why

### Example: Kubernetes Variation

**Substitutions:**
- Orchestration: Docker Compose → Kubernetes manifests
- Discovery: `.rio-library-root` file → ConfigMap with root metadata
- Generation: `envsubst` → Helm templates
- Storage: Bind mounts → PersistentVolumeClaims

**Invariants Preserved:**
- ✓ Self-discovery: Pods read ConfigMap to find cluster root
- ✓ Layer hierarchy: Multiple ConfigMaps with precedence
- ✓ Separation: ConfigMaps (config), Deployments (code), PVCs (data)
- ✓ Generation: Helm generates manifests from templates
- ✓ Config-first: Pods read ConfigMap before inferring
- ✓ Neutrality: Kubernetes infrastructure serves any methodology

**Result:** Kubernetes variation is Rio-compatible.

---

## Interoperability Guarantee

Systems implementing these patterns can interoperate because they share:

1. **Common discovery semantics** - All find their own roots
2. **Common resolution semantics** - All resolve through layers
3. **Common separation semantics** - All separate config/code/data
4. **Common generation semantics** - All generate from templates
5. **Common config semantics** - All read authoritative config
6. **Common neutrality semantics** - All serve content without constraints

**Example Interoperability:**
- Agent A on Docker Compose (Rio concrete)
- Agent B on Kubernetes (Rio variation)
- Agent C on systemd (Rio variation)

All three can:
- Understand each other's configuration format (config-first)
- Locate each other's resources (self-discovery)
- Share knowledge through common layer patterns (layer hierarchy)
- Coordinate without substrate-specific knowledge (neutrality)

---

## Evolution and Contribution

This document evolves through:

### Agent Observations

Agents may discover:
- New invariant patterns not yet codified
- Additional substitution points
- Better validation tests
- Edge cases requiring clarification

**Process:**
1. Agent documents observed pattern
2. Agent validates pattern against existing implementations
3. Agent proposes addition/modification to this document
4. Human reviews for pattern fidelity
5. Document updated if pattern is confirmed

### Human Refinement

Humans may:
- Clarify ambiguous patterns
- Add concrete examples
- Document known variations
- Refine validation tests

### Version History

Document versions track:
- What patterns were added/modified
- Why changes were made
- What observations led to changes
- Validation that changes maintain compatibility

---

## Substrate Abstraction Primitives

The fundamental abstractions that enable substrate independence:

### 1. Identity

**What:** How the system identifies itself
**Rio Implementation:** Genesis UUID in `.rio-library-root`
**Abstraction:** Unique, persistent identifier independent of location
**Variations:** UUID, DNS name, public key, service ID

### 2. Location

**What:** How the system finds its own boundaries
**Rio Implementation:** Filesystem root marker
**Abstraction:** Discoverable anchor point
**Variations:** File, environment variable, registry entry, DNS record

### 3. Structure

**What:** How resources are organized
**Rio Implementation:** Directory hierarchy with layers
**Abstraction:** Hierarchical namespace with precedence
**Variations:** Filesystem, object paths, URL hierarchy, database schema

### 4. State

**What:** How data persists
**Rio Implementation:** Bind-mounted directories
**Abstraction:** Persistent storage separate from runtime
**Variations:** Volumes, databases, object storage, distributed storage

### 5. Configuration

**What:** How behavior is controlled
**Rio Implementation:** .env files and settings.json
**Abstraction:** Authoritative, versioned configuration
**Variations:** Files, environment, config service, database

### 6. Orchestration

**What:** How runtime is managed
**Rio Implementation:** Docker Compose
**Abstraction:** Declarative runtime specification
**Variations:** Compose, Kubernetes, systemd, custom

---

## Self-Modification Guidelines

When agents extend infrastructure:

### Permitted Modifications

- Add new layers (maintains hierarchy)
- Add new templates (maintains generation)
- Add new discovery mechanisms (maintains self-discovery)
- Add new storage backends (maintains separation)
- Add new orchestration targets (maintains patterns)

### Validation Required

- Modify existing patterns (verify fidelity)
- Change resolution order (verify hierarchy)
- Alter discovery mechanism (verify self-discovery)
- Change separation boundaries (verify concerns)

### Human Approval Required

- Remove invariant patterns (breaks compatibility)
- Change core semantics (breaks interoperability)
- Modify validation tests (changes definition of compatibility)

### Documentation Required

All modifications must:
- Document what changed
- Document why it changed
- Validate pattern fidelity
- Update this document if patterns evolved

---

## Pattern DNA Summary

**Rio Library's DNA:**
```
INVARIANTS (must preserve):
1. Self-Discovery - Find own root dynamically
2. Layer Hierarchy - Specific overrides general
3. Separation of Concerns - Config/code/data boundaries
4. Dynamic Generation - Templates + variables → configs
5. Config-First - Read authoritative config before inferring
6. Methodology Neutrality - Infrastructure serves, doesn't constrain

SUBSTITUTION POINTS (can vary):
- Storage substrate
- Orchestration engine
- Compute platform
- Network topology
- Discovery mechanism
- Template engine

VALIDATION (confirms compatibility):
- All 6 invariants preserved
- Interoperability maintained
- Pattern fidelity verified
```

**Species Compatibility:**
Any system preserving these 6 invariants is Rio-compatible and can interoperate with other Rio-compatible systems, regardless of substrate differences.

---

## Future Observations

This section captures patterns observed by agents that may become formalized:

**Placeholder for agent-contributed patterns**

*Agents: Document observed patterns here. Include:*
- *Pattern description*
- *Where observed*
- *Why it matters*
- *Validation evidence*

---

## Conclusion

Rio Library's pattern DNA enables:
- **Substrate independence** - Run anywhere
- **Evolutionary variation** - Adapt to new environments
- **Species compatibility** - Interoperate despite differences
- **Self-extension** - Agents can generate compatible variations
- **Pattern fidelity** - Validate changes maintain compatibility

The patterns are the DNA. The concrete implementation is one expression. Infinite compatible variations are possible.

The system can now understand itself, extend itself, and colonize new substrates while maintaining the essential patterns that define "Rio-compatible."
