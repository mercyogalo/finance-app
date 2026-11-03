import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hifadhi/app.dart';
import 'package:hifadhi/core/constants/strings.dart';
import 'package:hifadhi/core/network/api_exception.dart';
import 'package:hifadhi/core/theme/app_theme.dart';
import 'package:hifadhi/core/widgets/goal_card.dart';
import 'package:hifadhi/core/widgets/primary_button.dart';
import 'package:hifadhi/core/widgets/status_chip.dart';
import 'package:hifadhi/features/shell/data/shell_repository.dart';
import 'package:hifadhi/features/shell/domain/shell_repository.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('primary button calls onPressed and ignores taps while loading', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Column(
            children: [
              PrimaryButton(label: 'Save', onPressed: () => taps += 1),
              const PrimaryButton(
                label: 'Wait',
                onPressed: null,
                isLoading: true,
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(taps, 1);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('goal card and status chip render their labels', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: const Scaffold(
          body: Column(
            children: [
              GoalCard(
                name: 'School fees',
                savedMinor: 125000,
                targetMinor: 1000000,
                progress: 0.125,
              ),
              StatusChip(label: 'On track', tone: StatusTone.onTrack),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('School fees'), findsOneWidget);
    expect(find.text('KES 1,250.00'), findsOneWidget);
    expect(find.text('of KES 10,000.00'), findsOneWidget);
    expect(find.text('On track'), findsOneWidget);
  });

  testWidgets('shell shows the app name when the repository is ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shellRepositoryProvider.overrideWithValue(
            const MockShellRepository(),
          ),
        ],
        child: const HifadhiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.appTagline), findsOneWidget);
  });

  testWidgets('shell shows an empty state when nothing is ready', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shellRepositoryProvider.overrideWithValue(
            const MockShellRepository(ready: false),
          ),
        ],
        child: const HifadhiApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.shellEmptyTitle), findsOneWidget);
  });

  testWidgets('shell shows an error and retries', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          shellRepositoryProvider.overrideWithValue(
            _FlakyRepository(onLoad: () => calls += 1),
          ),
        ],
        child: const HifadhiApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.somethingWentWrong), findsOneWidget);

    await tester.tap(find.text(AppStrings.retry));
    await tester.pumpAndSettle();

    expect(calls, 2);
    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}

class _FlakyRepository implements ShellRepository {
  _FlakyRepository({required this.onLoad});

  final void Function() onLoad;
  var _failed = false;

  @override
  Future<bool> load() async {
    onLoad();
    if (!_failed) {
      _failed = true;
      throw const ApiException(code: 'DOWN', message: 'down');
    }
    return true;
  }
}
