---
name: parallel-agents
description: Multi-agent orchestration patterns. Use when multiple independent tasks can run with different domain expertise, when comprehensive analysis requires multiple perspectives, or when parallel implementation streams need git worktree isolation.
allowed-tools: Read, Glob, Grep, Bash
---

# Native Parallel Agents

> Orchestration through Claude Code's built-in Agent tool

## Overview

This skill enables coordinating multiple specialized agents through Claude Code's native subagent system (the `Agent` tool with `subagent_type="<name>"`). Unlike external scripts, this approach keeps all orchestration within the parent Claude session.

## When to Use Orchestration

✅ **Good for:**
- Complex tasks requiring multiple expertise domains
- Code analysis from security, performance, and quality perspectives
- Comprehensive reviews (architecture + security + testing)
- Feature implementation needing backend + frontend + database work

❌ **Not for:**
- Simple, single-domain tasks
- Quick fixes or small changes
- Tasks where one agent suffices

---

## Native Agent Invocation

### Single Agent
```
Use the security-auditor agent to review authentication
```

### Sequential Chain
```
First, use the explorer-agent to discover project structure.
Then, use the backend-specialist to review API endpoints.
Finally, use the test-engineer to identify test gaps.
```

### With Context Passing
```
Use the frontend-specialist to analyze React components.
Based on those findings, have the test-engineer generate component tests.
```

### Resume Previous Work
```
Resume agent [agentId] and continue with additional requirements.
```

---

## Orchestration Patterns

### Pattern 1: Comprehensive Analysis
```
Agents: explorer-agent → [domain-agents] → synthesis

1. explorer-agent: Map codebase structure
2. security-auditor: Security posture
3. backend-specialist: API quality
4. frontend-specialist: UI/UX patterns
5. test-engineer: Test coverage
6. Synthesize all findings
```

### Pattern 2: Feature Review
```
Agents: affected-domain-agents → test-engineer

1. Identify affected domains (backend? frontend? both?)
2. Invoke relevant domain agents
3. test-engineer verifies changes
4. Synthesize recommendations
```

### Pattern 3: Security Audit
```
Agents: security-auditor → penetration-tester → synthesis

1. security-auditor: Configuration and code review
2. penetration-tester: Active vulnerability testing
3. Synthesize with prioritized remediation
```

---

## Available Agents

| Agent | Expertise | Trigger Phrases |
|-------|-----------|-----------------|
| `orchestrator` | Coordination | "comprehensive", "multi-perspective" |
| `security-auditor` | Security | "security", "auth", "vulnerabilities" |
| `penetration-tester` | Security Testing | "pentest", "red team", "exploit" |
| `backend-specialist` | Backend | "API", "server", "Node.js", "Express" |
| `frontend-specialist` | Frontend | "React", "UI", "components", "Next.js" |
| `test-engineer` | Testing | "tests", "coverage", "TDD" |
| `devops-engineer` | DevOps | "deploy", "CI/CD", "infrastructure" |
| `database-architect` | Database | "schema", "Prisma", "migrations" |
| `mobile-developer` | Mobile | "React Native", "Flutter", "mobile" |
| `api-designer` | API Design | "REST", "GraphQL", "OpenAPI" |
| `debugger` | Debugging | "bug", "error", "not working" |
| `explorer-agent` | Discovery | "explore", "map", "structure" |
| `documentation-writer` | Documentation | "write docs", "create README", "generate API docs" |
| `performance-optimizer` | Performance | "slow", "optimize", "profiling" |
| `project-planner` | Planning | "plan", "roadmap", "milestones" |
| `seo-specialist` | SEO | "SEO", "meta tags", "search ranking" |
| `game-developer` | Game Development | "game", "Unity", "Godot", "Phaser" |

---

## Claude Code Built-in Agents

These work alongside the project's custom agents:

| Agent | Purpose |
|-------|---------|
| **Explore** | Fast read-only codebase search |
| **Plan** | Architecture/research during planning |
| **general-purpose** | Complex multi-step modifications |

Use **Explore** for quick searches, **custom agents** (in `.claude/agents/`) for domain expertise.

---

## Git Worktrees — Isolating Parallel Mutation

Parallel **read-only** agents (analysis, review, discovery) never conflict — run them freely. Parallel agents that **write files** must NEVER share the same working tree: edits interleave and corrupt each other's work.

### Rule of thumb

| Streams | Approach |
|---------|----------|
| All read-only | Parallel, same tree — no isolation needed |
| Write, but disjoint features | One **git worktree per stream**, merge at the end |
| Write, overlapping files | **Don't parallelize** — serialize (a worktree doesn't fix a merge conflict, it only postpones it) |

### Commands

```bash
# One worktree per stream, each on its own branch:
git worktree add ../<repo>-feature-a -b feature/a
git worktree add ../<repo>-feature-b -b feature/b

# Each agent works ONLY inside its own worktree directory.

# After merging the branches back (normal flow: branch → PR → merge):
git worktree remove ../<repo>-feature-a
git worktree prune
```

### Rules

1. One worktree per parallel stream — two agents never mutate the same tree.
2. Each worktree gets its own branch; merge back through the project's normal flow.
3. **Always remove the worktree after merge** (a forgotten worktree pins its branch and confuses future runs).
4. The SPEC/PLAN stays in the main tree — worktrees are for code, not for the knowledge base.

---

## Synthesis Protocol

After all agents complete, synthesize:

```markdown
## Orchestration Synthesis

### Task Summary
[What was accomplished]

### Agent Contributions
| Agent | Finding |
|-------|---------|
| security-auditor | Found X |
| backend-specialist | Identified Y |

### Consolidated Recommendations
1. **Critical**: [Issue from Agent A]
2. **Important**: [Issue from Agent B]
3. **Nice-to-have**: [Enhancement from Agent C]

### Action Items
- [ ] Fix critical security issue
- [ ] Refactor API endpoint
- [ ] Add missing tests
```

---

## Best Practices

1. **Available agents** - 17 specialized agents can be orchestrated
2. **Logical order** - Discovery → Analysis → Implementation → Testing
3. **Share context** - Pass relevant findings to subsequent agents
4. **Single synthesis** - One unified report, not separate outputs
5. **Verify changes** - Always include test-engineer for code modifications

---

## Key Benefits

- ✅ **Single session** - All agents share context
- ✅ **AI-controlled** - Claude orchestrates autonomously
- ✅ **Native integration** - Works with built-in Explore, Plan agents
- ✅ **Resume support** - Can continue previous agent work
- ✅ **Context passing** - Findings flow between agents
