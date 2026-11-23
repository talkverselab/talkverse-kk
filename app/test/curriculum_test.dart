import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kk_app/core/theme.dart';
import 'package:kk_app/screens/dialogue_screen.dart';
import 'package:kk_app/data/purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kk_app/screens/curriculum_screen.dart';
import 'package:kk_app/services/curriculum_service.dart';
import 'package:kk_app/services/dialogue_service.dart';

Dialogue _d(String id, String island, int n) => Dialogue.fromJson({
      'id': id,
      'region': 'R1',
      'island': island,
      'turns': [
        for (var i = 1; i <= n; i++) {'num': i, 'speaker': i.isOdd ? 'A' : 'B', 'tl': 'Сөз$id$i', 'ko': '뜻$id$i'}
      ],
    });

void main() {
  group('점수 80% 경계', () {
    test('소수점 버림', () {
      expect(scorePercent(7, 9), 77);
      expect(scorePercent(2, 3), 66);
      expect(scorePercent(0, 0), 0);
    });
    test('80% 이상만 통과', () {
      expect(isPass(8, 10), isTrue);
      expect(isPass(79, 100), isFalse);
      expect(isPass(4, 5), isTrue);
      expect(isPass(23, 29), isFalse); // 79.3 → 79
      expect(isPass(24, 30), isTrue);
    });
    test('시험 기록 — 통과면 편 통과, 아니면 틀린 편 연습 다시', () {
      final st = CurriculumState(course: Course('c', ['a', 'b'], practiced: ['a', 'b']));
      expect(st.recordExam(7, 10, {'b'}, '2026-11-22'), isFalse);
      expect(st.course!.practiced, ['a']);
      expect(st.passedDialogues, isEmpty);
      st.course!.practiced.add('b');
      expect(st.recordExam(8, 10, {}, '2026-11-23'), isTrue);
      expect(st.course!.passedAt, '2026-11-23');
      expect(st.passedDialogues, ['a', 'b']);
      expect(st.course!.examScores, [70, 80]);
    });
  });

  group('간격 반복 날짜', () {
    test('1일 → 3일 → 7일 → 졸업', () {
      final st = CurriculumState();
      st.enqueue('x#1', '2026-11-22');
      expect(st.review.single.due, '2026-11-23');
      st.grade('x#1', true, '2026-11-23');
      expect(st.review.single.due, '2026-11-26');
      st.grade('x#1', true, '2026-11-26');
      expect(st.review.single.due, '2026-12-03');
      st.grade('x#1', true, '2026-12-03');
      expect(st.review, isEmpty);
    });
    test('틀리면 1일 뒤 처음 간격으로', () {
      final st = CurriculumState();
      st.enqueue('x#1', '2026-11-22');
      st.grade('x#1', true, '2026-11-23');
      st.grade('x#1', false, '2026-11-26');
      expect(st.review.single.step, 0);
      expect(st.review.single.due, '2026-11-27');
    });
    test('달·해 넘김', () {
      expect(addDays('2026-12-30', 3), '2027-01-02');
      expect(addDays('2028-02-28', 1), '2028-02-29');
    });
  });

  group('하루 분량·연속', () {
    test('새 편 목표를 채우고 복습이 없으면 끝, 연속 일수', () {
      final st = CurriculumState(dailyGoal: 1, course: Course('c', ['a', 'b']));
      expect(st.dayDone('2026-11-22'), isFalse);
      st.markPracticed('a', [1, 2], '2026-11-22');
      expect(st.dayDone('2026-11-22'), isTrue);
      expect(st.streakShown('2026-11-22'), 1);
      // 다음 날: 복습 2줄 + 새 편 1
      expect(st.dueReview('2026-11-23').length, 2);
      st.grade('a#1', true, '2026-11-23');
      st.grade('a#2', true, '2026-11-23');
      st.markPracticed('b', [1], '2026-11-23');
      expect(st.todayReview, 2);
      expect(st.streakShown('2026-11-23'), 2);
      expect(st.streakShown('2026-11-25'), 0);
    });
    test('저장 형식 왕복', () {
      final st = CurriculumState(level: 'R1', course: Course('c', ['a']));
      st.markPracticed('a', [1], '2026-11-22');
      final back = CurriculumState.fromJson(st.toJson());
      expect(back.toJson(), st.toJson());
      expect(st.toJson().keys, containsAll(['level', 'dailyGoal', 'course', 'passedDialogues', 'review', 'streak']));
    });
  });

  group('문제·추천', () {
    test('편마다 줄 수만큼, 최대 10, 보기 4개 중 정답 1', () {
      final a = _d('a', 'friends', 12), b = _d('b', 'life', 4);
      final qs = buildQuestions(a, limit: 10, pool: [b]);
      expect(qs.length, 10);
      for (final q in qs) {
        expect(q.choices.length, 4);
        expect(q.choices.toSet().length, 4);
        expect(q.choices[q.answer], '뜻a${q.turn}');
      }
      expect(buildQuestions(b, limit: 10, pool: [a]).length, 4);
    });
    test('시험 문제 수: 편당 최소 3, 전체 최대 30', () {
      expect(examPerDialogue(3), 10);
      expect(examPerDialogue(5), 6);
      expect(examPerDialogue(10), 3);
    });
    test('추천 = 안 한 편, 주제 겹치지 않게', () {
      final list = [_d('f1', 'friends', 2), _d('f2', 'friends', 2), _d('l1', 'life', 2), _d('w1', 'work', 2)];
      final r = recommend(list, {'l1'}, {}, 3);
      expect(r, ['f1', 'w1', 'f2']);
    });
  });

  testWidgets('시험 화면 — 고르고 결과까지', (t) async {
    final a = _d('a', 'friends', 5);
    final qs = buildQuestions(a, limit: 2);
    await t.pumpWidget(MaterialApp(home: CurriculumQuizScreen(title: 'T', questions: qs, mode: QuizMode.exam)));
    for (var i = 0; i < 2; i++) {
      await t.tap(find.text(qs[i].choices[qs[i].answer]));
      await t.pump();
      await t.tap(find.byType(FilledButton).last);
      await t.pump();
    }
    expect(find.textContaining('100'), findsOneWidget);
  });

  testWidgets('커리큘럼 화면: 레벨 → 추천으로 채우기, 좁은 칸(300)·폰 폭에서도 넘치지 않음', (t) async {
    SharedPreferences.setMockInitialValues({});
    t.view.devicePixelRatio = 1;
    t.view.physicalSize = const Size(300, 900);
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const CurriculumScreen()));
    for (var i = 0; i < 8; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await t.pump();
    }
    expect(find.text('단계를 골라요'), findsOneWidget);
    await t.tap(find.text('1단계'));
    for (var i = 0; i < 3; i++) {
      await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await t.pump();
    }
    await t.tap(find.text('추천으로 채우기'));
    await t.pump();
    expect(find.text('5/5편으로 코스 시작'), findsOneWidget);
    for (final w in [300.0, 390.0, 744.0]) {
      t.view.physicalSize = Size(w, 900);
      await t.pump();
      expect(t.takeException(), isNull);
    }
  });

  test('§12 단계 — JSON 대로, 앱에 없는 편은 건너뛰고 빈 단계는 숨김, 실패하면 회화 레벨 기본 대응', () async {
    SharedPreferences.setMockInitialValues({});
    final svc = CurriculumService.instance;
    await svc.ensureLoaded();
    final ids = DialogueService.instance.list().map((d) => d.id).toList();
    expect(ids, isNotEmpty);
    svc.setStages({
      'rev': 9,
      'stages': [
        {'n': 1, 'title': '첫걸음', 'dialogueIds': [ids[0], 'none_x']},
        {'n': 2, 'title': '빈 단계', 'dialogueIds': <String>[]},
        {'n': 3, 'title': '셋', 'dialogueIds': [ids[1], ids[2]]},
      ],
    });
    expect(svc.levels, ['1', '3']);
    expect(svc.title('1'), '첫걸음');
    expect(svc.levelList('1').map((d) => d.id), [ids[0]]);
    expect(svc.nextLevel('1'), '3');
    expect(svc.stageOf(ids[2]), '3');
    svc.setStages(null); // 실패 → R0+R1→1, R2→2, R3→3
    expect(svc.levels, containsAllInOrder(['1', '2']));
    expect(CurriculumService.stageOfRegion('R1'), '1');
    expect(CurriculumService.stageOfRegion('R3'), '3');
  });

  test('§12 덧붙임 — 단계 JSON 의 pick·pass·daily·desc 를 쓰고, 없으면 3·5·10 / 80 / 1·2·3', () async {
    SharedPreferences.setMockInitialValues({});
    final svc = CurriculumService.instance;
    await svc.ensureLoaded();
    final ids = DialogueService.instance.list().map((d) => d.id).toList();
    svc.setStages({
      'stages': [
        {'n': 1, 'title': '첫걸음', 'desc': '인사부터', 'dialogueIds': [ids[0], ids[1]], 'pick': [2, 4], 'pass': 70, 'daily': {'light': 1, 'normal': 3, 'focus': 5}},
        {'n': 2, 'dialogueIds': [ids[2]]},
      ],
    });
    svc.state.level = '1';
    svc.state.dailyGoal = 2;
    svc.applyStage();
    expect(svc.pickFor('1'), [2, 4]);
    expect(svc.desc('1'), '인사부터');
    expect(svc.state.passPercent, 70);
    expect(svc.state.dailyNew, 3);
    svc.state.course = Course('c', [ids[0]]);
    expect(svc.state.recordExam(7, 10, {}, '2026-11-23'), isTrue); // 70점 통과
    svc.state.level = '2';
    svc.applyStage();
    expect(svc.pickFor('2'), [3, 5, 10]);
    expect(svc.state.passPercent, 80);
    expect(svc.state.dailyNew, 2);
  });

  test('이용권 잠금 경계 — 1단계 열림·2단계 잠김·이용권 있으면 열림(PAYWALL_SPEC §5)', () async {
    SharedPreferences.setMockInitialValues({});
    final svc = CurriculumService.instance;
    await svc.ensureLoaded();
    final ids = DialogueService.instance.list().map((d) => d.id).toList();
    Purchase.owned.value = const {};
    svc.setStages({
      'freeSenseLevels': 1,
      'stages': [
        {'n': 1, 'free': true, 'dialogueIds': [ids[0]]},
        {'n': 2, 'free': false, 'dialogueIds': [ids[1]]},
        {'n': 3, 'dialogueIds': [ids[2]]}, // free 없음 → 1단계만 무료
      ],
    });
    expect(svc.stageLocked('1'), isFalse);
    expect(svc.stageLocked('2'), isTrue);
    expect(svc.stageLocked('3'), isTrue);
    expect(dialogueLevelLocked('R1'), isFalse);
    expect(dialogueLevelLocked('R2'), isTrue);
    final far = DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch;
    Purchase.owned.value = {'lang_kk_1y': far};
    expect(svc.stageLocked('2'), isFalse);
    expect(dialogueLevelLocked('R3'), isFalse);
    Purchase.owned.value = {'all_life': 0}; // 종합 평생
    expect(svc.stageLocked('3'), isFalse);
    Purchase.owned.value = {'lang_mn_1y': far}; // 다른 언어 이용권은 안 됨
    expect(svc.stageLocked('2'), isTrue);
    Purchase.owned.value = const {};
  });
}
