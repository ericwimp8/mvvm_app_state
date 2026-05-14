# Dart And Flutter Tests

Use this reference whenever the testing task is a Dart or Flutter unit, widget, provider, or notifier test.

Do not use this reference for app/runtime integration tests, `integration_test/**`, emulator-driven end-to-end flows, or driver/device automation tasks.

## Purpose

- Keep tests aligned with changed public behavior.
- Maximize regression signal per test while minimizing maintenance cost.
- Prefer behavior contracts over implementation details.

## Core Rules

- Assert observable behavior: outcomes, state transitions, emitted effects, persisted changes, and externally visible interactions.
- Do not assert internal triggers, private mechanics, or incidental call sequences unless that interaction is itself the public contract.
- Keep assertions resilient to harmless refactors.
- Keep test-writing work focused on proving behavior; do not change production implementation solely to make a newly added or corrected test pass.
- If a correctly scoped test exposes an implementation bug, keep the bug evidence visible; do not weaken the assertion or rewrite the test around incorrect behavior.
- Keep test files concise and comment-free; encode intent with clear test, group, and matrix names.
- Keep touched test files analyzer-clean.

## Test Layer Selection (Cheapest Proof First)

- Prove behavior at the lowest-cost layer that can validate the contract:
  - pure logic: unit test
  - provider/notifier behavior: provider or notifier test
  - UI composition/semantics: widget test
- Escalate to a heavier layer only when a lighter layer cannot prove the contract.
- Avoid duplicating the same contract across multiple layers unless the additional layer protects a distinct risk.
- If the required proof crosses app/runtime boundaries and needs integration or emulator coverage, stop using this reference and switch to the integration-testing guidance for that stack instead of stretching unit/widget/provider rules to fit.

## Coverage Strategy (Risk-Proportionate)

- Start from changed public behavior, not implementation branches.
- For each changed behavior, consider relevant paths:
  - success
  - expected failure
  - exception or fault
  - boundary or empty-state (when applicable)
- Add tests only where they materially reduce regression risk.
- Directly cover high-risk behavior (writes, auth, permissions, error handling, data integrity, concurrency boundaries).
- Cover core medium-risk rule transitions that define feature correctness.
- Skip low-value or trivial paths unless risk or history justifies them.
- If a path is intentionally skipped, document it in task or PR summary, not in test-file comments.

## Path Check (Lightweight)

- Keep a brief internal path check for each changed behavior:
  - behavior contract
  - risk level (`high`, `medium`, `low`)
  - proof (`test name` or matrix row) or intentional skip reason
- Keep this lightweight and task-focused; do not create formal ledger artifacts unless explicitly requested.
- Do not finish with uncovered high-risk paths.
- Do not leave medium-risk paths unaccounted (covered or explicitly justified).

## Bug Discovery And Blockers

- When validation reveals an implementation bug or another blocker, report it in the task or PR summary instead of hiding it in test changes.
- Keep blocker reporting lightweight:
  - behavior contract under test
  - observed failure or blocker
  - why the test remains correct
  - next concrete action
- A clear blocker report is an acceptable outcome for test-writing work when implementation repair is outside the current task scope.

## Structure

- Keep unavoidable local helpers minimal and narrowly scoped.
- Use typed table-driven matrices for repetitive input and output checks.
- Keep standalone tests for unique contracts (side effects/interactions, ordering/lifecycle, known regressions, error-quality expectations).

## Isolation And Determinism

- Default to fresh mocks and fakes in `setUp`.
- Avoid `tearDown` resets when doubles are recreated per test.
- Use `reset(...)` only when a shared double is intentional and reset is required for isolation.
- Prefer deterministic async control (`pump`, listeners, fake-async patterns) over timing-based waits.
- Control nondeterministic dependencies (clock, random, network, filesystem) via fakes or mocks.
- For timer-driven provider/notifier behavior, prefer capturing scheduled timer
  callbacks from a fake/mocked timer service (or fake async clock advancement)
  and invoking them deterministically in tests instead of relying on wall-clock
  waits.

## Quick Self-Check

1. Did I test changed behavior (not internals)?
2. Did I choose the cheapest test layer that proves each contract?
3. Are high-risk paths directly covered and medium-risk paths accounted for?
4. Did I keep structure DRY?
5. If a correct test failed, did I preserve the bug signal and report the blocker instead of forcing a green result?
6. Is the resulting test set high-value without unnecessary blowout?
