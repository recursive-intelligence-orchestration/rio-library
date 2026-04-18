# Rio Library Troubleshooting Guide

## Overview

This guide covers common errors, diagnostic procedures, and solutions for Rio Library deployments. Use this when things don't work as expected.

## Quick Diagnostics

### Verify Installation

```bash
# Check library root marker exists
test -f .rio-library-root && echo "✓ Library root marker found" || echo "✗ Marker missing"

# Check discovery script exists and is executable
test -x find_library_root.sh && echo "✓ Discovery script ready" || echo "✗ Script missing or not executable"

# Check initialization script exists and is executable
test -x init_environment.sh && echo "✓ Initialization script ready" || echo "✗ Script missing or not executable"

# Test root discovery
./find_library_root.sh && echo "✓ Root discovery working" || echo "✗ Discovery failed"
```

### Verify Environment Initialization

```bash
# Run initialization
./init_environment.sh

# Check exported variables
echo "LIBRARY_ROOT: $LIBRARY_ROOT"
echo "CONTEXT_PATH: $CONTEXT_PATH"
echo "GENESIS_UUID: $GENESIS_UUID"

# Check symlinks were created
ls -la layers/common_layer/universal 2>/dev/null && echo "✓ Universal symlink exists" || echo "✗ Universal symlink missing"
ls -la layers/common_layer/context 2>/dev/null && echo "✓ Context symlink exists" || echo "✗ Context symlink missing"
```

### Verify Agent Deployment

```bash
# Check agent container directory exists
ls -d containers/a0-myagent && echo "✓ Agent container exists" || echo "✗ Agent container missing"

# Check docker-compose.yml was generated
test -f containers/a0-myagent/docker-compose.yml && echo "✓ Compose file exists" || echo "✗ Compose file missing"

# Check agent is running
docker ps | grep a0-myagent && echo "✓ Agent running" || echo "✗ Agent not running"
```

## Common Errors and Solutions

### Error: "ERROR: .rio-library-root not found"

**Symptom:**
```
ERROR: .rio-library-root not found
```

**Cause:** Running discovery from outside the library directory structure.

**Solution:**
```bash
# Ensure you're within the library
cd /path/to/rio-library

# Verify marker exists
ls -la .rio-library-root

# Try discovery again
./find_library_root.sh
```

**Prevention:** Always run scripts from within the library directory or its subdirectories.

---

### Error: "Permission denied" when running scripts

**Symptom:**
```
bash: ./find_library_root.sh: Permission denied
```

**Cause:** Scripts are not executable.

**Solution:**
```bash
# Make scripts executable
chmod +x find_library_root.sh
chmod +x init_environment.sh
chmod +x create_agent.sh

# Verify permissions
ls -la *.sh
```

**Prevention:** After cloning repository, run `chmod +x *.sh` once.

---

### Error: "envsubst: command not found"

**Symptom:**
```
./init_environment.sh: line XX: envsubst: command not found
```

**Cause:** `envsubst` (part of gettext package) is not installed.

**Solution:**
```bash
# Debian/Ubuntu
sudo apt-get install gettext-base

# RHEL/CentOS
sudo yum install gettext

# macOS
brew install gettext
```

**Prevention:** Include `envsubst` in prerequisites check.

---

### Error: "docker-compose.yml not generated"

**Symptom:** Agent directory exists but `docker-compose.yml` is missing.

**Cause:** Initialization script didn't run or template is missing.

**Diagnosis:**
```bash
# Check if template exists
ls -la templates/docker-compose.template.yml

# Check if environment variables are set
echo $LIBRARY_ROOT
echo $CONTEXT_PATH
```

**Solution:**
```bash
# Run initialization
./init_environment.sh

# Manually generate if needed
cd containers/a0-myagent
envsubst < ../../templates/docker-compose.template.yml > docker-compose.yml
```

**Prevention:** Always run `init_environment.sh` before deployment.

---

### Error: "Port already in use"

**Symptom:**
```
Error starting userland proxy: listen tcp4 0.0.0.0:50080: bind: address already in use
```

**Cause:** Another agent or service is using the same PORT_BASE.

**Diagnosis:**
```bash
# Check what's using the port
netstat -tuln | grep 50080
# or
lsof -i :50080

# Check running containers
docker ps | grep 50080
```

**Solution:**
```bash
# Option 1: Stop conflicting container
docker compose -f containers/other-agent/docker-compose.yml down

# Option 2: Use different PORT_BASE
./create_agent.sh a0-template a0-myagent port_base=600  # Instead of 500
```

**Prevention:** Maintain a PORT_BASE allocation table:
- 500-599: Experimental context
- 600-699: Personal context
- 700-799: Professional context

---

### Error: "Broken symlink" in layers

**Symptom:**
```bash
ls -la layers/common_layer/
# Shows: universal -> /wrong/path (broken)
```

**Cause:** Library was moved or initialization hasn't run.

**Diagnosis:**
```bash
# Check where symlink points
readlink layers/common_layer/universal

# Check if target exists
ls -la $(readlink layers/common_layer/universal)
```

**Solution:**
```bash
# Recreate symlinks by running initialization
./init_environment.sh

# Verify symlinks
ls -la layers/common_layer/universal
ls -la layers/common_layer/context
```

**Prevention:** Run `init_environment.sh` after moving library or cloning to new location.

---

### Error: "Agent can't access knowledge"

**Symptom:** Agent reports it cannot find knowledge files or documentation.

**Diagnosis:**
```bash
# Check bind mounts in docker-compose.yml
grep -A 5 "volumes:" containers/a0-myagent/docker-compose.yml

# Check if paths exist on host
ls -la ${LIBRARY_ROOT}/layers/common_layer/knowledge/

# Check inside container
docker exec a0-myagent ls -la /common_layer/knowledge/
```

**Solution:**
```bash
# Verify LIBRARY_ROOT is set correctly
echo $LIBRARY_ROOT

# Regenerate docker-compose.yml
./init_environment.sh
cd containers/a0-myagent
envsubst < ../../templates/docker-compose.template.yml > docker-compose.yml

# Restart container
docker compose down
docker compose up -d
```

**Prevention:** Always run `init_environment.sh` before generating configurations.

---

### Error: "Configuration mismatch"

**Symptom:** Agent's `/a0/tmp/settings.json` doesn't match actual filesystem.

**Diagnosis:**
```bash
# Read agent's settings
docker exec a0-myagent cat /a0/tmp/settings.json | jq .

# Check actual paths
docker exec a0-myagent ls -la /a0/memory/
docker exec a0-myagent ls -la /agent_layer/
```

**Solution:**
```bash
# Follow Config-First Rule: trust settings.json
# If settings are wrong, update them:
docker exec a0-myagent vi /a0/tmp/settings.json

# Or regenerate from template
# (depends on your layer structure)
```

**Prevention:** Always update `settings.json` when changing paths or structure.

---

### Error: "Docker daemon not accessible"

**Symptom:**
```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock
```

**Cause:** Docker is not running or user lacks permissions.

**Diagnosis:**
```bash
# Check if Docker is running
systemctl status docker

# Check if user is in docker group
groups | grep docker
```

**Solution:**
```bash
# Start Docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in for group changes to take effect
```

**Prevention:** Ensure Docker is installed and user has appropriate permissions.

---

### Error: "rsync: command not found"

**Symptom:**
```
./create_agent.sh: line XX: rsync: command not found
```

**Cause:** `rsync` is not installed.

**Solution:**
```bash
# Debian/Ubuntu
sudo apt-get install rsync

# RHEL/CentOS
sudo yum install rsync

# macOS (usually pre-installed)
brew install rsync
```

**Prevention:** Include `rsync` in prerequisites.

---

### Error: "Agent created but won't start"

**Symptom:** `create_agent.sh` completes but `docker compose up -d` fails.

**Diagnosis:**
```bash
# Check docker-compose.yml syntax
cd containers/a0-myagent
docker compose config

# Check logs
docker compose logs

# Check if ports are available
netstat -tuln | grep $(grep PORT_BASE .env | cut -d= -f2)
```

**Solution:**
```bash
# Fix docker-compose.yml syntax errors
# or
# Use different PORT_BASE if ports conflict
# or
# Check Docker logs for specific error
docker compose logs --tail=50
```

---

## Verification Procedures

### After Fresh Installation

```bash
# 1. Verify library structure
test -f .rio-library-root && echo "✓ Root marker" || echo "✗ Missing"
test -x find_library_root.sh && echo "✓ Discovery script" || echo "✗ Missing"
test -x init_environment.sh && echo "✓ Init script" || echo "✗ Missing"
test -x create_agent.sh && echo "✓ Create script" || echo "✗ Missing"

# 2. Test discovery
LIBRARY_ROOT=$(./find_library_root.sh)
echo "Library root: $LIBRARY_ROOT"

# 3. Run initialization
./init_environment.sh

# 4. Verify environment
echo "LIBRARY_ROOT: $LIBRARY_ROOT"
echo "CONTEXT_PATH: $CONTEXT_PATH"
echo "GENESIS_UUID: $GENESIS_UUID"

# 5. Check symlinks
ls -la layers/common_layer/universal
ls -la layers/common_layer/context
```

### After Agent Creation

```bash
AGENT_NAME="a0-myagent"

# 1. Verify container directory
test -d containers/$AGENT_NAME && echo "✓ Container dir" || echo "✗ Missing"

# 2. Verify layer directory
test -d layers/$AGENT_NAME && echo "✓ Layer dir" || echo "✗ Missing"

# 3. Verify docker-compose.yml
test -f containers/$AGENT_NAME/docker-compose.yml && echo "✓ Compose file" || echo "✗ Missing"

# 4. Verify .env files
test -f containers/$AGENT_NAME/.env && echo "✓ Container .env" || echo "✗ Missing"
test -f layers/$AGENT_NAME/.env && echo "✓ Layer .env" || echo "✗ Missing"

# 5. Check PORT_BASE
grep PORT_BASE containers/$AGENT_NAME/.env
```

### After Agent Startup

```bash
AGENT_NAME="a0-myagent"
PORT_BASE=$(grep PORT_BASE containers/$AGENT_NAME/.env | cut -d= -f2)

# 1. Check container is running
docker ps | grep $AGENT_NAME && echo "✓ Running" || echo "✗ Not running"

# 2. Check ports are listening
netstat -tuln | grep ${PORT_BASE}80 && echo "✓ HTTP port" || echo "✗ Not listening"
netstat -tuln | grep ${PORT_BASE}22 && echo "✓ SSH port" || echo "✗ Not listening"

# 3. Check mounts inside container
docker exec $AGENT_NAME ls -la /agent_container && echo "✓ Agent container mount" || echo "✗ Missing"
docker exec $AGENT_NAME ls -la /agent_layer && echo "✓ Agent layer mount" || echo "✗ Missing"
docker exec $AGENT_NAME ls -la /common_layer && echo "✓ Common layer mount" || echo "✗ Missing"

# 4. Check agent can access knowledge
docker exec $AGENT_NAME ls -la /common_layer/knowledge/default/main/rio-library/ && echo "✓ Knowledge accessible" || echo "✗ Not accessible"

# 5. Test HTTP access
curl -I http://localhost:${PORT_BASE}80 && echo "✓ HTTP responding" || echo "✗ Not responding"
```

## Diagnostic Commands

### Check Library State

```bash
# Show library root
./find_library_root.sh

# Show genesis info
cat .rio-library-root | jq .

# Show all agents
ls -d containers/a0-* 2>/dev/null

# Show running containers
docker ps --filter "name=a0-"
```

### Check Agent State

```bash
AGENT_NAME="a0-myagent"

# Show agent configuration
cat containers/$AGENT_NAME/.env

# Show agent settings
docker exec $AGENT_NAME cat /a0/tmp/settings.json 2>/dev/null | jq .

# Show agent mounts
docker inspect $AGENT_NAME | jq '.[0].Mounts'

# Show agent ports
docker port $AGENT_NAME
```

### Check Layer State

```bash
# Show layer structure
tree -L 3 layers/

# Show common layer symlinks
ls -la layers/common_layer/ | grep "^l"

# Show agent layer contents
ls -la layers/a0-myagent/
```

## Recovery Procedures

### Reset Agent

```bash
AGENT_NAME="a0-myagent"

# 1. Stop and remove container
cd containers/$AGENT_NAME
docker compose down

# 2. Remove container directory
cd ../..
rm -rf containers/$AGENT_NAME

# 3. Remove layer directory (WARNING: deletes agent data)
rm -rf layers/$AGENT_NAME

# 4. Recreate agent
./create_agent.sh a0-template $AGENT_NAME port_base=500
```

### Reset Library Environment

```bash
# 1. Remove generated symlinks
rm -f layers/common_layer/universal
rm -f layers/common_layer/context

# 2. Remove generated docker-compose files
find containers -name "docker-compose.yml" -delete

# 3. Reinitialize
./init_environment.sh

# 4. Regenerate agent configurations
for agent in containers/a0-*; do
    cd $agent
    envsubst < ../../templates/docker-compose.template.yml > docker-compose.yml
    cd ../..
done
```

### Repair Broken Mounts

```bash
AGENT_NAME="a0-myagent"

# 1. Stop agent
cd containers/$AGENT_NAME
docker compose down

# 2. Verify paths exist
ls -la ${LIBRARY_ROOT}/containers/$AGENT_NAME
ls -la ${LIBRARY_ROOT}/layers/$AGENT_NAME
ls -la ${LIBRARY_ROOT}/layers/common_layer

# 3. Regenerate docker-compose.yml
cd ../..
./init_environment.sh
cd containers/$AGENT_NAME
envsubst < ../../templates/docker-compose.template.yml > docker-compose.yml

# 4. Restart agent
docker compose up -d

# 5. Verify mounts
docker exec $AGENT_NAME ls -la /agent_container
docker exec $AGENT_NAME ls -la /agent_layer
docker exec $AGENT_NAME ls -la /common_layer
```

## Getting Help

### Collect Diagnostic Information

When reporting issues, collect this information:

```bash
#!/bin/bash
# Save as collect_diagnostics.sh

echo "=== Rio Library Diagnostics ==="
echo ""
echo "Library Root:"
./find_library_root.sh
echo ""
echo "Genesis Marker:"
cat .rio-library-root
echo ""
echo "Environment Variables:"
./init_environment.sh
echo "LIBRARY_ROOT: $LIBRARY_ROOT"
echo "CONTEXT_PATH: $CONTEXT_PATH"
echo "GENESIS_UUID: $GENESIS_UUID"
echo ""
echo "Agents:"
ls -d containers/a0-* 2>/dev/null
echo ""
echo "Running Containers:"
docker ps --filter "name=a0-"
echo ""
echo "Symlinks:"
ls -la layers/common_layer/ | grep "^l"
```

### Common Questions

**Q: How do I know if initialization worked?**
A: Check that `$LIBRARY_ROOT`, `$CONTEXT_PATH`, and `$GENESIS_UUID` are set, and symlinks exist in `layers/common_layer/`.

**Q: How do I verify mounts are correct?**
A: Run `docker exec <agent> ls -la /agent_container /agent_layer /common_layer` and verify all paths exist.

**Q: How do I check if agent can access layers?**
A: Run `docker exec <agent> ls -la /common_layer/knowledge/default/main/rio-library/` and verify documentation files are visible.

**Q: What should I do if ports conflict?**
A: Use a different `PORT_BASE` when creating the agent, or stop the conflicting container.

**Q: How do I backup agent data?**
A: Copy `layers/<agent>/memory/` and `layers/<agent>/.env` to backup location. These contain persistent agent state.

## Summary

Most Rio Library issues fall into these categories:

1. **Discovery failures** - Run from wrong directory or marker missing
2. **Initialization failures** - Missing dependencies or scripts not executable
3. **Mount failures** - Paths don't exist or docker-compose.yml not generated
4. **Port conflicts** - Multiple agents using same PORT_BASE
5. **Permission issues** - Docker not accessible or scripts not executable

**General troubleshooting approach:**
1. Verify prerequisites installed
2. Run initialization script
3. Check environment variables are set
4. Verify paths exist
5. Check Docker logs for specific errors
6. Consult this guide for specific error messages
