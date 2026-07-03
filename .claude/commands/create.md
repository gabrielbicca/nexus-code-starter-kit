---
description: Create new application command. Triggers App Builder skill and starts interactive dialogue with user.
---

# /create - Create Application

$ARGUMENTS

---

## Task

This command starts a new application creation process.

### Steps:

1. **Request Analysis**
   - Understand what the user wants
   - If information is missing, use `conversation-manager` skill to ask

2. **Project Planning**
   - Use `project-planner` agent for task breakdown
   - Determine tech stack
   - Plan file structure
   - Create plan file and proceed to building

3. **Application Building (After Approval)**
   - Orchestrate with `app-builder` skill
   - Coordinate expert agents:
     - `database-architect` → Schema
     - `backend-specialist` → API
     - `frontend-specialist` → UI

4. **Quality Gate (🔴 MANDATORY — kit rule, never skip)**
   - `test-engineer` → implement tests in the test layer covering **every functionality built** (all features mapped to tests; E2E via `qa-automation-engineer` when applicable)
   - `security-auditor` → security review of everything built; address findings before finishing
   - Run the verification (`/verify` or the test suite) and report the **real output** — completion is declared with evidence, never with "should work"
   - Mark the SPEC's **Gate de qualidade** checkboxes (tests, security review, verification evidence) — `spec_drift.py` fails a `concluída` SPEC without them

5. **Preview**
   - Start with `auto_preview.py` when complete
   - Present URL to user

---

## Usage Examples

```
/create blog site
/create e-commerce app with product listing and cart
/create todo app
/create Instagram clone
/create crm system with customer management
```

---

## Before Starting

If request is unclear, ask these questions:
- What type of application?
- What are the basic features?
- Who will use it?

Use defaults, add details later.
