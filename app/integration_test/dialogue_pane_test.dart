// 아이패드 두 화면 + 만화책 읽기형 회화 확인용 스크린샷 흐름 — 2026-11-03(일본어앱·인도네시아어앱 dialogue_pane_test 를 옮김).
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/dialogue_pane_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kk_app/core/l10n.dart';
import 'package:kk_app/data/db/app_database.dart';
import 'package:kk_app/data/db/seed_loader.dart';
import 'package:kk_app/main.dart';
import 'package:kk_app/services/achievement_service.dart';
import 'package:kk_app/services/ko_reading.dart';
import 'package:kk_app/services/learner_prefs.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;

  Future<void> wait(WidgetTester t, int ms) async {
    final end = DateTime.now().add(Duration(milliseconds: ms));
    while (DateTime.now().isBefore(end)) {
      await t.pump(const Duration(milliseconds: 100));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> shot(WidgetTester t, String name) async {
    await wait(t, 2000);
    // ignore: avoid_print
    print('SHOT:$name');
    await wait(t, 3000);
  }

  Finder rail(String label) => find.descendant(of: find.byType(NavigationRail), matching: find.text(label));

  testWidgets('dialogue pane', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    // main() 과 같은 시작 순서
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await LearnerPrefs.load();
    await AchievementService.instance.load();
    await t.pumpWidget(const GermanUniverseApp());
    await wait(t, 1500);
    await shot(t, '01_home_wide');

    await t.tap(find.text('회화').at(1));
    await wait(t, 2500);
    await shot(t, '02_dialogue_home_right');

    // 초기 빌드(2026-11-08): 회화·접사·동사 콘텐츠가 없어 빈 화면만 찍는다.
    await t.tap(rail('홈'));
    await wait(t, 1000);
    await t.tap(find.text('접사').first);
    await wait(t, 2000);
    await shot(t, '10_affix_dictionary_empty');
    await t.pageBack();
    await wait(t, 1200);

    await t.tap(rail('홈'));
    await wait(t, 800);
    await t.ensureVisible(find.text('절벽 단어').first);
    await wait(t, 500);
    await shot(t, '15_home_sections');
    await t.tap(find.text('절벽 단어').first);
    await wait(t, 2500);
    await shot(t, '16_cliff_words');

    await t.tap(find.text('앱 소개').first);
    await wait(t, 1500);
    await shot(t, '17_about');

    await t.tap(rail('진행'));
    await wait(t, 1500);
    await shot(t, '08_progress_achievements');

    await t.tap(rail('프로필'));
    await wait(t, 1500);
    await shot(t, '09_profile');
  });
}
