import 'package:mvvm_app_state/mvvm_app_state.dart';

final class BookingsViewModel {
  final bookings = AppLoadController<List<String>>(
    reportFailure: noopAppFailureReporter,
  );
  final save = AppActionController<void>(reportFailure: noopAppFailureReporter);

  Future<void> load() {
    return bookings.run(() async {
      return const AppResult.success(['Studio room', 'Lighting kit']);
    });
  }

  Future<void> saveBooking() {
    return save.run(
      () async => const AppResult.success(null),
      successMessage: (_) => const UiMessage.success('Booking saved.'),
    );
  }

  void dispose() {
    bookings.dispose();
    save.dispose();
  }
}
