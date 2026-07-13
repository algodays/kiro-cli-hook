# Project Rules — kiro-plan-mode

This steering file guides the AI agent when working in this repository.

## Repository purpose

`kiro-plan-mode` adds a plan-first discipline layer to Kiro agents using Kiro's native Agent Hooks system. It is a submission for the Kiro Birthday Week 2026 Day 1 challenge: "Build a hook."

## Architecture

The project has two parts:

1. **Hook pack** (`.kiro/hooks/`) — four JSON hook definitions plus shell/Python scripts that implement Plan Mode, Skill auto-loading, Todo tracking, and Secret guarding.
2. **Demo app** (`demo-app/`) — a minimal Node/Express todo app used to demonstrate the hooks in action.

## Rules

- **Never commit secrets.** The `.kiro/plan/APPROVED` marker and `.kiro/plan/PLAN.md` are runtime artifacts — they are gitignored.
- **Hooks use shell commands where possible** (no credit consumption) and agent prompts only when the agent must reason about context.
- **Scripts must be deterministic** — given the same `USER_PROMPT`, the plan-first gate must always produce the same exit code.
- **All hooks are enabled by default.** Disable individually via the `enabled: false` field if needed.
- **The demo app must stay simple** — it exists to show hooks working, not to be a full product.

## File locations

- Hook JSON configs: `.kiro/hooks/*.json`
- Hook scripts: `.kiro/hooks/scripts/`
- Skill definitions: `.kiro/skills/*.md`
- Steering rules: `.kiro/steering/*.md`
- Runtime plan/todo: `.kiro/plan/` (gitignored)
- Demo app: `demo-app/`
