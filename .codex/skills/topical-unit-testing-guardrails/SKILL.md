---
name: topical-unit-testing-guardrails
description: Repository entrypoint for Dart and Flutter unit testing guardrails. Mandatory use every time when writing Dart unit tests.
---

# Topical Unit Testing Guardrails

## Usage

This skill is the entrypoint for Dart and Flutter unit-testing work in this repository.

## Mandatory Skill Load Matrix

- Load other topical unit-testing skills as needed:
- `topical-dart-unit-testing`

**Before writing:** Open the reference that matches the unit-testing stack you are working in.
**While writing:** Apply the referenced guardrails for coverage, determinism, and review scope.
**After writing:** Verify the resulting test changes still follow the selected reference and the local codebase patterns.

## File Index

- [Dart And Flutter Tests](references/dart-and-flutter-tests.md) - Guardrails for writing or updating Dart unit tests, Flutter widget tests, and provider/notifier tests in this codebase. Open this every time the task touches those non-integration test layers under `test/**`.
