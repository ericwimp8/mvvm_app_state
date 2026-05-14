# Core Concepts

Mocktail provides null-safe mocking without code generation, working with `package:test` and `flutter_test`.

## `CRITICAL`: Table-driven tests first

`cases + for loop`

If 3 or more tests share one Arrange/Act shape and differ only by inputs/expected outputs, you must convert them to one typed table-driven matrix.

### What counts as table-driven

- One typed case list with named fields.
- One observable behavior per row.
- One act path and one assertion pattern in the loop body.
- Case data holds variation; loop body stays mostly branch-free.

### When one-off tests are still correct

Keep standalone tests only for:
- side effects/interactions (for example verify call counts/order)
- lifecycle/ordering behavior
- exception-message quality
- known regression setup that cannot fit matrix shape

Do not keep both equivalent one-off tests and matrix rows for the same behavior.

### Matrix decision gate (run before finalize)

Convert to matrix when all are true:
- repeated Arrange/Act shape exists
- only input/expected values differ
- 3 or more near-duplicate tests exist

Keep one-off when any are true:
- assertion shape differs materially
- setup differs materially
- case is a unique regression with custom setup

### Conversion playbook

1. Identify duplicate tests and extract varying fields.
2. Create typed case rows with behavior-oriented names.
3. Keep one act path in loop body.
4. Keep one assertion pattern in loop body.
5. Delete equivalent one-off tests.
6. Keep only uniquely different one-off tests.

### Correct matrix example (service-style)

```dart
group('success shapes', () {
  typedef Case = ({
    String name,
    Map<String, dynamic> envelope,
    int expectedCount,
  });

  final cases = <Case>[
    (name: 'null data field -> empty', envelope: {'data': null}, expectedCount: 0),
    (name: 'empty array -> empty', envelope: {'data': <dynamic>[]}, expectedCount: 0),
    (
      name: 'mixed values -> one valid item retained',
      envelope: {
        'data': ['not-a-map', {'id': 'item-1', 'enabled': true}],
      },
      expectedCount: 1,
    ),
  ];

  for (final c in cases) {
    test(c.name, () async {
      parser.source = c.envelope;
      final data = await parser.fetchItems();
      expect(data.length, c.expectedCount);
    });
  }
});
```

### Final check

Before finalizing, run a repetition check: if repeated Arrange/Act shape exists, matrix conversion is required.

## `CRITICAL`: Setup minimality first

You must prove behavior with the smallest setup that can fail on a real regression.

### Setup ladder (use in order)

1. You must use injectable seams first (constructor/function parameters).
2. You must add local fakes/mocks only for uncovered seams.
3. You must use SDK/platform bootstrap only when no injectable seam can prove the contract.

### Practical rules

- You must keep shared setup in `setUp`/`setUpAll` and keep per-case variation in matrix rows.
- You must keep local fake types minimal and reusable across cases.
- You must keep assertions focused on contract behavior, not infrastructure wiring.

### Good example: injection-first error mapping

```dart
test('maps timeout errors without platform bootstrap', () async {
  final client = MockItemClient();

  when(() => client.fetchItems()).thenThrow(
    const TimeoutException('request timed out'),
  );

  final repository = ItemRepository(
    client: client,
    retryCount: 0,
  );

  expect(
    repository.loadItems,
    throwsA(isA<ItemLoadException>()),
  );
});
```

### Good example: table-driven success shapes with one setup path

```dart
group('success shapes', () {
  late MockItemClient client;

  setUp(() {
    client = MockItemClient();
  });

  final cases = [
    (name: 'null items -> empty', payload: {'items': null}, expectedCount: 0),
    (name: 'empty items -> empty', payload: {'items': <dynamic>[]}, expectedCount: 0),
  ];

  for (final c in cases) {
    test(c.name, () async {
      when(() => client.fetchItems()).thenAnswer(
        (_) async => c.payload,
      );

      final repository = ItemRepository(client: client);

      final data = await repository.loadItems();
      expect(data.length, c.expectedCount);
    });
  }
});
```

## `CRITICAL`: Assert behavior, not non-nullability

You must use `isNotNull` only when a value is nullable at runtime and null/non-null is part of the contract branch under test.

### Assertion rules

- You must remove `isNotNull` assertions for non-nullable static types.
- You must replace non-nullability-only checks with observable behavior assertions.
- You must keep nullable `isNotNull` checks only when they gate a real branch.
- You must follow a nullable guard with a concrete post-unwrap assertion whenever possible.

### Decision gate

Use `isNotNull` only when all are true:
- the expression type is nullable
- null/non-null distinguishes behavior under test
- a stronger direct contract assertion cannot replace it

Do not use `isNotNull` when any are true:
- type is non-nullable
- assertion only duplicates constructor/type guarantees
- assertion does not prove observable behavior

### Good example: remove low-signal non-nullability check

```dart
test('returns the configured formatter', () {
  final result = createFormatter();
  expect(result, isA<RecordFormatter>());
});
```

### Good example: nullable guard plus concrete contract assertion

```dart
test('activates fallback and exposes a usable root event id', () async {
  triggerFatalError();
  final activeId = activeRootEventId();

  expect(activeId, isNotNull);
  expect(activeId!, isNotEmpty);
  expect(boundary.isFallbackActive, isTrue);
});
```

### Good example: collection behavior over object existence

```dart
test('enabled items query returns only enabled items', () async {
  final store = FakeItemStore([
    const Item(id: '1', enabled: true),
    const Item(id: '2', enabled: false),
    const Item(id: '3', enabled: true),
  ]);

  final items = await store.enabledItems();

  expect(items.map((item) => item.id), ['1', '3']);
  expect(items.every((item) => item.enabled), isTrue);
});
```

## Create a mock for stubbing and verification

`class MockClass extends Mock implements YourClass {}`

Allows stubbing method return values with `when()` and verification with `verify()`. Unstubbed methods return `null` by default.

```dart
class MockUserRepository extends Mock implements UserRepository {}

final mock = MockUserRepository();
when(() => mock.getUser('123')).thenAnswer((_) async => user);
verify(() => mock.getUser('123')).called(1);
```

## Create a fake for partial implementation

`class FakeClass extends Fake implements YourClass {}`

Provides partial real implementations. Override specific methods with actual logic. Unoverridden methods throw `UnimplementedError`. Cannot use `when()`/`verify()` with Fakes.

```dart
class FakeUserRepository extends Fake implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    return User(id: id, name: 'Test User');
  }
}
```

## Choose between Mock and Fake

| Use Mock When | Use Fake When |
|---------------|---------------|
| Testing interactions (method called X times) | Need consistent, predictable data |
| Different return values per test | Simulating complex behavior |
| Need to verify arguments passed | Partial implementations suffice |
| Testing error scenarios | Performance-sensitive tests |

## Mock a callback or function

`class MockCallback extends Mock { void call(...); }`

For mocking top-level functions or callbacks, create a mock class with a `call` method matching the function signature.

```dart
class MockCallback extends Mock {
  void call(String value);
}

class MockAsyncCallback extends Mock {
  Future<bool> call(Uri url, {LaunchMode? mode});
}

final mockCallback = MockCallback();
when(() => mockCallback('test')).thenReturn(null);
```

## Set up test lifecycle with mocks

`setUp()` / `setUpAll()`

Structure tests with minimal lifecycle state. Prefer creating fresh mocks in `setUp` and avoid teardown resets when mocks are recreated per test.

```dart
void main() {
  late MockApiClient mockClient;
  late UserRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(Uri());
  });

  setUp(() {
    mockClient = MockApiClient();
    repository = UserRepository(client: mockClient);
  });

  group('getUser', () {
    test('returns user on success', () async {
      when(() => mockClient.get(any())).thenAnswer(
        (_) async => Response(body: '{"id": "1", "name": "Test"}'),
      );
      final user = await repository.getUser('1');
      expect(user.name, 'Test');
      verify(() => mockClient.get(any())).called(1);
    });
  });
}
```

## Reset mock state between tests

`reset(mock)` / `clearInteractions(mock)` / `resetMocktailState()`

- You must default to fresh mock instances in `setUp` instead of resetting mocks in `tearDown`.
- You must use `reset(mock)` only when a mock instance is intentionally reused across tests and full state reset is required.
- You must use `clearInteractions(mock)` only when stubs should remain but interaction history must be cleared.
- You must avoid `resetMocktailState()` for routine test lifecycle management.

```dart
setUp(() {
  mockRepo = MockRepo();
});

test('reused singleton mock requires reset', () {
  reset(sharedMock);
});
```

## Resolve unawaited future warnings in tests

`await` / `unawaited(...)`

When analyzer reports `unawaited_futures`, match the fix to test intent:

- Use `await` when completion is part of ordering/assertion (for example, `expectLater(...)`).
- Use `unawaited(...)` when fire-and-forget is intentional (for example, triggering animation status changes and advancing frames with `pump()`).
- Import `dart:async` when using `unawaited(...)`.

```dart
import 'dart:async';

test('await expectation future', () async {
  final expectation = expectLater(stream, emitsInOrder([1, 2]));
  triggerEvents();
  await expectation;
});

testWidgets('intentional fire-and-forget animation', (tester) async {
  unawaited(controller.forward());
  await tester.pump();
});
```
