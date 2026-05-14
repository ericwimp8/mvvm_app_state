# Async Testing Patterns

Test Futures, Streams, and time-dependent operations.

You must keep async tests deterministic and comment-free.

## Test stream emissions in order

`expectLater(..., emitsInOrder([...]))`

Set up expectation BEFORE triggering the stream.

```dart
test('stream emits values in order', () {
  when(() => mock.dataStream).thenAnswer(
    (_) => Stream.fromIterable([1, 2, 3]),
  );

  expectLater(
    mock.dataStream,
    emitsInOrder([1, 2, 3, emitsDone]),
  );
});
```

## Test state notifier emissions

`expectLater(controller.stream, emitsInOrder([...]))`

Must set up `expectLater` BEFORE calling the method that triggers emissions.

```dart
test('StateNotifier emits states', () {
  final controller = MyController(mockRepo: mockRepo);

  expectLater(
    controller.stream,
    emitsInOrder([
      const AsyncLoading(),
      isA<AsyncData>(),
    ]),
  );

  controller.loadData();
});
```

## Test Future completion

`expectLater(..., completion(value))`

Assert that a Future completes with a specific value.

```dart
test('completes successfully', () async {
  when(() => mock.fetchData()).thenAnswer((_) async => 'result');

  await expectLater(
    mock.fetchData(),
    completion('result'),
  );
});
```

## Test Future throws exception

`expectLater(..., throwsA(isA<Type>()))`

Assert that a Future throws a specific exception type.

```dart
test('throws exception', () async {
  when(() => mock.fetchData()).thenAnswer(
    (_) async => throw NetworkException(),
  );

  await expectLater(
    mock.fetchData(),
    throwsA(isA<NetworkException>()),
  );
});
```

## Test synchronous exception throwing

`expect(() => ..., throwsA(...))`

Use synchronous expect for non-async code that throws.

```dart
test('throws on error', () async {
  when(() => mockClient.get(any())).thenThrow(NetworkException());

  expect(
    () => repository.getUser('1'),
    throwsA(isA<NetworkException>()),
  );
});
```

## Test debounced or delayed operations

`wait: Duration` in blocTest

Wait for debounce timers to complete before checking expectations.

```dart
blocTest<SearchCubit, SearchState>(
  'debounces search input',
  build: () => SearchCubit(repository: mockRepo),
  act: (cubit) => cubit.search('test'),
  wait: const Duration(milliseconds: 500),
  expect: () => [isA<SearchLoaded>()],
);
```

## Test retry behavior

`callCount` pattern with conditional throwing

Track call count to throw on initial calls, succeed on retry.

```dart
test('retries on transient failure', () async {
  var callCount = 0;
  when(() => mock.fetch()).thenAnswer((_) async {
    callCount++;
    if (callCount < 3) throw TransientError();
    return 'success';
  });

  final result = await service.fetchWithRetry();

  expect(result, 'success');
  verify(() => mock.fetch()).called(3);
});
```

## Test permanent failure propagation

`throwsA(isA<ErrorType>())`

Verify that permanent errors are not retried and propagate correctly.

```dart
test('propagates permanent failure', () async {
  when(() => mock.fetch()).thenThrow(PermanentError());

  expect(
    () => service.fetchWithRetry(),
    throwsA(isA<PermanentError>()),
  );
});
```
