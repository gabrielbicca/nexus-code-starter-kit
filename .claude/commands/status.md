---
description: Display agent and project status. Progress tracking and status board.
---

# /status - Show Status

$ARGUMENTS

---

## Task

Show current project and agent status.

### What It Shows

1. **Project Info**
   - Project name and path
   - Tech stack
   - Current features

2. **Agent Status Board**
   - Which agents are running
   - Which tasks are completed
   - Pending work

3. **File Statistics**
   - Files created count
   - Files modified count

4. **Preview Status**
   - Is server running
   - URL
   - Health check

5. **Code Hygiene Reminder (periodic — kit rule of thumb)**
   - Check when the last dead-code/tech-debt sweep happened (look for a report in `docs/03_Sprint_Logs/` or a "varredura" entry in recent sprint logs)
   - If there's no sweep in the last sprint (~2 weeks) or none ever ran, **suggest**: "Considere rodar o `@clean-code-auditor` (varredura de débito técnico e código morto — skill `dead-code-sweep`)"
   - This is a suggestion, not a blocker — never run the sweep automatically from /status

---

## Example Output

```
=== Project Status ===

📁 Project: my-ecommerce
📂 Path: C:/projects/my-ecommerce
🏷️ Type: nextjs-ecommerce
📊 Status: active

🔧 Tech Stack:
   Framework: next.js
   Database: postgresql
   Auth: clerk
   Payment: stripe

✅ Features (5):
   • product-listing
   • cart
   • checkout
   • user-auth
   • order-history

⏳ Pending (2):
   • admin-panel
   • email-notifications

📄 Files: 73 created, 12 modified

=== Agent Status ===

✅ database-architect → Completed
✅ backend-specialist → Completed
🔄 frontend-specialist → Dashboard components (60%)
⏳ test-engineer → Waiting

=== Preview ===

🌐 URL: http://localhost:3000
💚 Health: OK
```

---

## Technical

Status uses these scripts:
- `python .claude/scripts/session_manager.py status`
- `python .claude/scripts/auto_preview.py status`
