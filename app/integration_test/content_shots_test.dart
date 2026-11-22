// 콘텐츠 채운 뒤 화면 확인(2026-11-22): 홈 → 회화 목록·한 편 → 접사 → 동사 → 주제 단어 → 표현.
// 실행: python3 tools/pane_shots.py <아이패드 UDID> <출력폴더> integration_test/content_shots_test.dart
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

  Future<void> open(WidgetTester t, String label, String name) async {
    await t.tap(rail('홈'));
    await wait(t, 1000);
    final f = find.text(label).first;
    await t.ensureVisible(f);
    await wait(t, 500);
    await t.tap(f);
    await wait(t, 2500);
    await shot(t, name);
  }

  testWidgets('content shots', timeout: const Timeout(Duration(minutes: 10)), (t) async {
    appDb = AppDatabase();
    await SeedLoader(appDb).seedIfNeeded();
    await KoReadingPrefs.load();
    await AppLangPrefs.load();
    await LearnerPrefs.load();
    await AchievementService.instance.load();
    await t.pumpWidget(const GermanUniverseApp());
    await wait(t, 2000);
    await shot(t, 'c01_home');
    await open(t, 'Диалог', 'c02_dialogue_home');
    if (find.text('읽기 시작').evaluate().isNotEmpty) {
      await t.tap(find.text('읽기 시작').first);
      await wait(t, 3000);
      await shot(t, 'c03_dialogue_play');
      await t.pageBack();
      await wait(t, 1200);
    }
    await open(t, 'Жалғау', 'c04_affix');
    await open(t, 'Етістік', 'c05_verbs');
    await open(t, 'Сөз', 'c06_topic_words');
    await open(t, 'Тіркес', 'c07_expressions');
    await open(t, 'R1~R5', 'c08_cliff_words');
    await open(t, 'Грамматика', 'c09_sense_course');
    await t.tap(find.textContaining('어디로').first);
    await wait(t, 3000);
    await shot(t, 'c10_sense_lesson');
  });
}
