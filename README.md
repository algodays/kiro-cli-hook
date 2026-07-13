# kiro-plan-mode — A plan-first discipline layer for Kiro agents

> Built for Kiro Birthday Week 2026, Day 1: "Build a hook."

Kiro's Agent Hooks are a great automation primitive, but I kept running into the same problem: the agent would jump straight to editing files the moment I asked for a feature, sometimes before it had fully understood the codebase. The diff would be fine, but the *plan* behind it was implicit. I wanted the agent to think before it wrote code — and I wanted to approve that plan before any file was touched.

So I built a small hook pack that enforces a plan-first workflow, entirely with the hooks system Kiro already ships. No fork, no plugin, no external tooling — just four JSON files in `.kiro/hooks/` and a few shell scripts.

## What it does

When you ask the agent to build or change something, the **plan-first gate** intercepts the prompt before it reaches the model and blocks execution. The agent is told to explore the codebase with read-only tools, write a structured plan to `.kiro/plan/PLAN.md`, and wait. Nothing gets edited until you reply `approve plan`. Once approved, execution is unlocked and the agent can implement the plan. A `new task` reset puts you back in plan mode for the next request.

Read-only questions — "what does this file do?", "explain the architecture" — pass through without blocking, so you don't get gated out of quick conversations.

The three companion hooks round out the workflow:

- **skill-auto-loader** runs on session start, detects the project type from marker files (`package.json`, `requirements.txt`, `pubspec.yaml`, `Cargo.toml`, `go.mod`), and injects the matching skill markdown into the agent's context so it starts with the right conventions.
- **todo-tracker** fires after every agent turn and keeps `.kiro/plan/TODO.md` in sync with what's done and what's still pending.
- **secret-guard** runs before any write tool and stops the agent from committing API keys, tokens, private keys, or dangerous shell commands (`rm -rf /`, `sudo`, `--no-verify`).

## The four hooks

| Hook | Trigger | Action | What it does |
|---|---|---|---|
| plan-first-gate | `UserPromptSubmit` | Shell command | Blocks mutating prompts until a plan is written and approved (exit 2). Questions pass through. |
| skill-auto-loader | `SessionStart` | Shell command | Detects project type and injects the matching skill markdown into context. |
| todo-tracker | `Stop` | Agent prompt | Updates `.kiro/plan/TODO.md` after every turn with completed/pending tasks. |
| secret-guard | `PreToolUse` (write tools) | Agent prompt | Scans tool input for secrets and dangerous commands before any write. |

### Why shell commands where possible

Shell command actions run locally and don't consume credits, since they don't trigger an LLM loop. Agent prompt actions do. The plan-first-gate and skill-auto-loader are deterministic — given the same prompt or project layout, they always produce the same result — so they use shell commands. The todo-tracker and secret-guard need to reason about the agent's context, so they use agent prompts.

## Install

```bash
git clone https://github.com/algodays/kiro-cli-hook.git
cd kiro-cli-hook
chmod +x .kiro/hooks/scripts/*.sh .kiro/hooks/scripts/*.py
```

Open the project in Kiro IDE, or run `kiro-cli chat` from the directory. The hooks activate automatically — the skill-auto-loader runs on session start, and the plan-first-gate intercepts your prompts.

## Workflow

```
you: "add a dark mode toggle to the app"
  → agent: blocked. explores the codebase, writes a plan to .kiro/plan/PLAN.md, asks for approval.

you: "approve plan"
  → agent: plan approved. now edits files and runs commands to implement it.

you: "new task"
  → resets back to plan mode for the next request.
```

Read-only questions pass through without blocking.

## Repository structure

```
.
├── .kiro/
│   ├── hooks/
│   │   ├── plan-first-gate.json        # UserPromptSubmit → plan-mode enforcement
│   │   ├── skill-auto-loader.json      # SessionStart → inject project-type skill
│   │   ├── todo-tracker.json           # Stop → update TODO.md
│   │   ├── secret-guard.json           # PreToolUse → block secrets / dangerous commands
│   │   └── scripts/
│   │       ├── plan-first.sh           # USER_PROMPT parsing → block/allow logic
│   │       ├── skill-loader.sh         # Detect marker files, print skill markdown
│   │       └── secret_guard.py         # Regex scan for API keys, private keys, rm -rf
│   ├── skills/
│   │   ├── node.md                     # Node/JS conventions
│   │   ├── python.md                   # Python conventions
│   │   ├── flutter.md                  # Flutter conventions
│   │   ├── rust.md                     # Rust conventions
│   │   └── go.md                      # Go conventions
│   ├── steering/
│   │   └── project-rules.md            # Repository rules for the agent
│   └── plan/                           # Runtime artifacts (gitignored)
│       ├── PLAN.md                     # Written by the agent during planning
│       ├── APPROVED                    # Marker file created on approval
│       └── TODO.md                     # Auto-updated after each turn
├── demo-app/
│   ├── package.json
│   ├── src/
│   │   ├── server.js                   # Node HTTP server: todo CRUD + login
│   │   └── test.test.js
│   └── public/
│       └── index.html                  # Todo UI (dark mode toggle added by the agent after plan approval)
├── demo/
│   ├── demo.html                       # Animated presentation used for the demo video
│   └── video/demo-video.mp4            # 41s demo
├── .gitignore
└── README.md
```

## Demo

A 41-second demo is included at `demo/video/demo-video.mp4`. It walks through the plan-first workflow: a mutating prompt gets blocked, the agent writes a plan, the user approves, and the agent implements a dark mode toggle on the demo app.

The dark mode toggle in `demo-app/public/index.html` was added by the Kiro agent itself, *after* the plan-first-gate hook forced it to plan and get approval first. That commit is the proof the workflow works end-to-end.

## How Kiro was used

This project was built end-to-end inside Kiro. I used the IDE's "Ask Kiro to create a hook" UI to scaffold the initial hook JSON structures, then iterated on the shell scripts in `kiro-cli chat` — particularly the plan-first gate's prompt detection, which took a few rounds of regex tuning to correctly separate mutating requests from read-only questions without blocking normal conversation.

The steering file in `.kiro/steering/project-rules.md` was written to keep the agent honest: hooks should prefer shell commands over agent prompts where the logic is deterministic, the demo app should stay minimal, and runtime plan artifacts should be gitignored. The agent followed these rules while writing code, which kept the structure consistent.

Each hook was tested directly in the Kiro agent before committing. The plan-first-gate was validated by submitting mutating prompts and confirming the block (exit 2), then approving and confirming execution unlocked. The skill-auto-loader was verified by checking that the Node skill markdown appeared in the session context when `package.json` was present. The secret-guard was tested by feeding it a fake `sk-...` key and confirming the block.

The entire `.kiro/` folder — hooks, scripts, skills, and steering — was written with Kiro's assistance, and the demo app's dark mode feature was implemented by the agent after going through the plan-first workflow itself.

## License

MIT
