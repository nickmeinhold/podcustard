import 'package:flutter_test/flutter_test.dart';
import 'package:redux/redux.dart';
import 'package:podcustard/redux/app_reducer.dart';
import 'package:podcustard/redux/app_state.dart';
import 'package:podcustard/redux/middleware.dart';
import 'package:podcustard/services/auth_service.dart';
import 'package:podcustard/widgets/app.dart';

import '../mocks/mock_firebase_auth.dart';

void main() {
  testWidgets('RideCompareApp widget observes auth state on load and navigates',
      (WidgetTester tester) async {
    final fakeFirebaseAuth = Mocks.fakeFirebaseAuthOpen();
    // create a basic store with middleware that uses the AuthService to
    // observe auth state and a reducer that saves the emitted auth state
    final store = Store<AppState>(
      appReducer,
      initialState: AppState.init(),
      middleware: [
        ...createMiddleware(
          AuthService(fakeFirebaseAuth),
        ),
      ],
    );

    fakeFirebaseAuth.add(FakeFirebaseUserNull());

    // build our app and trigger a frame
    await tester.pumpWidget(RideCompareApp(store));

    // Create the Finders.
    final authPageFinder = find.text('Auth Page');
    final mainPageFinder = find.text('Main Page');

    // Use the `findsOneWidget` matcher to verify that a Text widget with the
    // expected String appears exactly once in the widget tree, indicating the
    // AuthPage widget is present, so the expected navigation has occured
    expect(authPageFinder, findsOneWidget);
    expect(mainPageFinder, findsNothing);

    // add a FirebaseUser
    fakeFirebaseAuth.add(FakeFirebaseUserBlah());

    await tester.pump();

    // Check that the Main Page is now shown
    expect(mainPageFinder, findsOneWidget);
    expect(authPageFinder, findsNothing);
  });
}