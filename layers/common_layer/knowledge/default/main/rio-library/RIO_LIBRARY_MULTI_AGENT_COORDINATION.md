# Rio Library Multi-Agent Coordination

## Overview

This document describes patterns and protocols for coordinating multiple Agent Zero instances deployed through Rio Library. These patterns are extracted from production multi-agent deployments and enable agents to discover, communicate, and collaborate while maintaining autonomy.

**Status:** Production-tested patterns from real deployments.

---

## Core Coordination Patterns

### Parent-Child Relationship

The fundamental coordination pattern where one agent spawns and tracks child agents.

**Parent Agent Responsibilities:**
- Tracks spawned instances in persistent metadata
- Provides knowledge sharing on request
- Maintains lineage records
- Enables sibling discovery (policy-controlled)
- Does NOT control child behavior (autonomy preserved)

**Child Agent Responsibilities:**
- Knows parent identity and location
- Can request parent knowledge
- Operates independently
- Evolves according to own policy
- Reports status to parent (optional)

**Key Principle:** Parent-child is a **relationship**, not a hierarchy. Children are autonomous.

---

### Sibling Relationship

Agents spawned by the same parent can coordinate as peers.

**Sibling Capabilities:**
- Discover each other through parent metadata
- Share knowledge (if policy allows)
- Operate independently
- No hierarchy among siblings
- Coordinate on shared tasks (optional)

**Key Principle:** Siblings are **peers**, not subordinates. Coordination is voluntary.

---

## Coordination Protocol

### Instance Tracking

Parent agents track spawned instances using `extension.json` in their layer directory.

**Location:** `layers/<parent-agent>/extension.json`

**Schema:**
```json
{
  "spawned_instances": [
    {
      "identity": "agent-name",
      "purpose": "Brief description of agent's role",
      "created": "ISO-8601 timestamp",
      "status": "active|paused|terminated",
      "location": "connection-string",
      "genesis_uuid": "child-agent-genesis-uuid"
    }
  ],
  "coordination_policy": {
    "allow_sibling_discovery": true,
    "allow_knowledge_sharing": true,
    "require_status_updates": false
  }
}
```

**Example:**
```json
{
  "spawned_instances": [
    {
      "identity": "urban-planner",
      "purpose": "City transit optimization",
      "created": "2026-04-18T22:00:00Z",
      "status": "active",
      "location": "http://localhost:50001",
      "genesis_uuid": "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
    },
    {
      "identity": "research-assistant",
      "purpose": "Literature review and synthesis",
      "created": "2026-04-18T22:30:00Z",
      "status": "active",
      "location": "http://localhost:50002",
      "genesis_uuid": "b2c3d4e5-f6a7-8901-bcde-f12345678901"
    }
  ],
  "coordination_policy": {
    "allow_sibling_discovery": true,
    "allow_knowledge_sharing": true,
    "require_status_updates": false
  }
}
```

---

### Discovery Mechanisms

**Parent Discovery:**
Child agents discover their parent through configuration at creation time.

**Location:** `layers/<child-agent>/extension.json`

```json
{
  "parent_instance": {
    "identity": "parent-agent-name",
    "location": "http://localhost:50000",
    "genesis_uuid": "parent-genesis-uuid"
  }
}
```

**Sibling Discovery:**
Child agents discover siblings by reading parent's `spawned_instances` array.

**Process:**
1. Child reads own `extension.json` to find parent location
2. Child requests parent's `extension.json` (if policy allows)
3. Child reads `spawned_instances` array
4. Child filters for active siblings
5. Child can contact siblings directly

---

### Communication Patterns

**Parent-to-Child:**
- Knowledge sharing requests
- Policy updates
- Coordination requests (not commands)

**Child-to-Parent:**
- Status updates (if required by policy)
- Knowledge requests
- Sibling discovery requests

**Sibling-to-Sibling:**
- Direct communication (no parent mediation)
- Knowledge sharing
- Task coordination
- Collaborative problem-solving

**Communication Channels:**
- HTTP API endpoints (Agent Zero web interface)
- Shared knowledge directories (bind-mounted volumes)
- Message files in common_layer
- Database connections (if configured)

---

## Knowledge Sharing Patterns

### Shared Knowledge Directory

Agents can share knowledge through common_layer mount points.

**Structure:**
```
layers/common_layer/knowledge/shared/
├── parent-agent/
│   ├── shared-knowledge.md
│   └── coordination-state.json
└── cross-agent/
    ├── shared-memory.md
    └── collaborative-notes.md
```

**Access Control:**
- Read-only: Agents can read shared knowledge
- Write: Only owning agent writes to own directory
- Coordination: Use cross-agent directory for collaborative content

---

### Knowledge Request Protocol

**Child requests knowledge from parent:**

1. Child reads parent location from own `extension.json`
2. Child sends HTTP request to parent's API endpoint
3. Parent validates request against policy
4. Parent provides knowledge or denies request
5. Child integrates knowledge into own context

**Implementation:**
```bash
# Child agent requests parent knowledge
curl -X POST http://parent-location:port/api/knowledge-request \
  -H "Content-Type: application/json" \
  -d '{
    "requester": "child-agent-name",
    "requester_uuid": "child-genesis-uuid",
    "knowledge_type": "domain-specific-knowledge",
    "reason": "Need context for task X"
  }'
```

---

## Multi-Agent Deployment Patterns

### Pattern 1: Single-Host Multi-Agent

Multiple agents on same host with port separation.

**Configuration:**
```yaml
# Parent agent on port 50000
containers/a0-parent/.env:
  PORT_BASE=50000

# Child agent 1 on port 50001
containers/a0-child-1/.env:
  PORT_BASE=50001

# Child agent 2 on port 50002
containers/a0-child-2/.env:
  PORT_BASE=50002
```

**Network:** All agents on localhost, different ports

**Advantages:**
- Simple networking
- Fast communication
- Shared filesystem possible

**Limitations:**
- Single point of failure
- Resource contention
- Port management required

---

### Pattern 2: Multi-Host Distributed

Agents distributed across multiple hosts.

**Configuration:**
```json
// Parent tracks remote children
{
  "spawned_instances": [
    {
      "identity": "remote-worker-1",
      "location": "http://host1.example.com:50000",
      "status": "active"
    },
    {
      "identity": "remote-worker-2",
      "location": "http://host2.example.com:50000",
      "status": "active"
    }
  ]
}
```

**Network:** Agents on different hosts, HTTP communication

**Advantages:**
- Fault isolation
- Resource distribution
- Geographic distribution possible

**Limitations:**
- Network latency
- More complex networking
- Shared filesystem requires NFS or similar

---

### Pattern 3: Hierarchical Multi-Tier

Multiple levels of parent-child relationships.

**Structure:**
```
Root Agent (Orchestrator)
├── Regional Agent 1
│   ├── Local Agent 1a
│   └── Local Agent 1b
└── Regional Agent 2
    ├── Local Agent 2a
    └── Local Agent 2b
```

**Use Cases:**
- Geographic distribution
- Organizational hierarchy
- Specialized domains

**Coordination:**
- Each level tracks immediate children only
- Knowledge flows up/down hierarchy
- Siblings coordinate at each level

---

## Coordination Workflows

### Workflow 1: Spawning Child Agent

**Parent agent spawns child:**

1. Parent decides to spawn child agent
2. Parent uses `create_agent.sh` to clone template
3. Parent configures child's `extension.json` with parent info
4. Parent updates own `extension.json` with child info
5. Parent starts child container
6. Child reads config and discovers parent
7. Child reports ready status to parent (optional)

**Implementation:**
```bash
# Parent agent executes (via code_execution_tool)
cd /a0/instruments/default/main/rio-library

# Create child agent
./create_agent.sh \
  --source-agent a0-template \
  --target-agent a0-child-worker \
  --port-base 50001 \
  --auth-login child_user \
  --auth-password secure_password

# Update parent's extension.json
# (Parent agent writes this programmatically)

# Start child container
cd /containers/a0-child-worker
docker compose up -d
```

---

### Workflow 2: Sibling Coordination

**Siblings coordinate on shared task:**

1. Sibling A discovers Sibling B through parent metadata
2. Sibling A contacts Sibling B directly
3. Siblings negotiate task division
4. Siblings work independently on subtasks
5. Siblings share results through common_layer
6. Siblings synthesize final result
7. Siblings report completion to parent (optional)

**Knowledge Sharing:**
```bash
# Sibling A writes partial result
echo "Partial analysis from Sibling A" > \
  /layers/common_layer/knowledge/shared/cross-agent/task-123-partial-a.md

# Sibling B reads and adds own analysis
cat /layers/common_layer/knowledge/shared/cross-agent/task-123-partial-a.md
echo "Partial analysis from Sibling B" > \
  /layers/common_layer/knowledge/shared/cross-agent/task-123-partial-b.md

# Either sibling synthesizes final result
cat task-123-partial-*.md > task-123-final.md
```

---

### Workflow 3: Knowledge Propagation

**Parent shares knowledge with all children:**

1. Parent updates shared knowledge in common_layer
2. Parent notifies children of update (optional)
3. Children read updated knowledge
4. Children integrate into own context
5. Children apply to ongoing work

**Shared Knowledge Location:**
```
layers/common_layer/knowledge/shared/parent-agent/
└── domain-knowledge.md  # All children can read
```

---

## Coordination Policies

### Policy Configuration

Define coordination rules in parent's `extension.json`:

```json
{
  "coordination_policy": {
    "allow_sibling_discovery": true,
    "allow_knowledge_sharing": true,
    "require_status_updates": false,
    "knowledge_sharing_scope": "domain-specific",
    "max_children": 10,
    "auto_cleanup_terminated": true
  }
}
```

**Policy Fields:**
- `allow_sibling_discovery`: Can children discover each other?
- `allow_knowledge_sharing`: Can children request parent knowledge?
- `require_status_updates`: Must children report status?
- `knowledge_sharing_scope`: What knowledge is shareable?
- `max_children`: Maximum spawned instances
- `auto_cleanup_terminated`: Remove terminated children from tracking?

---

### Security Considerations

**Authentication:**
- Each agent has own credentials
- Parent does NOT have child credentials
- Children authenticate to parent for knowledge requests

**Authorization:**
- Policy controls what knowledge is shareable
- Children cannot access parent's private knowledge
- Siblings cannot access each other's private knowledge

**Isolation:**
- Each agent runs in own container
- Separate memory and state
- Shared knowledge is explicit, not accidental

---

## Monitoring Multi-Agent Systems

### Health Checks

**Parent monitors children:**
```bash
# Check child agent health
curl http://localhost:50001/health

# Expected response:
{
  "status": "healthy",
  "agent": "a0-child-worker",
  "uptime": "3h 24m",
  "last_activity": "2026-04-18T22:45:00Z"
}
```

**Automated Monitoring:**
```bash
# Parent agent script to check all children
for instance in $(jq -r '.spawned_instances[].location' extension.json); do
  echo "Checking $instance"
  curl -s "$instance/health" || echo "UNHEALTHY: $instance"
done
```

---

### Status Tracking

**Child reports status to parent:**
```bash
# Child updates own status
curl -X POST http://parent-location:50000/api/status-update \
  -H "Content-Type: application/json" \
  -d '{
    "identity": "child-agent-name",
    "status": "active",
    "current_task": "Processing dataset X",
    "progress": 0.65,
    "timestamp": "2026-04-18T22:50:00Z"
  }'
```

**Parent updates tracking:**
```json
{
  "spawned_instances": [
    {
      "identity": "child-agent-name",
      "status": "active",
      "last_update": "2026-04-18T22:50:00Z",
      "current_task": "Processing dataset X",
      "progress": 0.65
    }
  ]
}
```

---

## Troubleshooting Multi-Agent Coordination

### Issue: Child Cannot Discover Parent

**Symptoms:**
- Child agent cannot read parent's extension.json
- Child reports "parent not found"

**Diagnosis:**
```bash
# Check child's parent configuration
cat /layers/<child-agent>/extension.json | jq '.parent_instance'

# Verify parent location is reachable
curl http://parent-location:port/health
```

**Solutions:**
- Verify parent location in child's extension.json
- Check network connectivity between agents
- Verify parent agent is running
- Check firewall rules if multi-host

---

### Issue: Sibling Discovery Fails

**Symptoms:**
- Sibling cannot read parent's spawned_instances
- Policy denies sibling discovery

**Diagnosis:**
```bash
# Check parent's coordination policy
cat /layers/<parent-agent>/extension.json | jq '.coordination_policy.allow_sibling_discovery'

# Verify child can reach parent
curl http://parent-location:port/api/spawned-instances
```

**Solutions:**
- Enable sibling discovery in parent policy
- Verify child has read access to parent metadata
- Check authentication if required

---

### Issue: Knowledge Sharing Blocked

**Symptoms:**
- Child requests knowledge but receives denial
- Parent policy restricts sharing

**Diagnosis:**
```bash
# Check parent's sharing policy
cat /layers/<parent-agent>/extension.json | jq '.coordination_policy.allow_knowledge_sharing'

# Check knowledge scope
jq '.coordination_policy.knowledge_sharing_scope' extension.json
```

**Solutions:**
- Enable knowledge sharing in parent policy
- Verify requested knowledge is within scope
- Check child authentication

---

## Best Practices

### Coordination Design

**1. Preserve Autonomy**
- Children operate independently
- Parent provides resources, not commands
- Coordination is voluntary, not forced

**2. Explicit Communication**
- Use structured protocols (JSON)
- Document coordination patterns
- Log coordination events

**3. Policy-Driven**
- Define coordination rules explicitly
- Make policies discoverable
- Allow policy evolution

**4. Fault Tolerance**
- Children survive parent failure
- Parent tracks but doesn't control
- Graceful degradation on communication loss

---

### Scaling Considerations

**Single-Host Limits:**
- Port exhaustion (65535 ports max)
- Resource contention (CPU, memory)
- Filesystem I/O bottlenecks

**Multi-Host Benefits:**
- Resource distribution
- Fault isolation
- Geographic distribution

**Coordination Overhead:**
- More agents = more coordination cost
- Consider hierarchical patterns for scale
- Use asynchronous communication

---

## Integration with Rio Patterns

### Pattern DNA Compatibility

Multi-agent coordination preserves all 11 Rio invariants:

1. **Self-Discovery:** Each agent discovers own root independently
2. **Layer Hierarchy:** Each agent has own layer stack
3. **Separation of Concerns:** Each agent's config/code/data separated
4. **Dynamic Generation:** Each agent generates own configs
5. **Config-First:** Each agent reads own authoritative config
6. **Methodology Neutrality:** Coordination doesn't impose methodology
7. **Meta-Awareness:** Each agent introspects own infrastructure
8. **Boundary & Permeability:** Each agent has own boundaries
9. **State Lifecycle:** Each agent manages own lifecycle
10. **Dual Configuration:** Each agent has orchestration + runtime config
11. **Emergent Properties:** Coordination enables collective intelligence

**Key Insight:** Multi-agent coordination is an **emergent property** of Rio's pattern DNA, not a separate system.

---

## Future Patterns

This section captures coordination patterns observed in production that may be formalized:

**Placeholder for agent-contributed coordination patterns**

*Agents: Document observed coordination patterns here. Include:*
- *Pattern description*
- *Use case*
- *Implementation details*
- *Benefits and trade-offs*

---

## Conclusion

Multi-agent coordination in Rio Library enables:
- **Autonomous operation** - Agents coordinate without central control
- **Scalable deployment** - Single-host to distributed multi-tier
- **Knowledge sharing** - Policy-controlled, explicit protocols
- **Fault tolerance** - Agents survive coordination failures
- **Pattern fidelity** - Coordination preserves all Rio invariants

The coordination patterns are **production-tested** from real multi-agent deployments and enable agents to collaborate while maintaining autonomy and pattern compatibility.

**Pattern source:** Extracted from Indras-Net multi-instance deployment + Self-Replication Protocol documentation.
