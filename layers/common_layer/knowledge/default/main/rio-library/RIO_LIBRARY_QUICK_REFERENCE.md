# Rio Library Quick Reference

## Essential Commands

### Discovery and Initialization

```bash
# Discover library root
./find_library_root.sh

# Initialize environment
./init_environment.sh

# Check environment variables
echo $LIBRARY_ROOT
echo $CONTEXT_PATH
echo $GENESIS_UUID
```

### Agent Creation

```bash
# Minimal (uses defaults)
./create_agent.sh a0-template a0-myagent

# With port and display name
./create_agent.sh a0-template a0-myagent \
  dest_display="My Agent" port_base=500

# Full configuration
./create_agent.sh a0-template a0-myagent \
  dest_display="My Agent" \
  port_base=500 \
  auth_login=myuser \
  auth_password=mypassword \
  knowledge_dir=custom \
  memory_subdir=myagent-memory
```

### Agent Management

```bash
# Start agent
cd containers/a0-myagent
docker compose up -d

# Stop agent
docker compose down

# Restart agent
docker compose restart

# View logs
docker compose logs -f

# Check status
docker compose ps
```

### Agent Access

```bash
# Execute command in agent
docker exec a0-myagent <command>

# Shell into agent
docker exec -it a0-myagent bash

# View agent settings
docker exec a0-myagent cat /a0/tmp/settings.json
```

## Port Calculation

### Pattern

```
PORT_BASE = NNN

HTTP  = NNN80
SSH   = NNN22
HTTPS = NNN43
```

### Examples

| PORT_BASE | HTTP   | SSH    | HTTPS  |
|-----------|--------|--------|--------|
| 500       | 50080  | 50022  | 50043  |
| 600       | 60080  | 60022  | 60043  |
| 700       | 70080  | 70022  | 70043  |
| 800       | 80080  | 80022  | 80043  |

### Allocation Strategy

- **500-599**: Experimental context
- **600-699**: Personal context
- **700-799**: Professional context
- **800-899**: Reserved

## Environment Variables

### Discovered Variables

Set by `init_environment.sh`:

| Variable       | Description                    | Example                              |
|----------------|--------------------------------|--------------------------------------|
| LIBRARY_ROOT   | Absolute path to library root  | `/mnt/rootfs/rio-library`           |
| CONTEXT_PATH   | Relative path from root        | `experimental/production`           |
| GENESIS_UUID   | Unique library identifier      | `b5ae486e-1b42-4fa5-a47e-73f793bb1a0e` |

### Container Variables

Set in `containers/<agent>/.env`:

| Variable       | Description                    | Example                              |
|----------------|--------------------------------|--------------------------------------|
| CONTAINER_NAME | Agent container name           | `a0-myagent`                        |
| PORT_BASE      | Base port number               | `500`                               |
| KNOWLEDGE_DIR  | Knowledge directory name       | `custom`                            |

### Layer Variables

Set in `layers/<agent>/.env`:

| Variable       | Description                    | Example                              |
|----------------|--------------------------------|--------------------------------------|
| AUTH_LOGIN     | Agent login username           | `myuser`                            |
| AUTH_PASSWORD  | Agent login password           | `mypassword`                        |
| ROOT_PASSWORD  | Agent root password            | `secure_root_pass`                  |

## Layer Resolution Order

When agent looks for resource:

```
1. Agent Layer (/agent_layer)
   ↓ Most specific
   
2. Control Layer (/control_layer)
   ↓ System-wide
   
3. Common Layer (/common_layer)
   ↓ Universal
   
4. Base Image
   ↓ Fallback
```

**Example:** Finding `prompts/agent.system.main.role.md`

1. Check `/agent_layer/prompts/agent.system.main.role.md`
2. If not found, check `/control_layer/prompts/agent.system.main.role.md`
3. If not found, check `/common_layer/prompts/agent.system.main.role.md`
4. If not found, use base image default

## Mount Points

### Standard Agent Mounts

| Host Path                                    | Container Path      | Mode |
|---------------------------------------------|---------------------|------|
| `${LIBRARY_ROOT}/containers/${AGENT_NAME}`  | `/agent_container`  | ro   |
| `${LIBRARY_ROOT}/layers/${AGENT_NAME}`      | `/agent_layer`      | ro   |
| `${LIBRARY_ROOT}/layers/common_layer`       | `/common_layer`     | ro   |
| `${LIBRARY_ROOT}/layers/control_layer`      | `/control_layer`    | ro   |
| `${LIBRARY_ROOT}/layers/${AGENT_NAME}/memory` | `/a0/memory`      | rw   |
| `${LIBRARY_ROOT}/layers/${AGENT_NAME}/tmp`  | `/a0/tmp`           | rw   |

**ro** = read-only, **rw** = read-write

## File Locations

### Configuration Files

| File                                  | Purpose                          |
|---------------------------------------|----------------------------------|
| `.rio-library-root`                   | Genesis marker                   |
| `containers/<agent>/.env`             | Container environment            |
| `layers/<agent>/.env`                 | Agent runtime environment        |
| `layers/<agent>/tmp/settings.json`    | Agent configuration              |
| `containers/<agent>/docker-compose.yml` | Docker orchestration           |

### Documentation

| File                                  | Purpose                          |
|---------------------------------------|----------------------------------|
| `README.md`                           | Main documentation               |
| `layers/common_layer/knowledge/default/main/rio-library/*.md` | Reference docs |

### Scripts

| File                    | Purpose                          |
|-------------------------|----------------------------------|
| `find_library_root.sh`  | Discover library root            |
| `init_environment.sh`   | Initialize environment           |
| `create_agent.sh`       | Create new agent                 |

## Common Workflows

### Add Custom Knowledge

```bash
# 1. Create knowledge directory
mkdir -p layers/common_layer/knowledge/custom/my_domain

# 2. Add knowledge files
cat > layers/common_layer/knowledge/custom/my_domain/overview.md << 'EOF'
# My Domain Knowledge
Content here...
EOF

# 3. Agent can access at:
# /common_layer/knowledge/custom/my_domain/overview.md
```

### Create Custom Profile

```bash
# 1. Create profile module
mkdir -p layers/control_layer/profile_modules/my_profile

# 2. Define profile
cat > layers/control_layer/profile_modules/my_profile/profiles.json << 'EOF'
{
  "profile_type": "my_profile",
  "profiles": {
    "default": {"name": "Default Profile"}
  }
}
EOF

# 3. Create profile content
mkdir -p layers/control_layer/profile_modules/my_profile/profiles
cat > layers/control_layer/profile_modules/my_profile/profiles/default.md << 'EOF'
# Default Profile
Guidelines here...
EOF
```

### Override Agent Behavior

```bash
# 1. Create agent-specific prompt
mkdir -p layers/a0-myagent/prompts
cat > layers/a0-myagent/prompts/agent.system.main.role.md << 'EOF'
# Custom Agent Role
This agent has specialized behavior...
EOF

# 2. Restart agent
cd containers/a0-myagent
docker compose restart
```

## Troubleshooting Quick Checks

### Verify Installation

```bash
test -f .rio-library-root && echo "✓" || echo "✗ Missing marker"
test -x find_library_root.sh && echo "✓" || echo "✗ Script not executable"
./find_library_root.sh && echo "✓" || echo "✗ Discovery failed"
```

### Verify Agent

```bash
AGENT="a0-myagent"
docker ps | grep $AGENT && echo "✓ Running" || echo "✗ Not running"
docker exec $AGENT ls /agent_layer && echo "✓ Mounted" || echo "✗ Mount failed"
```

### Check Ports

```bash
PORT_BASE=500
netstat -tuln | grep ${PORT_BASE}80 && echo "✓ HTTP" || echo "✗ Not listening"
netstat -tuln | grep ${PORT_BASE}22 && echo "✗ SSH" || echo "✗ Not listening"
```

## Diagnostic Commands

```bash
# Show library info
cat .rio-library-root | jq .

# Show all agents
ls -d containers/a0-* 2>/dev/null

# Show running containers
docker ps --filter "name=a0-"

# Show agent configuration
cat containers/a0-myagent/.env

# Show agent settings
docker exec a0-myagent cat /a0/tmp/settings.json | jq .

# Show agent mounts
docker inspect a0-myagent | jq '.[0].Mounts'
```

## create_agent.sh Parameters

### Required

- `source` - Template agent name (e.g., `a0-template`)
- `dest` - New agent name (e.g., `a0-myagent`)

### Optional

| Parameter        | Description                          | Example                |
|------------------|--------------------------------------|------------------------|
| dest_display     | Human-readable name                  | `"My Agent"`          |
| dest_profile     | Profile ID                           | `myagent-profile`     |
| source_profile   | Source profile ID                    | `a0-template`         |
| port_base        | Base port (0-654)                    | `500`                 |
| knowledge_dir    | Knowledge directory                  | `custom`              |
| memory_subdir    | Memory subdirectory                  | `myagent-memory`      |
| no_docker        | Skip docker compose up               | `true`                |
| root_password    | Root password                        | `secure_pass`         |
| auth_login       | Login username                       | `myuser`              |
| auth_password    | Login password                       | `mypassword`          |

## URL Access Patterns

### HTTP Access

```
http://localhost:${PORT_BASE}80
```

Examples:
- PORT_BASE=500: http://localhost:50080
- PORT_BASE=600: http://localhost:60080

### SSH Access

```
ssh://localhost:${PORT_BASE}22
```

Examples:
- PORT_BASE=500: ssh://localhost:50022
- PORT_BASE=600: ssh://localhost:60022

### HTTPS Access (nginx)

```
https://localhost:${PORT_BASE}43
```

Examples:
- PORT_BASE=500: https://localhost:50043
- PORT_BASE=600: https://localhost:60043

## Directory Quick Reference

```
rio-library/
├── .rio-library-root        # Genesis marker
├── *.sh                     # Scripts
├── templates/               # Config templates
├── containers/              # Agent containers
│   └── a0-*/               # Agent directories
├── layers/                  # Customization layers
│   ├── a0-*/               # Agent layers
│   ├── common_layer/       # Shared layer
│   └── control_layer/      # System control
└── volumes/                 # Persistent data
```

## Git Quick Reference

### What to Commit

- Scripts (*.sh)
- Templates (templates/*)
- Template agent (containers/a0-template/)
- Template layer (layers/a0-template/)
- Shared layers (layers/common_layer/, layers/control_layer/)
- Documentation (*.md)

### What NOT to Commit

- Generated files (docker-compose.yml)
- Deployed agents (containers/a0-*, layers/a0-*)
- Symlinks (layers/common_layer/universal, layers/common_layer/context)
- Agent data (*/memory/, */tmp/)
- Secrets (.env files with passwords)

## Common Error Messages

| Error                                  | Solution                                    |
|----------------------------------------|---------------------------------------------|
| "ERROR: .rio-library-root not found"   | Run from within library directory           |
| "Permission denied"                    | `chmod +x *.sh`                            |
| "envsubst: command not found"          | Install gettext-base package                |
| "Port already in use"                  | Use different PORT_BASE                     |
| "docker-compose.yml not generated"     | Run `init_environment.sh`                  |
| "Broken symlink"                       | Run `init_environment.sh`                  |

## Performance Tips

- Use read-only mounts for configuration (`:ro`)
- Keep agent memory on fast storage
- Limit log file sizes
- Clean up old containers: `docker system prune`
- Monitor disk usage: `du -sh layers/*/memory/`

## Security Checklist

- [ ] Change default AUTH_LOGIN and AUTH_PASSWORD
- [ ] Use strong ROOT_PASSWORD
- [ ] Don't commit .env files with secrets
- [ ] Use HTTPS for production deployments
- [ ] Restrict network access with firewall rules
- [ ] Keep Docker and Agent Zero updated
- [ ] Review agent permissions regularly
- [ ] Backup agent memory and configuration

## Useful Aliases

Add to `~/.bashrc` or `~/.zshrc`:

```bash
# Rio Library aliases
alias rio-init='./init_environment.sh'
alias rio-create='./create_agent.sh'
alias rio-root='./find_library_root.sh'
alias rio-agents='ls -d containers/a0-* 2>/dev/null'
alias rio-running='docker ps --filter "name=a0-"'
```

## Summary

**Most common operations:**

1. **Initialize:** `./init_environment.sh`
2. **Create agent:** `./create_agent.sh a0-template a0-myagent port_base=500`
3. **Start agent:** `cd containers/a0-myagent && docker compose up -d`
4. **Access agent:** `http://localhost:50080` (for PORT_BASE=500)
5. **View logs:** `docker compose logs -f`
6. **Stop agent:** `docker compose down`

**Most common issues:**

1. Scripts not executable → `chmod +x *.sh`
2. Environment not initialized → `./init_environment.sh`
3. Port conflicts → Use different PORT_BASE
4. Mount failures → Check paths and regenerate docker-compose.yml
5. Agent can't access knowledge → Verify mounts with `docker inspect`
