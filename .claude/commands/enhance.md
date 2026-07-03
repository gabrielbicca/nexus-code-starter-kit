---
description: Add or update features in existing application. Used for iterative development.
---

# /enhance - Update Application

$ARGUMENTS

---

## Task

This command adds features or makes updates to existing application.

### Steps:

1. **Understand Current State**
   - Load project state with `python .claude/scripts/session_manager.py info`
   - Understand existing features, tech stack

2. **Plan Changes**
   - Determine what will be added/changed
   - Detect affected files
   - Check dependencies

3. **Present Plan to User** (for major changes)
   ```
   "To add admin panel:
   - I'll create 15 new files
   - Update 8 files
   - Takes ~10 minutes
   
   Should I start?"
   ```

4. **Apply**
   - Call relevant agents
   - Make changes

5. **Quality Gate (🔴 MANDATORY — kit rule, never skip)**
   - `test-engineer` → implement tests in the test layer for **every new/changed functionality** (all features mapped to tests)
   - `security-auditor` → security review of the changes; address findings before finishing
   - Run the verification (`/verify` or the test suite) and report the **real output** — completion is declared with evidence, never with "should work"
   - Mark the SPEC's **Gate de qualidade** checkboxes (tests, security review, verification evidence) — `spec_drift.py` fails a `concluída` SPEC without them

6. **Update Preview**
   - Hot reload or restart

---

## Usage Examples

```
/enhance add dark mode
/enhance build admin panel
/enhance integrate payment system
/enhance add search feature
/enhance edit profile page
/enhance make responsive
```

---

## Caution

- Get approval for major changes
- Warn on conflicting requests (e.g., "use Firebase" when project uses PostgreSQL)
- Commit each change with git
