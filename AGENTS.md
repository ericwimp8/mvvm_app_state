## Source Of Truth Directive (Mandatory)

1. **Source code is the source of truth.**
All technical decisions during research, implementation, debugging, and code reading must be grounded in production source code.

2. **Trace all relevant code paths end-to-end.**
For any behavior you analyze or change, trace all relevant paths through abstractions all the way to concrete implementations. Do not stop at interfaces, wrappers, helpers, or other abstractions.

3. **Do not use tests as a source of truth.**
Never use tests as truth for behavior, contracts, or interaction flow, no matter what they test or how they test.

4. **Treat tests as potentially misleading during analysis.**
Tests can be incomplete or incorrect and can mislead implementation, debugging, and code reading if treated as truth.

5. **Code choices must come from source code, not tests.**
All decisions about design, behavior, interactions, and fixes must be based on traced source code. Tests may only be used after that to validate or detect mismatch.

## Topical Skills (Agent Instruction)

Skills with a `topical-` prefix are binding implementation contracts for their topic.

How to use them:
- Use relevant `topical-*` skills early to identify required patterns.
- For applicable scope, skills are the source of truth.
- Do not invent new patterns; reuse established codebase patterns that comply with skills.
- If a request, plan, or existing code conflicts with a skill, halt and report the conflict before editing.

## Core Guardrails (Always Apply)

- **CRITICAL: NEVER use destructive or irreversible git commands** unless explicitly instructed by the user (includes: `git push --force`, `git reset --hard`, `git rebase`, `git branch -D`, `git clean -fd`, or any command that rewrites history or permanently deletes data)

## Test Commands

Use stack-appropriate scoped test commands. Never run the full suite unless explicitly requested.
- For Dart scoped tests, prefer direct multi-path invocations over shell loops when running more than one file, for example `dart test test/a_test.dart test/b_test.dart`.

## Documentation

- Keep documentation and comments minimal.
- Add comments only when they clarify non-obvious intent, constraints, or tradeoffs.
- Do not add comments that restate what the code already makes clear.

## Quality Checks (All Stacks)

After code changes, run the idiomatic CLI checks for the touched area (format, lint, static/type checks, and relevant scoped tests).
Choose the order based on fastest feedback and the changed files/modules.

Rules:
- Prefer repo-defined commands first.
- Start scoped to changed files/modules; run broader checks only if needed or required.
- Fix issues introduced by your changes before finishing.
- If a check cannot run, state exactly what was skipped and why.

## End-Of-Task Skill Audit

After completing coding tasks, list the skills that were used.
