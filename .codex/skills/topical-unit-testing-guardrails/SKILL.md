---
name: topical-unit-testing-guardrails
description: Repository entrypoint for unit-testing work in this repository. Use when writing or changing non-integration Dart or Flutter tests, then open the relevant stack reference before editing tests. Do not use this skill for `integration_test/**`, app/runtime integration tests, or emulator/device-driven end-to-end flows.
---

# Topical Unit Testing Guardrails

## Usage

This skill is the entrypoint for unit-testing work in this repository.

Do not load this skill for app/runtime integration tests, emulator-driven integration tests, or device/driver automation flows.

## Mandatory Skill Load Matrix

- Load other topical unit-testing skills as needed:
- `topical-dart-unit-testing`

**Before writing:** Open the reference that matches the unit-testing stack you are working in.
**While writing:** Apply the referenced guardrails for coverage, determinism, and review scope.
**After writing:** Verify the resulting test changes still follow the selected reference and the local codebase patterns.

## File Index

- [Dart And Flutter Tests](references/dart-and-flutter-tests.md) - Guardrails for writing or updating Dart unit tests, Flutter widget tests, and provider/notifier tests in this codebase. Open this every time the task touches those non-integration test layers under `test/**`.
