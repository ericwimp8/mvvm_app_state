---
name: topical-dart-unit-testing
description: Dart and Flutter unit-testing patterns with Mocktail. Use when writing Dart unit tests, Flutter widget tests, mocking dependencies, stubbing methods, verifying interactions, or testing async code below the integration layer. Do not use this skill for integration tests, `integration_test/**`, or emulator/device-driven end-to-end flows.
---

# Dart Unit Testing with Mocktail

## Critical Constraints

- You must keep generated test files comment-free.
- You must convert repeated test shapes to typed table-driven matrices when 3 or more cases share one setup/act path.
- You must keep setup minimal and behavior-focused.
- You must not treat this skill as guidance for integration tests or runtime device/emulator flows.

## File Index

Each file covers a testing concern. Format: What it covers / When to use it.

- `core-concepts.md` — Mock vs Fake fundamentals, test lifecycle, reset patterns
  - Table-driven tests (`critical`) — when 3+ tests share one setup/act shape and only input/output varies
  - Setup minimality (`critical`) — use injectable seams first; keep setup smaller than behavior assertions
  - Create a mock — when you need to stub and verify method calls
  - Create a fake — when you need partial real implementations
  - Choose between Mock and Fake — when deciding which approach fits your test
  - Mock a callback — when testing code that accepts function parameters
  - Set up test lifecycle — when structuring tests with fresh mocks and minimal shared setup
  - Reset mock state — when a reused mock instance requires explicit state reset
  - Resolve unawaited future warnings — when analyzer reports `unawaited_futures` and you need to choose `await` vs `unawaited(...)`

- `stubbing.md` — when(), thenReturn(), thenAnswer() patterns
  - Return a synchronous value — when stubbing getters or sync methods
  - Return an async value or stream — when stubbing Futures or Streams
  - Access invocation arguments — when return value depends on input
  - Stub different values for specific arguments — when different inputs need different outputs
  - Throw exceptions — when testing error handling paths
  - Return different values on sequential calls — when testing retry or pagination logic
  - Stub generic methods — when mocking methods with type parameters

- `matchers-verification.md` — any(), verify(), captureAny() patterns
  - Match any argument value — when you don't care about specific values
  - Match arguments with custom conditions — when you need constrained matching
  - Register custom types for any() — when using any() with custom classes
  - Verify call count — when asserting a method was called N times
  - Verify never called — when asserting a method should not be invoked
  - Verify call order — when sequence of calls matters
  - Verify no interactions — when asserting complete isolation
  - Capture arguments — when you need to assert on actual values passed

- `async-testing.md` — Stream, Future, and time-based testing
  - Test stream emissions — when verifying Stream output sequence
  - Test state notifier emissions — when testing StateNotifier or similar
  - Test Future completion — when verifying async success
  - Test Future throws — when verifying async error handling
  - Test debounced operations — when testing delayed/throttled behavior
  - Test retry behavior — when testing resilient operations

- `widget-testing.md` — Flutter widget tests with mocks, Riverpod, Bloc
  - Test widget with mocked dependencies — when unit testing widgets
  - Test with Provider — when widget uses Provider for DI
  - Test with Riverpod — when widget uses Riverpod providers
  - Advance frames or wait for animations — when testing async UI updates
  - Find widgets by selectors — when locating widgets for assertions
  - Mock network images — when testing widgets with Image.network
  - Fake Flutter classes — when mocking ThemeData or BuildContext
  - Test Bloc/Cubit — when testing state management with bloc_test

## Usage

This index contains curated patterns that supersede general approaches. When writing code for any problem listed above, read the matching file first—do not rely on general knowledge.

**Before writing:** Scan this index. If your task matches an entry, read that file.
**While writing:** If you're about to write non-trivial test logic, pause and check if a pattern exists here.
**After writing:** Verify your code matches the patterns in the relevant files, not just your training.
