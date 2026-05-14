# Argument Matchers and Verification

Match arguments flexibly and verify mock interactions.

## Match any argument value

`any()` / `any(named: 'param')`

Match any value for positional or named arguments.

```dart
when(() => mock.save(any())).thenReturn(true);

when(() => mock.fetch(id: any(named: 'id'))).thenAnswer((_) async => data);

when(() => mock.update(any(), status: any(named: 'status'))).thenReturn(true);
```

## Match arguments with custom conditions

`any(that: matcher)`

Use a Matcher to constrain what values are accepted.

```dart
when(() => mock.search(any(that: startsWith('test')))).thenReturn([]);
when(() => mock.process(any(that: isA<User>()))).thenReturn(true);
```

## Register custom types for any() matcher

`registerFallbackValue(instance)`

Required for custom types used with `any()` or `captureAny()`. Register in `setUpAll()`.

```dart
class FakeUser extends Fake implements User {}
class FakeRequest extends Fake implements Request {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUser());
    registerFallbackValue(FakeRequest());
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  test('uses any matcher with custom type', () {
    final mock = MockRepository();
    when(() => mock.saveUser(any())).thenAnswer((_) async => true);
  });
}
```

## Verify a method was called N times

`verify(() => mock.method()).called(n)`

Check exact call count or use matchers for flexible verification.

```dart
verify(() => mock.save(any())).called(1);
verify(() => mock.save(any())).called(greaterThan(0));
verify(() => mock.save(any())).called(lessThanOrEqualTo(3));
```

## Verify a method was never called

`verifyNever(() => mock.method())`

Assert that a method was not invoked at all.

```dart
verifyNever(() => mock.delete(any()));
```

## Verify methods were called in order

`verifyInOrder([...])`

Assert that multiple methods were called in a specific sequence.

```dart
verifyInOrder([
  () => mock.init(),
  () => mock.load(),
  () => mock.process(any()),
  () => mock.complete(),
]);
```

## Verify no interactions occurred

`verifyZeroInteractions(mock)` / `verifyNoMoreInteractions(mock)`

Check for no calls at all, or no unverified calls.

```dart
verifyZeroInteractions(mock);

verify(() => mock.method1()).called(1);
verify(() => mock.method2()).called(1);
verifyNoMoreInteractions(mock);
```

## Capture arguments passed to a method

`captureAny()` / `captureAny(named: 'param')`

Capture actual argument values for assertions.

```dart
when(() => mock.save(any())).thenReturn(true);
mock.save('test');

final captured = verify(() => mock.save(captureAny())).captured;
expect(captured.last, ['test']);
```

## Capture only matching arguments

`captureAny(that: matcher)`

Capture arguments that match a condition.

```dart
mock.save('dog');
mock.save('cat');
mock.save('dolphin');

final captured = verify(() => mock.save(captureAny(that: startsWith('d')))).captured;
expect(captured.last, ['dog', 'dolphin']);
```

## Capture and inspect complex arguments

`verification.captured` array

Access captured values for detailed assertions.

```dart
when(() => mockClient.post(any(), body: any(named: 'body')))
    .thenAnswer((_) async => Response(statusCode: 200));

await service.createUser(User(name: 'John', email: 'john@test.com'));

final verification = verify(
  () => mockClient.post(
    captureAny(),
    body: captureAny(named: 'body'),
  ),
);

verification.called(1);

final capturedUrl = verification.captured[0] as Uri;
final capturedBody = verification.captured[1] as Map<String, dynamic>;

expect(capturedUrl.path, '/users');
expect(capturedBody['name'], 'John');
expect(capturedBody['email'], 'john@test.com');
```

## Create custom matchers

`extends Matcher`

Build reusable matchers for complex argument validation.

```dart
class IsValidUser extends Matcher {
  final String expectedName;
  IsValidUser(this.expectedName);

  @override
  bool matches(item, Map matchState) {
    return item is User && item.name == expectedName;
  }

  @override
  Description describe(Description description) =>
      description.add('User with name $expectedName');
}

verify(() => mock.save(any(that: IsValidUser('John')))).called(1);
```
