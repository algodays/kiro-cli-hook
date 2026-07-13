#!/usr/bin/env bash
# skill-loader.sh — Skill Auto-Loader for Kiro agents
#
# Trigger: SessionStart  (stdout is added to the agent's context)
# Detects the project type by looking for marker files, then prints the
# matching skill markdown so the agent starts with domain-specific guidance.

set -uo pipefail

SKILL_DIR=".kiro/skills"
loaded=0

# Node / JavaScript / TypeScript
if [ -f "package.json" ] || [ -f "demo-app/package.json" ]; then
  if [ -f "$SKILL_DIR/node.md" ]; then
    echo "[Skill loaded: Node/JavaScript]"
    cat "$SKILL_DIR/node.md"
    loaded=1
  fi
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  if [ -f "$SKILL_DIR/python.md" ]; then
    echo "[Skill loaded: Python]"
    cat "$SKILL_DIR/python.md"
    loaded=1
  fi
fi

# Flutter / Dart
if [ -f "pubspec.yaml" ]; then
  if [ -f "$SKILL_DIR/flutter.md" ]; then
    echo "[Skill loaded: Flutter]"
    cat "$SKILL_DIR/flutter.md"
    loaded=1
  fi
fi

# Rust
if [ -f "Cargo.toml" ]; then
  if [ -f "$SKILL_DIR/rust.md" ]; then
    echo "[Skill loaded: Rust]"
    cat "$SKILL_DIR/rust.md"
    loaded=1
  fi
fi

# Go
if [ -f "go.mod" ]; then
  if [ -f "$SKILL_DIR/go.md" ]; then
    echo "[Skill loaded: Go]"
    cat "$SKILL_DIR/go.md"
    loaded=1
  fi
fi

if [ "$loaded" -eq 0 ]; then
  echo "[Skill Auto-Loader] No project-type marker found (package.json, requirements.txt, pubspec.yaml, Cargo.toml, go.mod). No skill injected. To add a skill, place a .md file in .kiro/skills/ and add a detection rule in skill-loader.sh."
fi
