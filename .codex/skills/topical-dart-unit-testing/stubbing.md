# Stubbing Methods

Define mock behavior using `when()` with various return strategies.

## Return a synchronous value

`when(() => mock.method()).thenReturn(value)`

Use for methods that return synchronous values directly.

```dart
when(() => mock.getValue()).thenReturn(42);
when(() => mock.currentUser).thenReturn(User(id: '1'));
```

## Return an async value or stream

`when(() => mock.method()).thenAnswer((_) async => value)`

Use for Futures, Streams, or when you need dynamic values.

```dart
when(() => mock.fetchData()).thenAnswer((_) async => Data());

when(() => mock.dataStream).thenAnswer((_) => Stream.value(data));
when(() => mock.updates).thenAnswer((_) => Stream.fromIterable([1, 2, 3]));
```

## Access invocation arguments in stub

`thenAnswer((invocation) => ...)`

Access the invocation object to base the return value on the arguments passed.

```dart
when(() => mock.process(any())).thenAnswer((invocation) {
  final arg = invocation.positionalArguments.first;
  return 'Processed: $arg';
});
```

## Stub different values for specific arguments

`when(() => mock.method(specificArg)).thenAnswer(...)`

Stub different behaviors based on specific argument values.

```dart
when(() => mock.getUser('123')).thenAnswer((_) async => user);
when(() => mock.getUser('456')).thenAnswer((_) async => otherUser);
```

## Throw exceptions from stubs

`when(() => mock.method()).thenThrow(exception)`

Stub methods to throw exceptions for error scenario testing.

```dart
when(() => mock.riskyOperation()).thenThrow(Exception('Failed'));

when(() => mock.asyncOp()).thenAnswer((_) async => throw NetworkError());
```

## Return different values on sequential calls

`responses.removeAt(0)` pattern

For methods that should return different values on each call.

```dart
final responses = ['first', 'second', 'third'];
when(() => mock.nextValue()).thenAnswer((_) => responses.removeAt(0));
```

## Stub generic methods

`when(() => mock.method<Type>(any())).thenReturn(value)`

Must specify type parameter to avoid dynamic inference issues.

```dart
class Cache {
  T? get<T>(String key);
  void set<T>(String key, T value);
}

class MockCache extends Mock implements Cache {}

when(() => mockCache.get<int>(any())).thenReturn(42);
when(() => mockCache.set<String>(any(), any())).thenReturn(null);

when(() => mockCache.set(any(), any<int>())).thenReturn(null);
```
