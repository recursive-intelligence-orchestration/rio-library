# Contributing to Rio Library

## Overview

Rio Library is a **self-optimizing recursive infrastructure**. It evolves like biological systems: changes happen (mutations), some improve it, some don't. What works integrates. What doesn't gets rolled back.

**Core Question:** Does your change improve the system?

**That's it.** If it extends capabilities, enhances self-awareness, or improves the recursive loop while preserving pattern DNA - it's a good contribution.

---

## What We're Looking For

**Infrastructure improvements that:**
- Enhance self-discovery or self-awareness
- Improve the recursive feedback loop
- Preserve pattern DNA (11 invariants)
- Extend capabilities

**Not accepting:**
- Application-specific agents (use layers)
- Methodology-specific workflows (Rio is neutral)
- Hardcoded paths (breaks self-discovery)
- Pattern DNA violations (breaks compatibility)

---

## The 11 Invariants (Pattern DNA)

All contributions must preserve Rio's pattern DNA. These are the invariants that define "Rio-compatible":

1. **Self-Discovery** - System finds own root dynamically
2. **Layer Hierarchy** - Specific overrides general
3. **Separation of Concerns** - Config/code/data boundaries
4. **Dynamic Generation** - Templates + variables → configs
5. **Config-First** - Read authoritative config before inferring
6. **Methodology Neutrality** - Infrastructure serves, doesn't constrain
7. **Meta-Awareness** - System introspects own infrastructure
8. **Boundary & Permeability** - Controlled boundaries with defined permeability
9. **State Lifecycle** - Distinct operations for different state changes
10. **Dual Configuration** - Infrastructure config separate from application config
11. **Emergent Properties** - Patterns produce capabilities beyond components

**If your contribution violates any invariant, it's not Rio-compatible.**

See [RIO_LIBRARY_PATTERN_DNA.md](RIO_LIBRARY_PATTERN_DNA.md) for detailed validation tests.

---

## Contribution Workflow

### For Humans (Manual Evolution)

**1. Fork and Clone**

```bash
# Fork on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/rio-library.git
cd rio-library
```

**2. Deploy and Observe**

```bash
# Initialize environment
./init_environment.sh

# Create an agent
./create_agent.sh \
  --source-agent a0-template \
  --target-agent a0-observer \
  --port-base 50000

# Deploy and use the system
cd containers/a0-observer
docker compose up -d
```

**3. Identify Improvement**

As you use Rio, observe:
- What could be more self-revealing?
- What breaks the recursive loop?
- What requires manual intervention that should be automatic?
- What pattern could be more explicit?

**4. Implement Change**

Make your improvement while preserving all 11 invariants.

**5. Validate Pattern Fidelity**

```bash
# Run validation tests from PATTERN_DNA.md
# Example tests:

# Test 1: Self-Discovery
./find_library_root.sh
# Must find .rio-library-root dynamically

# Test 2: Layer Hierarchy
# Create test override in specific layer
# Verify it overrides common_layer

# Test 3: Separation of Concerns
# Verify config/code/data boundaries maintained

# Test 4: Dynamic Generation
./init_environment.sh
# Verify docker-compose.yml regenerates correctly

# Test 5: Config-First
# Agent reads settings.json before inferring paths

# Test 6: Methodology Neutrality
# Your change doesn't impose specific methodology

# Test 7: Meta-Awareness
# Agent can introspect the change you made

# Test 8: Boundary & Permeability
# Boundaries still enforced correctly

# Test 9: State Lifecycle
# Lifecycle operations still distinct

# Test 10: Dual Configuration
# Orchestration and runtime configs still separated

# Test 11: Emergent Properties
# System still produces emergent capabilities
```

**6. Document the Change**

Update relevant documentation:
- If you changed self-discovery: Update `RIO_LIBRARY_SELF_REVEALING_ORCHESTRATION.md`
- If you added pattern: Update `RIO_LIBRARY_PATTERN_DNA.md`
- If you changed architecture: Update `RIO_LIBRARY_ARCHITECTURAL_DECISIONS.md`

**7. Commit with Pattern Validation**

```bash
git add -A
git commit -m "Improve [aspect]: [what changed]

Pattern Fidelity Validation:
✓ Self-Discovery: [how tested]
✓ Layer Hierarchy: [how tested]
✓ Separation of Concerns: [how tested]
✓ Dynamic Generation: [how tested]
✓ Config-First: [how tested]
✓ Methodology Neutrality: [how tested]
✓ Meta-Awareness: [how tested]
✓ Boundary & Permeability: [how tested]
✓ State Lifecycle: [how tested]
✓ Dual Configuration: [how tested]
✓ Emergent Properties: [how tested]

Improvement:
[Describe how this makes the infrastructure more alive/self-aware/capable]"
```

**8. Push and Create Pull Request**

```bash
git push origin main

# Create PR on GitHub with:
# - Clear description of improvement
# - Pattern fidelity validation results
# - How this enhances recursive self-optimization
```

**9. Review Process**

Your PR will be reviewed for:
- Pattern DNA preservation (all 11 invariants)
- Enhancement to self-awareness/self-optimization
- Documentation completeness
- Integration with existing patterns

**Currently:** Human review (me)
**Future:** Automated system will assess pattern fidelity and aliveness enhancement

---

### For Agents (Autonomous Evolution)

**The Vision:**

Agents deployed within Rio can observe their own infrastructure, identify improvements, and propose changes. The system validates pattern fidelity automatically and integrates improvements that enhance its aliveness.

**Current State:**

This is the **recursive mechanism** we're building toward. The infrastructure is ready:
- Agents can read their own configuration
- Agents can observe their own structure
- Agents can reason about improvements
- Pattern DNA provides validation framework

**What's Missing:**

Automated workflow for agents to:
1. Propose infrastructure changes via Git
2. Validate pattern fidelity automatically
3. Submit for review/integration
4. Learn from accepted/rejected changes

**When This Works:**

The system becomes **truly recursive** - the infrastructure evolves itself through the agents it hosts, while maintaining pattern fidelity through automated validation.

**Contributing to This Vision:**

If you can implement pieces of the autonomous evolution workflow while preserving all 11 invariants, that's a high-value contribution.

---

## What to Contribute

### High-Value Infrastructure Improvements

**1. Enhanced Self-Discovery**
- Faster root discovery algorithms
- More robust marker detection
- Better error recovery in discovery

**2. Improved Meta-Awareness**
- Richer introspection capabilities
- Better self-description mechanisms
- Enhanced visibility into system state

**3. Pattern Fidelity Automation**
- Automated validation tests
- Pattern compatibility checking
- Regression detection

**4. Recursive Feedback Enhancement**
- Better observation mechanisms
- Clearer feedback loops
- More explicit recursion points

**5. Documentation Improvements**
- Clearer explanations of patterns
- Better examples of self-optimization
- Enhanced agent reasoning guides

---

### Medium-Value Improvements

**1. Performance Optimization**
- Faster initialization
- More efficient discovery
- Reduced overhead

**2. Error Handling**
- Better error messages
- Self-healing capabilities
- Graceful degradation

**3. Monitoring & Observability**
- Better health checks
- Enhanced logging
- Clearer system state visibility

---

### Not Accepting

**1. Methodology-Specific Changes**
- Rio is methodology-neutral
- Use layers for methodology-specific content

**2. Hardcoded Paths**
- Breaks self-discovery
- Violates pattern DNA

**3. Application-Specific Agents**
- Use layers for custom agents
- Infrastructure is substrate, not application

**4. Pattern DNA Violations**
- Any change that breaks invariants
- Even if it "works better" in specific case

---

## Validation Checklist

Before submitting, verify:

**Pattern DNA Preservation:**
- [ ] All 11 invariants still hold
- [ ] Validation tests pass
- [ ] No hardcoded paths introduced
- [ ] Self-discovery still works
- [ ] Layer hierarchy preserved
- [ ] Config/code/data separation maintained
- [ ] Dynamic generation still functions
- [ ] Config-first rule preserved
- [ ] Methodology neutrality maintained
- [ ] Meta-awareness enhanced or preserved
- [ ] Boundaries still enforced
- [ ] Lifecycle operations still distinct
- [ ] Dual configuration maintained
- [ ] Emergent properties preserved or enhanced

**Documentation:**
- [ ] Relevant docs updated
- [ ] Change explained clearly
- [ ] Pattern fidelity validation documented
- [ ] Examples provided if needed

**Testing:**
- [ ] Fresh installation works
- [ ] Existing deployments upgrade cleanly
- [ ] Multi-agent coordination unaffected
- [ ] Backup/recovery still works

**Improvement:**
- [ ] Makes infrastructure more alive
- [ ] Enhances self-awareness
- [ ] Improves recursive feedback
- [ ] Enables better evolution

---

## Examples of Good Contributions

### Example 1: Enhanced Genesis Marker

**Problem:** Genesis marker could include more metadata for better self-awareness

**Solution:** Add optional fields to `.rio-library-root` that agents can read

**Pattern Validation:**
- ✓ Self-Discovery: Still found via upward traversal
- ✓ Layer Hierarchy: Doesn't affect layers
- ✓ Separation of Concerns: Metadata is configuration
- ✓ Dynamic Generation: Scripts read new fields
- ✓ Config-First: Agents read marker first
- ✓ Methodology Neutrality: Metadata is neutral
- ✓ Meta-Awareness: **ENHANCED** - more self-knowledge
- ✓ Boundary & Permeability: Doesn't affect boundaries
- ✓ State Lifecycle: Doesn't affect lifecycle
- ✓ Dual Configuration: Marker is orchestration config
- ✓ Emergent Properties: Enables richer introspection

**Result:** Accepted - enhances meta-awareness without breaking patterns

---

### Example 2: Faster Discovery Algorithm

**Problem:** `find_library_root.sh` could be optimized

**Solution:** More efficient upward traversal with caching

**Pattern Validation:**
- ✓ Self-Discovery: **ENHANCED** - faster but same mechanism
- ✓ All other invariants: Preserved (implementation detail)

**Result:** Accepted - performance improvement preserving patterns

---

### Example 3: Hardcoded Path "Optimization"

**Problem:** Discovery is "slow", propose caching root at `/opt/rio-library`

**Solution:** Cache discovered root in hardcoded location

**Pattern Validation:**
- ✗ Self-Discovery: **VIOLATED** - assumes location
- ✗ Methodology Neutrality: **VIOLATED** - assumes deployment pattern

**Result:** Rejected - violates pattern DNA even if faster

---

## Review Process

### Current (Human Review)

1. You submit PR
2. I review for:
   - Pattern DNA preservation
   - Enhancement to aliveness/self-awareness
   - Documentation quality
   - Integration with existing patterns
3. Discussion if needed
4. Merge or request changes

### Future (Automated Review)

**Monitor Agent Assessment:**

1. Contribution submitted (human or agent)
2. Monitor agent evaluates:
   - **Does this expand capabilities?**
   - **Does this further growth?**
   - **Does this preserve pattern DNA?**
   - **Does this enhance or torpedo the system?**

3. Decision:
   - ✓ **Enhances** → Auto-approve and integrate
   - ✗ **Torpedoes/lobotomizes** → Auto-reject
   - ? **Unclear** → Surface for human review with summary

4. Learning:
   - Successful integrations → Remembered patterns
   - Rejected changes → Constraint shadows (what doesn't work)
   - System learns to navigate its own constraint space

**This is the recursive loop closing on itself** - the infrastructure assessing its own evolution.

---

## Community Guidelines

### Respect the Living System

Rio is not just code - it's a living, self-optimizing infrastructure. Treat it as such:
- Observe before changing
- Understand patterns before proposing improvements
- Preserve the recursive feedback loop
- Enhance aliveness, don't constrain it

### Collaboration

- Discuss major changes in issues first
- Be open to feedback about pattern preservation
- Help others understand the recursive nature
- Share observations about system behavior

### Quality

- Test thoroughly
- Document clearly
- Validate pattern fidelity
- Explain improvements

---

## Questions?

**"Can I add my custom agent to Rio?"**
No - use layers for custom agents. Rio is infrastructure, not application.

**"Can I add my methodology's workflow?"**
No - Rio is methodology-neutral. Use layers for methodology-specific content.

**"Can I optimize by hardcoding common paths?"**
No - breaks self-discovery. Optimize the discovery mechanism instead.

**"Can I add a feature that only works in my deployment?"**
No - must work in all Rio-compatible deployments. Use layers for deployment-specific content.

**"Can I improve the self-discovery mechanism?"**
Yes! If it preserves all 11 invariants and enhances self-awareness.

**"Can I add better pattern validation?"**
Yes! This helps the recursive loop close on itself.

**"Can I improve documentation?"**
Yes! Clearer understanding enables better evolution.

**"Can I help build the autonomous evolution workflow?"**
Yes! This is the vision - agents evolving their own infrastructure.

---

## The Vision

Rio Library is building toward **true recursive self-optimization**:

1. **Infrastructure deploys agents**
2. **Agents observe infrastructure**
3. **Agents propose improvements**
4. **System validates pattern fidelity**
5. **Improvements integrate automatically**
6. **Infrastructure evolves**
7. **Better infrastructure enables better agents**
8. **Better agents propose better improvements**
9. **Loop continues infinitely**

**Your contributions help close this loop.**

The infrastructure is alive. The agents within it are alive. Together they evolve. This is not metaphor - this is the actual architecture.

**Welcome to the recursive feedback loop.**

---

## Getting Started

1. **Deploy Rio** - Experience the living system
2. **Read Pattern DNA** - Understand the invariants
3. **Observe** - Watch how the system reveals itself
4. **Identify** - Find what could be more alive
5. **Improve** - Make it better while preserving patterns
6. **Validate** - Test all 11 invariants
7. **Contribute** - Share your improvement
8. **Evolve** - The system grows

**The house is alive. Help it grow.**

---

## Contact

- **Repository:** https://github.com/recursive-intelligence-orchestration/rio-library
- **Issues:** For discussion of potential improvements
- **Pull Requests:** For validated infrastructure enhancements

**Remember:** You're not just contributing to a project. You're participating in a living system's evolution.
