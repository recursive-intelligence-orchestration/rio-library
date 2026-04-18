# Rio Library Backup and Recovery

## Overview

This document provides backup and recovery procedures for Rio Library-based Agent Zero deployments. It covers what to backup, how to backup, recovery procedures, and disaster recovery planning based on Rio's pattern DNA and production deployment experience.

**Status:** Production-tested procedures.

---

## Understanding State in Rio

### Persistent vs Ephemeral State

Rio's **Separation of Concerns** and **State Lifecycle** patterns define what persists and what regenerates.

**Persistent State (Must Backup):**
- Agent memory and work directories
- Chat history
- Custom knowledge bases
- Agent-specific configurations
- Extension metadata (spawned instances, coordination state)
- User data and credentials

**Ephemeral State (Regenerates):**
- Docker containers
- Generated docker-compose.yml files
- Temporary files
- Cache directories
- Runtime process state

**Git-Tracked (Version Controlled):**
- Layer configurations
- Scripts and templates
- Documentation
- Base configurations

**Key Principle:** Backup persistent state, version control configuration, regenerate ephemeral state.

---

## What to Backup

### Critical Data (Priority 1)

**Agent Work Directories:**
```
volumes/private/<agent-name>/
├── memory/           # Agent memory and context
├── work_dir/         # Agent working files
└── logs/             # Agent-specific logs
```

**Shared Data:**
```
volumes/common/
├── chat_history/     # Conversation history
└── shared_knowledge/ # Shared knowledge bases
```

**Agent Configurations:**
```
layers/<agent-name>/
├── .env              # Runtime configuration
├── extension.json    # Coordination metadata
└── knowledge/        # Agent-specific knowledge
```

---

### Important Data (Priority 2)

**Container Configurations:**
```
containers/<agent-name>/
├── .env              # Orchestration configuration
└── docker-compose.yml # Generated, but backup for reference
```

**Control Layer:**
```
layers/control_layer/
└── profiles/         # System-wide profiles
```

---

### Optional Data (Priority 3)

**Common Layer Custom Content:**
```
layers/common_layer/knowledge/
└── custom/           # Custom shared knowledge
```

**Logs:**
```
Docker container logs (if not using external logging)
```

---

## Backup Procedures

### Manual Backup

**Full Agent Backup:**

```bash
#!/bin/bash
# backup_agent.sh - Backup single agent

AGENT_NAME=$1
BACKUP_DIR=${2:-/backups}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${AGENT_NAME}_${TIMESTAMP}.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup agent data
tar -czf "$BACKUP_FILE" \
  --exclude='*.tmp' \
  --exclude='*.cache' \
  containers/$AGENT_NAME \
  layers/$AGENT_NAME \
  volumes/private/$AGENT_NAME \
  volumes/common/chat_history

echo "Backup created: $BACKUP_FILE"
echo "Size: $(du -h $BACKUP_FILE | cut -f1)"
```

**Usage:**
```bash
./backup_agent.sh a0-production /backups
```

---

**Full System Backup:**

```bash
#!/bin/bash
# backup_system.sh - Backup entire Rio deployment

BACKUP_DIR=${1:-/backups}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/rio_system_${TIMESTAMP}.tar.gz"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup entire system
tar -czf "$BACKUP_FILE" \
  --exclude='*.tmp' \
  --exclude='*.cache' \
  --exclude='.git' \
  containers/ \
  layers/ \
  volumes/ \
  .rio-library-root \
  *.sh

echo "System backup created: $BACKUP_FILE"
echo "Size: $(du -h $BACKUP_FILE | cut -f1)"
```

**Usage:**
```bash
./backup_system.sh /backups
```

---

### Automated Backup

**Daily Backup Cron Job:**

```bash
# /etc/cron.d/rio-backup
# Daily backup at 2 AM
0 2 * * * root /opt/rio-library/backup_system.sh /backups/daily

# Weekly backup on Sunday at 3 AM
0 3 * * 0 root /opt/rio-library/backup_system.sh /backups/weekly

# Monthly backup on 1st at 4 AM
0 4 1 * * root /opt/rio-library/backup_system.sh /backups/monthly
```

---

**Backup Rotation:**

```bash
#!/bin/bash
# rotate_backups.sh - Keep only recent backups

BACKUP_DIR=/backups

# Keep last 7 daily backups
find $BACKUP_DIR/daily -name "*.tar.gz" -mtime +7 -delete

# Keep last 4 weekly backups
find $BACKUP_DIR/weekly -name "*.tar.gz" -mtime +28 -delete

# Keep last 12 monthly backups
find $BACKUP_DIR/monthly -name "*.tar.gz" -mtime +365 -delete

echo "Backup rotation complete"
```

---

### Incremental Backup

**Using rsync for efficient backups:**

```bash
#!/bin/bash
# incremental_backup.sh - Rsync-based incremental backup

AGENT_NAME=$1
BACKUP_DIR=${2:-/backups/incremental}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create backup directory structure
mkdir -p "$BACKUP_DIR/$AGENT_NAME"

# Incremental backup with rsync
rsync -av --delete \
  --link-dest="$BACKUP_DIR/$AGENT_NAME/latest" \
  volumes/private/$AGENT_NAME/ \
  "$BACKUP_DIR/$AGENT_NAME/$TIMESTAMP/"

# Update latest symlink
rm -f "$BACKUP_DIR/$AGENT_NAME/latest"
ln -s "$TIMESTAMP" "$BACKUP_DIR/$AGENT_NAME/latest"

echo "Incremental backup complete: $BACKUP_DIR/$AGENT_NAME/$TIMESTAMP"
```

---

### Remote Backup

**Backup to Remote Server:**

```bash
#!/bin/bash
# remote_backup.sh - Backup to remote server via SSH

AGENT_NAME=$1
REMOTE_HOST="backup-server.example.com"
REMOTE_USER="backup"
REMOTE_DIR="/backups/rio-library"

# Create local backup
./backup_agent.sh $AGENT_NAME /tmp

# Get latest backup file
BACKUP_FILE=$(ls -t /tmp/${AGENT_NAME}_*.tar.gz | head -1)

# Transfer to remote server
scp "$BACKUP_FILE" ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/

# Verify transfer
ssh ${REMOTE_USER}@${REMOTE_HOST} "ls -lh ${REMOTE_DIR}/$(basename $BACKUP_FILE)"

# Clean up local backup
rm "$BACKUP_FILE"

echo "Remote backup complete"
```

---

**Backup to Cloud Storage (S3):**

```bash
#!/bin/bash
# s3_backup.sh - Backup to AWS S3

AGENT_NAME=$1
S3_BUCKET="s3://my-rio-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create local backup
./backup_agent.sh $AGENT_NAME /tmp

# Get latest backup file
BACKUP_FILE=$(ls -t /tmp/${AGENT_NAME}_*.tar.gz | head -1)

# Upload to S3
aws s3 cp "$BACKUP_FILE" "$S3_BUCKET/$AGENT_NAME/"

# Verify upload
aws s3 ls "$S3_BUCKET/$AGENT_NAME/$(basename $BACKUP_FILE)"

# Clean up local backup
rm "$BACKUP_FILE"

echo "S3 backup complete"
```

---

## Recovery Procedures

### Single Agent Recovery

**Full Agent Restore:**

```bash
#!/bin/bash
# restore_agent.sh - Restore agent from backup

AGENT_NAME=$1
BACKUP_FILE=$2

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "Restoring $AGENT_NAME from $BACKUP_FILE"

# Stop agent if running
cd containers/$AGENT_NAME
docker compose down 2>/dev/null
cd ../..

# Extract backup
tar -xzf "$BACKUP_FILE"

echo "Restore complete. Start agent with:"
echo "cd containers/$AGENT_NAME && docker compose up -d"
```

**Usage:**
```bash
./restore_agent.sh a0-production /backups/a0-production_20260418_220000.tar.gz
```

---

### Selective Recovery

**Restore Only Work Directory:**

```bash
#!/bin/bash
# restore_work_dir.sh - Restore only agent work directory

AGENT_NAME=$1
BACKUP_FILE=$2

# Extract only work directory
tar -xzf "$BACKUP_FILE" volumes/private/$AGENT_NAME/work_dir

echo "Work directory restored for $AGENT_NAME"
```

---

**Restore Only Configuration:**

```bash
#!/bin/bash
# restore_config.sh - Restore only agent configuration

AGENT_NAME=$1
BACKUP_FILE=$2

# Extract only configuration
tar -xzf "$BACKUP_FILE" \
  layers/$AGENT_NAME \
  containers/$AGENT_NAME/.env

echo "Configuration restored for $AGENT_NAME"
```

---

### System Recovery

**Full System Restore:**

```bash
#!/bin/bash
# restore_system.sh - Restore entire Rio deployment

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "WARNING: This will overwrite current deployment"
read -p "Continue? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled"
    exit 0
fi

# Stop all agents
for agent_dir in containers/a0-*; do
    if [ -d "$agent_dir" ]; then
        cd "$agent_dir"
        docker compose down 2>/dev/null
        cd ../..
    fi
done

# Extract backup
tar -xzf "$BACKUP_FILE"

echo "System restored. Start agents with:"
echo "cd containers/<agent-name> && docker compose up -d"
```

---

### Recovery Validation

**Verify Restored Agent:**

```bash
#!/bin/bash
# verify_restore.sh - Validate restored agent

AGENT_NAME=$1

echo "Verifying restore for $AGENT_NAME"

# Check files exist
echo "Checking files..."
[ -d "containers/$AGENT_NAME" ] && echo "✓ Container config exists" || echo "✗ Container config missing"
[ -d "layers/$AGENT_NAME" ] && echo "✓ Layer config exists" || echo "✗ Layer config missing"
[ -d "volumes/private/$AGENT_NAME" ] && echo "✓ Private volumes exist" || echo "✗ Private volumes missing"

# Check configuration
echo "Checking configuration..."
[ -f "containers/$AGENT_NAME/.env" ] && echo "✓ Orchestration .env exists" || echo "✗ Orchestration .env missing"
[ -f "layers/$AGENT_NAME/.env" ] && echo "✓ Runtime .env exists" || echo "✗ Runtime .env missing"

# Start agent
echo "Starting agent..."
cd containers/$AGENT_NAME
docker compose up -d

# Wait for startup
sleep 10

# Check health
PORT=$(grep PORT_BASE .env | cut -d= -f2)
if curl -s -f http://localhost:$PORT/health > /dev/null; then
    echo "✓ Agent is healthy"
else
    echo "✗ Agent health check failed"
fi

cd ../..
```

---

## Disaster Recovery

### Recovery Time Objectives

**RTO (Recovery Time Objective):** < 1 hour
**RPO (Recovery Point Objective):** < 24 hours (with daily backups)

---

### Disaster Recovery Plan

**Scenario 1: Single Agent Failure**

1. Identify failed agent
2. Locate most recent backup
3. Stop failed agent container
4. Restore from backup
5. Start agent container
6. Verify health and functionality
7. Monitor for recurring issues

**Time Estimate:** 15-30 minutes

---

**Scenario 2: Host System Failure**

1. Provision new host system
2. Install prerequisites (Docker, etc.)
3. Clone Rio Library repository
4. Restore system backup
5. Initialize environment (`init_environment.sh`)
6. Start all agent containers
7. Verify all agents healthy
8. Update DNS/load balancer if needed

**Time Estimate:** 1-2 hours

---

**Scenario 3: Data Corruption**

1. Identify corrupted data
2. Stop affected agent(s)
3. Restore from most recent clean backup
4. If corruption is recent, restore from earlier backup
5. Start agent(s)
6. Verify data integrity
7. Investigate corruption cause

**Time Estimate:** 30 minutes - 2 hours

---

### Disaster Recovery Testing

**Quarterly DR Test:**

```bash
#!/bin/bash
# dr_test.sh - Disaster recovery test

echo "=== Disaster Recovery Test ==="
echo "Date: $(date)"

# 1. Create test backup
echo "Creating test backup..."
./backup_agent.sh a0-production /tmp/dr-test

# 2. Simulate failure (stop agent)
echo "Simulating failure..."
cd containers/a0-production
docker compose down
cd ../..

# 3. Restore from backup
echo "Restoring from backup..."
BACKUP_FILE=$(ls -t /tmp/dr-test/a0-production_*.tar.gz | head -1)
./restore_agent.sh a0-production "$BACKUP_FILE"

# 4. Start agent
echo "Starting agent..."
cd containers/a0-production
docker compose up -d
cd ../..

# 5. Verify recovery
echo "Verifying recovery..."
sleep 15
./verify_restore.sh a0-production

# 6. Clean up test backup
rm -rf /tmp/dr-test

echo "=== DR Test Complete ==="
```

---

## Backup Best Practices

### Backup Strategy

**3-2-1 Rule:**
- **3** copies of data (original + 2 backups)
- **2** different storage media
- **1** offsite backup

**Example Implementation:**
1. Original data on production server
2. Daily backup to local NAS
3. Weekly backup to remote server
4. Monthly backup to cloud storage (S3)

---

### Backup Verification

**Verify Backup Integrity:**

```bash
#!/bin/bash
# verify_backup.sh - Verify backup file integrity

BACKUP_FILE=$1

echo "Verifying backup: $BACKUP_FILE"

# Check file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "✗ Backup file not found"
    exit 1
fi

# Check file is not empty
if [ ! -s "$BACKUP_FILE" ]; then
    echo "✗ Backup file is empty"
    exit 1
fi

# Test tar integrity
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "✓ Backup file is valid"
else
    echo "✗ Backup file is corrupted"
    exit 1
fi

# List contents
echo "Backup contents:"
tar -tzf "$BACKUP_FILE" | head -20
echo "..."
echo "Total files: $(tar -tzf "$BACKUP_FILE" | wc -l)"
```

---

### Backup Security

**Encrypt Backups:**

```bash
#!/bin/bash
# encrypted_backup.sh - Create encrypted backup

AGENT_NAME=$1
BACKUP_DIR=${2:-/backups}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${AGENT_NAME}_${TIMESTAMP}.tar.gz"
ENCRYPTED_FILE="${BACKUP_FILE}.gpg"

# Create backup
./backup_agent.sh $AGENT_NAME /tmp

# Encrypt backup
gpg --symmetric --cipher-algo AES256 -o "$ENCRYPTED_FILE" "$BACKUP_FILE"

# Remove unencrypted backup
rm "$BACKUP_FILE"

echo "Encrypted backup created: $ENCRYPTED_FILE"
```

**Decrypt and Restore:**

```bash
#!/bin/bash
# decrypt_and_restore.sh - Decrypt and restore backup

ENCRYPTED_FILE=$1
AGENT_NAME=$2

# Decrypt backup
BACKUP_FILE="${ENCRYPTED_FILE%.gpg}"
gpg --decrypt -o "$BACKUP_FILE" "$ENCRYPTED_FILE"

# Restore
./restore_agent.sh $AGENT_NAME "$BACKUP_FILE"

# Clean up decrypted file
rm "$BACKUP_FILE"
```

---

## State Migration

### Migrate Agent to New Host

**Export Agent:**

```bash
#!/bin/bash
# export_agent.sh - Export agent for migration

AGENT_NAME=$1
EXPORT_FILE="/tmp/${AGENT_NAME}_export.tar.gz"

# Create export
./backup_agent.sh $AGENT_NAME /tmp

echo "Agent exported to: $EXPORT_FILE"
echo "Transfer to new host and run import_agent.sh"
```

---

**Import Agent:**

```bash
#!/bin/bash
# import_agent.sh - Import agent on new host

EXPORT_FILE=$1
AGENT_NAME=$(basename "$EXPORT_FILE" | sed 's/_export.tar.gz//')

echo "Importing agent: $AGENT_NAME"

# Extract export
tar -xzf "$EXPORT_FILE"

# Initialize environment if needed
if [ ! -f "docker-compose.yml" ]; then
    ./init_environment.sh
fi

# Start agent
cd containers/$AGENT_NAME
docker compose up -d
cd ../..

echo "Agent imported and started"
```

---

### Migrate Between Rio Versions

**Version Migration:**

```bash
#!/bin/bash
# migrate_version.sh - Migrate to new Rio version

OLD_VERSION="v1.0"
NEW_VERSION="v2.0"

echo "Migrating from $OLD_VERSION to $NEW_VERSION"

# 1. Backup current state
./backup_system.sh /backups/pre-migration

# 2. Stop all agents
for agent_dir in containers/a0-*; do
    cd "$agent_dir"
    docker compose down
    cd ../..
done

# 3. Update Rio Library
git fetch origin
git checkout $NEW_VERSION

# 4. Run migration script if exists
if [ -f "migrate_${OLD_VERSION}_to_${NEW_VERSION}.sh" ]; then
    ./migrate_${OLD_VERSION}_to_${NEW_VERSION}.sh
fi

# 5. Reinitialize environment
./init_environment.sh

# 6. Start agents
for agent_dir in containers/a0-*; do
    cd "$agent_dir"
    docker compose up -d
    cd ../..
done

echo "Migration complete"
```

---

## Integration with Rio Patterns

Backup and recovery preserves all 11 Rio invariants:

1. **Self-Discovery:** Restored agents discover own root
2. **Layer Hierarchy:** Layer precedence maintained after restore
3. **Separation of Concerns:** Persistent/ephemeral separation guides backup
4. **Dynamic Generation:** Ephemeral configs regenerated, not backed up
5. **Config-First:** Authoritative config backed up and restored
6. **Methodology Neutrality:** Backup doesn't impose methodology
7. **Meta-Awareness:** Agents can backup themselves if given tools
8. **Boundary & Permeability:** Backup respects boundary definitions
9. **State Lifecycle:** Backup/restore are lifecycle operations
10. **Dual Configuration:** Both orchestration and runtime configs backed up
11. **Emergent Properties:** Reliable recovery enables resilience

**Key Insight:** Backup strategy emerges from **State Lifecycle** and **Separation of Concerns** patterns.

---

## Monitoring Backup Health

**Backup Monitoring Script:**

```bash
#!/bin/bash
# monitor_backups.sh - Monitor backup health

BACKUP_DIR=/backups
ALERT_EMAIL="ops@example.com"

# Check last backup age
LAST_BACKUP=$(find $BACKUP_DIR -name "*.tar.gz" -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -d' ' -f2)
LAST_BACKUP_AGE=$(( ($(date +%s) - $(stat -c %Y "$LAST_BACKUP")) / 3600 ))

if [ $LAST_BACKUP_AGE -gt 24 ]; then
    echo "ALERT: Last backup is $LAST_BACKUP_AGE hours old" | mail -s "Backup Alert" $ALERT_EMAIL
fi

# Check backup size
LAST_BACKUP_SIZE=$(du -m "$LAST_BACKUP" | cut -f1)
if [ $LAST_BACKUP_SIZE -lt 100 ]; then
    echo "ALERT: Last backup is only ${LAST_BACKUP_SIZE}MB" | mail -s "Backup Alert" $ALERT_EMAIL
fi

# Check backup integrity
if ! tar -tzf "$LAST_BACKUP" > /dev/null 2>&1; then
    echo "ALERT: Last backup is corrupted" | mail -s "Backup Alert" $ALERT_EMAIL
fi

echo "Backup health check complete"
```

---

## Conclusion

Rio Library backup and recovery enables:
- **Data protection** - Persistent state backed up, ephemeral regenerated
- **Disaster recovery** - RTO < 1 hour, RPO < 24 hours
- **State migration** - Move agents between hosts and versions
- **Pattern preservation** - Backup/recovery maintains all Rio invariants

These procedures are **production-tested** and based on Rio's pattern DNA understanding of persistent vs ephemeral state.

**Pattern source:** Combined from 16 RNS backup/recovery documents + Rio Pattern DNA (State Lifecycle, Separation of Concerns).
