# Agent Coordination

> How App Builder orchestrates specialist agents.

## Agent Pipeline

```
┌─────────────────────────────────────────────────────────────┐
│                   APP BUILDER (Orchestrator)                 │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     PROJECT PLANNER                          │
│  • Task breakdown                                            │
│  • Dependency graph                                          │
│  • File structure planning                                   │
│  • Ensure SPEC + create docs/02_Specs/PLAN-<slug>.md (MANDATORY) │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│              CHECKPOINT: PLAN VERIFICATION                   │
│  🔴 VERIFY: SPEC + docs/02_Specs/PLAN-<slug>.md exist?       │
│  🔴 If NO → STOP → Create plan file first                    │
│  🔴 If YES → Proceed to specialist agents                    │
└─────────────────────────────────────────────────────────────┘
                              │
          ┌───────────────────┼───────────────────┐
          ▼                   ▼                   ▼
┌─────────────────┐ ┌─────────────────┐ ┌─────────────────┐
│ DATABASE        │ │ BACKEND         │ │ FRONTEND        │
│ ARCHITECT       │ │ SPECIALIST      │ │ SPECIALIST      │
│                 │ │                 │ │                 │
│ • Schema design │ │ • API routes    │ │ • Components    │
│ • Migrations    │ │ • Controllers   │ │ • Pages         │
│ • Seed data     │ │ • Middleware    │ │ • Styling       │
└─────────────────┘ └─────────────────┘ └─────────────────┘
          │                   │                   │
          └───────────────────┼───────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                 PARALLEL PHASE (Optional)                    │
│  • Security Auditor → Vulnerability check                   │
│  • Test Engineer → Unit tests                               │
│  • Performance Optimizer → Bundle analysis                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     DEVOPS ENGINEER                          │
│  • Environment setup                                         │
│  • Preview deployment                                        │
│  • Health check                                              │
└─────────────────────────────────────────────────────────────┘
```

## Execution Order

| Phase | Agent(s) | Parallel? | Prerequisite | CHECKPOINT |
|-------|----------|-----------|--------------|------------|
| 0 | Socratic Gate | ❌ | - | ✅ Ask 3 questions |
| 1 | Project Planner | ❌ | Questions answered | ✅ **SPEC + PLAN in docs/02_Specs/** |
| 1.5 | **SPEC + PLAN CHECK** | ❌ | SPEC + PLAN exist | ✅ **Files in docs/02_Specs/** |
| 2 | Database Architect | ❌ | Plan ready | Schema defined |
| 3 | Backend Specialist | ❌ | Schema ready | API routes created |
| 4 | Frontend Specialist | ✅ | API ready (partial) | UI components ready |
| 5 | Security Auditor, Test Engineer | ✅ | Code ready | Tests & audit pass |
| 6 | DevOps Engineer | ❌ | All code ready | Deployment ready |

> 🔴 **CRITICAL:** Phase 1.5 is MANDATORY. No specialist agents proceed without a SPEC + PLAN in docs/02_Specs/.
