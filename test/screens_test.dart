import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cando_mobprog/screens/login_screen.dart';
import 'package:cando_mobprog/screens/splash_screen.dart';
import 'package:cando_mobprog/screens/settings_screen.dart';
import 'package:cando_mobprog/widgets/like_button.dart';
import 'package:cando_mobprog/services/preferences_service.dart';
import 'package:cando_mobprog/screens/detail_screen.dart';
import 'package:cando_mobprog/widgets/post_card.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'notification details retain asset images and local like toggle',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DetailScreen(
            userName: 'Michael Scott',
            postContent: 'An update',
            date: 'December 17',
            numOfLikes: 5,
            profileImageUrl: 'michael.jpg',
            imageUrl: 'michaelnotif.jpg',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('An update'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(
        images.map((image) => (image.image as AssetImage).assetName),
        containsAll([
          'assets/images/michael.jpg',
          'assets/images/michaelnotif.jpg',
        ]),
      );
      await tester.ensureVisible(find.text('5'));
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      expect(find.text('6'), findsOneWidget);
      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('promotion card opens the shared detail screen', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PostCard(
            userName: 'Promotion',
            postContent: 'Special offer',
            adsMarket: 'More details',
            date: 'October 11',
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('More details'));
    await tester.pumpAndSettle();
    expect(find.byType(DetailScreen), findsOneWidget);
    expect(find.text('Special offer'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 568), const Size(1280, 800)]) {
    testWidgets('login validates empty fields and fits $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialApp(home: LogInScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Sign In'));
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your username'), findsOneWidget);
      expect(find.text('Enter your password'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('splash routes to login when there is no saved session', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(LogInScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('two views of a post share one toggled like count', (
    tester,
  ) async {
    await PreferencesService.instance.loadLikes(1);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              LikeButton(reactionKey: 'post.8', initialLikes: 4),
              LikeButton(reactionKey: 'post.8', initialLikes: 4),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('4').first);
    await tester.pumpAndSettle();
    expect(find.text('5'), findsNWidgets(2));
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();
    expect(find.text('4'), findsNWidgets(2));
  });

  testWidgets('settings fits narrow viewport and saves dark preference', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MaterialApp(home: SettingsScreen()));
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(
      (await SharedPreferences.getInstance()).getString('themeMode'),
      'dark',
    );
    expect(tester.takeException(), isNull);
  });
}
