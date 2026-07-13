#!/usr/bin/env bash
# plan-first.sh — Plan-First Gate for Kiro agents
#
# Trigger: UserPromptSubmit  (Kiro sets USER_PROMPT env var)
# Exit 0 = allow prompt through to the agent
# Exit 2 = BLOCK prompt, STDERR is returned to the agent as guidance
#
# Workflow:
#   1. User asks to build/change something  -> BLOCK, tell agent to plan first
#   2. Agent explores codebase, writes .kiro/plan/PLAN.md, asks for approval
#   3. User replies "approve plan"          -> create APPROVED marker, allow
#   4. Agent executes the approved plan
#   5. User says "new task" / "reset"       -> clear marker, back to plan mode

set -uo pipefail

PLAN_DIR=".kiro/plan"
PLAN_FILE="$PLAN_DIR/PLAN.md"
APPROVED_MARKER="$PLAN_DIR/APPROVED"
TODO_FILE="$PLAN_DIR/TODO.md"

mkdir -p "$PLAN_DIR" 2>/dev/null

PROMPT="${USER_PROMPT:-}"

# --- 1) Reset / new task — check FIRST so it works even when approved -----
if echo "$PROMPT" | grep -qiE '(new task|reset plan|start over|cancel plan|naya task)'; then
  rm -f "$APPROVED_MARKER" "$PLAN_FILE" "$TODO_FILE"
  echo "Plan reset. Back to plan mode — describe a new task to begin."
  exit 0
fi

# --- 2) Approval command -------------------------------------------------
if echo "$PROMPT" | grep -qiE '^(approve plan|approve|approved|plan approved|go ahead|proceed|execute plan|start coding|start building|lag jao|kar do|start karo)\b'; then
  if [ -f "$PLAN_FILE" ]; then
    touch "$APPROVED_MARKER"
    echo "PLAN APPROVED. Execution mode unlocked. You may now edit files and run commands to implement the plan in $PLAN_FILE. Remove the APPROVED marker only when the task is fully done."
    exit 0
  else
    echo "Cannot approve: no plan found at $PLAN_FILE. First describe the task so the agent can write a plan." >&2
    exit 2
  fi
fi

# --- 3) Already approved — allow execution -------------------------------
if [ -f "$APPROVED_MARKER" ]; then
  exit 0
fi

# --- 4) Detect MUTATING requests — block if no approval yet ---------------
# Common mutating verbs in English + Hinglish
if echo "$PROMPT" | grep -qiE '\b(add|create|build|fix|update|delete|remove|change|modify|implement|write|edit|refactor|install|deploy|make|generate|set up|setup|move|rename|migrate|configure|ban[ao]|banao|likho|change karo|update karo|fix karo|add karo|implement karo)\b'; then
  cat >&2 <<'PLANMODE'
PLAN MODE ACTIVE — the plan-first-gate hook requires a plan before any file changes.

You are NOT allowed to edit files or run mutating commands yet. Instead:
1. Explore the codebase using read-only tools (file reads, searches, greps).
2. Write a clear, step-by-step plan to .kiro/plan/PLAN.md with:
   - Goal of the task
   - Files that will be created or modified
   - Implementation steps in order
   - Risks and edge cases to watch for
3. Show the plan to the user and ask them to reply "approve plan" to unlock execution.

Do NOT make any file changes until the user explicitly approves the plan.
PLANMODE
  exit 2
fi

# --- 5) Everything else (questions, greetings, short prompts) — allow -----
exit 0
