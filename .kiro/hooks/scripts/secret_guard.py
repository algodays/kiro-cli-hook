#!/usr/bin/env python3
"""secret_guard.py — Secret & Dangerous-Command Guard

Trigger: PreToolUse (matcher: write|shell tools)
Action: shell command — this script.

Scans tool input (passed via env vars or stdin) for:
  - API keys / tokens:  sk-, AKIA, ghp_, github_pat_, xoxb-, AIza, Bearer
  - Private keys:       BEGIN RSA/OPENSSH/PGP PRIVATE KEY
  - Dangerous commands: rm -rf /, sudo, --no-verify, dd of=/dev/, chmod -R 777

Exit 0 = content is clean, allow the tool call.
Exit 2 = BLOCK the tool call (PreToolUse blocking), STDERR returned to agent.
"""

import os
import re
import sys

PATTERNS = [
    (r"sk-[a-zA-Z0-9]{20,}", "OpenAI API key (sk-...)"),
    (r"AKIA[0-9A-Z]{16}", "AWS access key (AKIA...)"),
    (r"ghp_[a-zA-Z0-9]{36}", "GitHub personal access token (ghp_...)"),
    (r"github_pat_[a-zA-Z0-9_]{22,}", "GitHub fine-grained PAT (github_pat_...)"),
    (r"xox[baprs]-[a-zA-Z0-9-]{10,}", "Slack token (xox...)"),
    (r"AIza[0-9A-Za-z\-_]{35}", "Google API key (AIza...)"),
    (r"Bearer\s+[a-zA-Z0-9\-._~+/]+=*", "Bearer auth token"),
    (r"-----BEGIN\s+(RSA|OPENSSH|PGP|EC)\s+PRIVATE\s+KEY-----", "Private key block"),
    (r"(?i)password\s*[:=]\s*['\"][^'\"]{6,}['\"]", "Hardcoded password"),
    (r"(?i)(api|secret|auth)_?key\s*[:=]\s*['\"][^'\"]{12,}['\"]", "Hardcoded API/secret key"),
]

DANGEROUS_CMDS = [
    (r"rm\s+-rf\s+/?(\s|$)", "rm -rf / — destructive root delete"),
    (r"(?i)\bsudo\b", "sudo — privileged command"),
    (r"--no-verify", "git --no-verify — bypassing git hooks"),
    (r"dd\s+.*of=/dev/", "dd to device — disk overwrite risk"),
    (r"chmod\s+-R\s+777", "chmod -R 777 — world-writable"),
    (r":\(\)\{:\|:&\};:", "fork bomb"),
]

def scan(text):
    """Return list of (pattern_description, matched_substring) tuples."""
    findings = []
    for pattern, desc in PATTERNS:
        m = re.search(pattern, text)
        if m:
            snippet = m.group(0)[:50]
            findings.append((desc, snippet))
    for pattern, desc in DANGEROUS_CMDS:
        if re.search(pattern, text):
            findings.append((desc, ""))
    return findings

def main():
    # Gather all possible input sources
    sources = []
    for key in ("TOOL_INPUT", "TOOL_NAME", "FILE_PATH", "USER_PROMPT"):
        val = os.environ.get(key, "")
        if val:
            sources.append(f"{key}={val}")
    stdin_data = ""
    try:
        stdin_data = sys.stdin.read()
    except Exception:
        pass
    if stdin_data:
        sources.append(f"stdin={stdin_data}")

    blob = "\n".join(sources)
    if not blob.strip():
        # No input to scan — allow (nothing to block)
        sys.exit(0)

    findings = scan(blob)
    if not findings:
        sys.exit(0)

    # Block!
    print("SECRET GUARD BLOCKED this tool call. Risks found:", file=sys.stderr)
    for desc, snippet in findings:
        if snippet:
            print(f"  - {desc}: '{snippet}'", file=sys.stderr)
        else:
            print(f"  - {desc}", file=sys.stderr)
    print("\nDo NOT proceed. Warn the user and suggest a safe alternative.", file=sys.stderr)
    sys.exit(2)

if __name__ == "__main__":
    main()
