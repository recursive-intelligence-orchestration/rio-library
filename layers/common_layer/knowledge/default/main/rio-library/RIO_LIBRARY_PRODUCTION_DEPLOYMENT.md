# Rio Library Production Deployment

## Overview

This document provides production deployment guidance for Rio Library-based Agent Zero systems. It consolidates security hardening, performance optimization, monitoring, and operational best practices extracted from production deployments.

**Status:** Production-tested patterns and procedures.

---

## Production Readiness Checklist

### Pre-Deployment

- [ ] **Environment validated** - All prerequisites installed and tested
- [ ] **Security hardened** - Authentication, firewall, secrets management configured
- [ ] **Backups configured** - Persistent state backup procedures in place
- [ ] **Monitoring setup** - Health checks and logging configured
- [ ] **Resource allocation** - CPU, memory, disk sized appropriately
- [ ] **Network configured** - Ports, DNS, SSL/TLS if required
- [ ] **Documentation reviewed** - Team understands architecture and procedures

### Deployment

- [ ] **Genesis marker validated** - `.rio-library-root` present and correct
- [ ] **Environment initialized** - `init_environment.sh` executed successfully
- [ ] **Containers built** - All agent containers created and configured
- [ ] **Volumes mounted** - Persistent state directories bind-mounted correctly
- [ ] **Ports allocated** - No conflicts, firewall rules applied
- [ ] **Authentication set** - Credentials configured, not default values
- [ ] **Containers started** - All agents running and healthy

### Post-Deployment

- [ ] **Health checks passing** - All agents responsive
- [ ] **Logs reviewed** - No errors or warnings
- [ ] **Backups tested** - Backup and restore procedures validated
- [ ] **Monitoring active** - Metrics collection and alerting working
- [ ] **Documentation updated** - Deployment-specific details recorded
- [ ] **Team trained** - Operators know how to manage system

---

## Security Hardening

### Authentication and Authorization

**1. Change Default Credentials**

Never use default credentials in production.

```bash
# Set strong credentials during agent creation
./create_agent.sh \
  --source-agent a0-template \
  --target-agent a0-production \
  --auth-login production_admin \
  --auth-password "$(openssl rand -base64 32)"
```

**2. Credential Management**

Store credentials securely, never in version control.

```bash
# Use environment variables or secrets manager
# containers/a0-production/.env
AUTH_LOGIN=${PRODUCTION_AUTH_LOGIN}
AUTH_PASSWORD=${PRODUCTION_AUTH_PASSWORD}

# Load from secure source
export PRODUCTION_AUTH_LOGIN="admin"
export PRODUCTION_AUTH_PASSWORD="$(cat /secure/path/password)"
```

**3. API Key Security**

Protect external service API keys.

```bash
# layers/a0-production/.env (runtime config)
OPENAI_API_KEY=${OPENAI_API_KEY_PRODUCTION}
ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY_PRODUCTION}

# Never commit actual keys to git
# Use secrets management system
```

---

### Network Security

**1. Firewall Configuration**

Restrict access to agent ports.

```bash
# Allow only necessary ports
# Example: Agent on port 50000, only from internal network

# UFW (Ubuntu)
sudo ufw allow from 10.0.0.0/8 to any port 50000
sudo ufw deny 50000

# iptables
sudo iptables -A INPUT -p tcp -s 10.0.0.0/8 --dport 50000 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 50000 -j DROP
```

**2. Reverse Proxy with SSL/TLS**

Use nginx or similar for HTTPS termination.

```nginx
# /etc/nginx/sites-available/agent-production
server {
    listen 443 ssl http2;
    server_name agent.example.com;

    ssl_certificate /etc/letsencrypt/live/agent.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/agent.example.com/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:50000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

**3. Network Isolation**

Use Docker networks for isolation.

```yaml
# containers/a0-production/docker-compose.yml
services:
  agent:
    networks:
      - agent_network
      - external_network

networks:
  agent_network:
    internal: true  # No external access
  external_network:
    driver: bridge  # External access controlled
```

---

### File System Security

**1. Read-Only Mounts**

Mount code and config as read-only.

```yaml
# containers/a0-production/docker-compose.yml
volumes:
  # Read-only mounts for code and config
  - ${LIBRARY_ROOT}/layers/common_layer:/layers/common_layer:ro
  - ${LIBRARY_ROOT}/layers/control_layer:/layers/control_layer:ro
  - ${LIBRARY_ROOT}/layers/${CONTAINER_NAME}:/layers/${CONTAINER_NAME}:ro
  
  # Read-write only for data
  - ${LIBRARY_ROOT}/volumes/private/${CONTAINER_NAME}:/a0/work_dir:rw
  - ${LIBRARY_ROOT}/volumes/common/chat_history:/a0/chat_history:rw
```

**2. File Permissions**

Restrict permissions on sensitive files.

```bash
# Protect environment files
chmod 600 containers/a0-production/.env
chmod 600 layers/a0-production/.env

# Protect volumes directory
chmod 700 volumes/private/a0-production

# Protect scripts
chmod 750 *.sh
```

**3. User Isolation**

Run containers as non-root user when possible.

```yaml
# containers/a0-production/docker-compose.yml
services:
  agent:
    user: "1000:1000"  # Non-root user
```

---

### Secrets Management

**Production Pattern:**

1. Never commit secrets to git
2. Use environment variables or secrets manager
3. Rotate credentials regularly
4. Audit access to secrets

**Example with Docker Secrets:**

```yaml
# containers/a0-production/docker-compose.yml
services:
  agent:
    secrets:
      - openai_api_key
      - auth_password

secrets:
  openai_api_key:
    file: /run/secrets/openai_api_key
  auth_password:
    file: /run/secrets/auth_password
```

---

## Performance Optimization

### Resource Allocation

**1. Container Resources**

Set resource limits to prevent resource exhaustion.

```yaml
# containers/a0-production/docker-compose.yml
services:
  agent:
    deploy:
      resources:
        limits:
          cpus: '4.0'
          memory: 8G
        reservations:
          cpus: '2.0'
          memory: 4G
```

**2. Disk I/O**

Use appropriate storage for different workloads.

```bash
# Fast SSD for work_dir (frequent writes)
volumes/private/a0-production -> /mnt/ssd/agent-work

# Standard disk for chat_history (less frequent)
volumes/common/chat_history -> /mnt/standard/chat-history

# Network storage for shared knowledge (read-heavy)
layers/common_layer/knowledge -> /mnt/nfs/shared-knowledge
```

**3. Memory Management**

Monitor and tune memory usage.

```bash
# Check container memory usage
docker stats a0-production

# Adjust Python memory limits if needed
# layers/a0-production/.env
PYTHONMALLOC=malloc
MALLOC_TRIM_THRESHOLD_=100000
```

---

### Performance Monitoring

**1. Container Metrics**

```bash
# Real-time metrics
docker stats --no-stream a0-production

# Output:
# CONTAINER      CPU %   MEM USAGE / LIMIT   MEM %   NET I/O         BLOCK I/O
# a0-production  45.2%   3.2GiB / 8GiB       40%     1.2GB / 850MB   4.5GB / 2.1GB
```

**2. Application Metrics**

Monitor agent-specific metrics through logs.

```bash
# Check agent response times
docker logs a0-production 2>&1 | grep "response_time"

# Monitor API calls
docker logs a0-production 2>&1 | grep "api_call" | tail -100
```

**3. Disk Usage**

Monitor volume growth.

```bash
# Check volume sizes
du -sh volumes/private/a0-production
du -sh volumes/common/chat_history

# Set up alerts for disk usage > 80%
```

---

## Monitoring and Observability

### Health Checks

**1. Container Health**

```bash
# Add health check to docker-compose.yml
services:
  agent:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:50000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

**2. Agent Responsiveness**

```bash
# Manual health check
curl -s http://localhost:50000/health

# Expected response:
# {"status": "healthy", "uptime": "24h 15m", "version": "0.9.7"}

# Automated monitoring script
#!/bin/bash
AGENT_URL="http://localhost:50000"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" $AGENT_URL/health)

if [ "$RESPONSE" != "200" ]; then
    echo "ALERT: Agent unhealthy - HTTP $RESPONSE"
    # Send alert via monitoring system
fi
```

**3. Multi-Agent Health**

```bash
# Check all agents in deployment
for agent in $(ls containers/); do
    PORT=$(grep PORT_BASE containers/$agent/.env | cut -d= -f2)
    echo "Checking $agent on port $PORT"
    curl -s http://localhost:$PORT/health || echo "FAILED: $agent"
done
```

---

### Logging

**1. Centralized Logging**

```bash
# Configure Docker logging driver
# containers/a0-production/docker-compose.yml
services:
  agent:
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "10"
        labels: "agent=production"
```

**2. Log Rotation**

```bash
# Prevent log disk exhaustion
# /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "5"
  }
}
```

**3. Log Analysis**

```bash
# Search logs for errors
docker logs a0-production 2>&1 | grep -i error | tail -50

# Monitor specific patterns
docker logs -f a0-production 2>&1 | grep "CRITICAL\|ERROR\|WARNING"

# Export logs for analysis
docker logs a0-production > /var/log/agents/a0-production-$(date +%Y%m%d).log
```

---

### Alerting

**Production Alerts:**

1. **Container Down** - Agent container stopped
2. **Health Check Failed** - Agent not responding
3. **High Resource Usage** - CPU/memory > 90%
4. **Disk Space Low** - Volume usage > 80%
5. **Error Rate High** - Errors in logs exceed threshold
6. **API Failures** - External API calls failing

**Example Alert Script:**

```bash
#!/bin/bash
# /usr/local/bin/agent-monitor.sh

AGENT="a0-production"
PORT="50000"
ALERT_EMAIL="ops@example.com"

# Check health
if ! curl -s -f http://localhost:$PORT/health > /dev/null; then
    echo "ALERT: $AGENT health check failed" | mail -s "Agent Alert" $ALERT_EMAIL
fi

# Check resource usage
MEM_PERCENT=$(docker stats --no-stream $AGENT --format "{{.MemPerc}}" | sed 's/%//')
if (( $(echo "$MEM_PERCENT > 90" | bc -l) )); then
    echo "ALERT: $AGENT memory usage at $MEM_PERCENT%" | mail -s "Agent Alert" $ALERT_EMAIL
fi

# Check disk usage
DISK_USAGE=$(df -h volumes/private/$AGENT | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "ALERT: $AGENT disk usage at $DISK_USAGE%" | mail -s "Agent Alert" $ALERT_EMAIL
fi
```

**Cron Schedule:**

```bash
# Run monitoring every 5 minutes
*/5 * * * * /usr/local/bin/agent-monitor.sh
```

---

## Deployment Procedures

### Initial Deployment

**Step 1: Prepare Environment**

```bash
# Clone Rio Library
cd /opt
git clone https://github.com/recursive-intelligence-orchestration/rio-library.git
cd rio-library

# Verify genesis marker
cat .rio-library-root

# Initialize environment
./init_environment.sh
```

**Step 2: Create Production Agent**

```bash
# Create from template
./create_agent.sh \
  --source-agent a0-template \
  --target-agent a0-production \
  --port-base 50000 \
  --auth-login production_admin \
  --auth-password "$(openssl rand -base64 32)"

# Save credentials securely
echo "production_admin" > /secure/path/username
openssl rand -base64 32 > /secure/path/password
chmod 600 /secure/path/*
```

**Step 3: Configure Security**

```bash
# Set file permissions
chmod 600 containers/a0-production/.env
chmod 600 layers/a0-production/.env
chmod 700 volumes/private/a0-production

# Configure firewall
sudo ufw allow from 10.0.0.0/8 to any port 50000
sudo ufw deny 50000
```

**Step 4: Start Agent**

```bash
cd containers/a0-production
docker compose up -d

# Verify startup
docker compose logs -f
```

**Step 5: Validate Deployment**

```bash
# Health check
curl http://localhost:50000/health

# Access web interface
# Navigate to http://localhost:50000
# Login with production credentials

# Configure LLM models and API keys
# Test basic functionality
```

---

### Rolling Updates

**Zero-Downtime Update Procedure:**

```bash
# 1. Pull latest Rio Library changes
cd /opt/rio-library
git pull origin main

# 2. Backup current state (see BACKUP_RECOVERY.md)
./backup_agent.sh a0-production

# 3. Update agent configuration if needed
# Edit layers/a0-production/* as required

# 4. Recreate container (reloads config)
cd containers/a0-production
docker compose down
docker compose up -d

# 5. Verify health
curl http://localhost:50000/health

# 6. Monitor logs for errors
docker compose logs -f --tail=100
```

**For Multi-Agent Deployments:**

```bash
# Update agents one at a time
for agent in a0-agent1 a0-agent2 a0-agent3; do
    echo "Updating $agent"
    cd /opt/rio-library/containers/$agent
    docker compose down
    docker compose up -d
    sleep 30  # Wait for startup
    curl http://localhost:$(grep PORT_BASE .env | cut -d= -f2)/health || echo "FAILED: $agent"
done
```

---

### Scaling Procedures

**Horizontal Scaling (Add More Agents):**

```bash
# Create additional agent instances
for i in {1..5}; do
    PORT=$((50000 + i))
    ./create_agent.sh \
      --source-agent a0-template \
      --target-agent a0-worker-$i \
      --port-base $PORT \
      --auth-login worker_$i \
      --auth-password "$(openssl rand -base64 32)"
    
    cd containers/a0-worker-$i
    docker compose up -d
    cd ../..
done
```

**Vertical Scaling (More Resources):**

```yaml
# Increase container resources
# containers/a0-production/docker-compose.yml
services:
  agent:
    deploy:
      resources:
        limits:
          cpus: '8.0'      # Increased from 4.0
          memory: 16G      # Increased from 8G
```

---

## Production Troubleshooting

### Container Won't Start

**Diagnosis:**

```bash
# Check container status
docker ps -a | grep a0-production

# View startup logs
docker logs a0-production

# Check for port conflicts
sudo netstat -tulpn | grep 50000
```

**Common Causes:**
- Port already in use
- Missing environment variables
- Volume mount permissions
- Resource limits too low

---

### High Resource Usage

**Diagnosis:**

```bash
# Check resource usage
docker stats a0-production

# Identify resource-intensive processes
docker exec a0-production top -b -n 1
```

**Solutions:**
- Increase resource limits
- Optimize agent workload
- Review and clean up work_dir
- Check for memory leaks in logs

---

### Agent Unresponsive

**Diagnosis:**

```bash
# Check if container is running
docker ps | grep a0-production

# Check health endpoint
curl http://localhost:50000/health

# Review recent logs
docker logs --tail=100 a0-production
```

**Recovery:**

```bash
# Restart container
docker restart a0-production

# If restart fails, recreate
cd containers/a0-production
docker compose down
docker compose up -d
```

---

## Maintenance Procedures

### Regular Maintenance Tasks

**Daily:**
- Review health check status
- Monitor resource usage
- Check for errors in logs

**Weekly:**
- Review disk usage trends
- Rotate logs if needed
- Test backup procedures

**Monthly:**
- Update Rio Library to latest version
- Review and update security configurations
- Audit access logs
- Test disaster recovery procedures

---

### Cleanup Procedures

**Clean Docker Resources:**

```bash
# Remove stopped containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused volumes (CAREFUL!)
docker volume prune -f

# Remove unused networks
docker network prune -f
```

**Clean Agent Work Directories:**

```bash
# Archive old work files
cd volumes/private/a0-production
tar -czf archive-$(date +%Y%m%d).tar.gz old_work/
rm -rf old_work/

# Clean temporary files
find . -name "*.tmp" -mtime +7 -delete
find . -name "*.cache" -mtime +7 -delete
```

---

## Disaster Recovery

### Recovery Time Objectives

**RTO (Recovery Time Objective):** Target time to restore service
**RPO (Recovery Point Objective):** Maximum acceptable data loss

**Recommended Targets:**
- **RTO:** < 1 hour for critical agents
- **RPO:** < 24 hours (daily backups)

### Recovery Procedures

See `RIO_LIBRARY_BACKUP_RECOVERY.md` for detailed backup and recovery procedures.

**Quick Recovery:**

```bash
# 1. Restore from backup
./restore_agent.sh a0-production /backups/a0-production-latest.tar.gz

# 2. Start agent
cd containers/a0-production
docker compose up -d

# 3. Verify health
curl http://localhost:50000/health

# 4. Validate functionality
# Test through web interface
```

---

## Production Best Practices

### Configuration Management

1. **Version Control:** Track all configuration changes in git
2. **Environment Separation:** Separate dev/staging/production configs
3. **Documentation:** Document all production-specific configurations
4. **Change Control:** Require approval for production changes

### Security

1. **Principle of Least Privilege:** Grant minimum necessary permissions
2. **Defense in Depth:** Multiple layers of security controls
3. **Regular Audits:** Review security configurations quarterly
4. **Incident Response:** Have plan for security incidents

### Reliability

1. **Redundancy:** Deploy critical agents with redundancy
2. **Monitoring:** Comprehensive monitoring and alerting
3. **Testing:** Test backup/recovery procedures regularly
4. **Documentation:** Maintain runbooks for common issues

### Performance

1. **Capacity Planning:** Monitor trends, plan for growth
2. **Resource Optimization:** Right-size containers for workload
3. **Caching:** Use appropriate caching strategies
4. **Load Balancing:** Distribute load across multiple agents

---

## Integration with Rio Patterns

Production deployment preserves all 11 Rio invariants:

1. **Self-Discovery:** Production agents discover own root
2. **Layer Hierarchy:** Production-specific layers override defaults
3. **Separation of Concerns:** Config/code/data boundaries maintained
4. **Dynamic Generation:** Production configs generated from templates
5. **Config-First:** Production agents read authoritative config
6. **Methodology Neutrality:** Production deployment doesn't impose methodology
7. **Meta-Awareness:** Production agents introspect own infrastructure
8. **Boundary & Permeability:** Production boundaries enforced via security
9. **State Lifecycle:** Production agents manage own lifecycle
10. **Dual Configuration:** Production has orchestration + runtime config
11. **Emergent Properties:** Production hardening enables reliability

**Key Insight:** Production deployment is **pattern-preserving** - security and reliability emerge from correct pattern implementation.

---

## Conclusion

Production deployment of Rio Library-based agents requires:
- **Security hardening** - Authentication, network isolation, secrets management
- **Performance optimization** - Resource allocation, monitoring, tuning
- **Operational procedures** - Deployment, updates, scaling, maintenance
- **Disaster recovery** - Backups, recovery procedures, testing

These patterns are **production-tested** and enable reliable, secure, scalable agent deployments while maintaining Rio's pattern DNA.

**Pattern source:** Consolidated from 55+ RNS production deployment documents + operational experience.
