import 'package:flutter_test/flutter_test.dart';
import 'package:kk_app/services/curriculum.dart';
import 'package:kk_app/services/dialogue_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('80% 경계 — 정답/문제 소수점 버림', () {
    expect(Curriculum.score(8, 10), 80);
    expect(Curriculum.passes(8, 10), isTrue);
    expect(Curriculum.score(23, 29), 79); // 79.3 → 79
    expect(Curriculum.passes(23, 29), isFalse);
    expect(Curriculum.passes(4, 5), isTrue);
    expect(Curriculum.score(0, 0), 0);
  });

  test('간격 반복 1·3·7일 — 맞히면 다음, 틀리면 1일로', () {
    const d = '2026-11-22';
    var r = Curriculum.nextReview('a#1', 0, true, d);
    expect(r['due'], '2026-11-25');
    expect(r['step'], 1);
    r = Curriculum.nextReview('a#1', 1, true, d);
    expect(r['due'], '2026-11-29');
    r = Curriculum.nextReview('a#1', 2, true, d);
    expect(r['due'], '2026-11-29'); // 7일에서 멈춤
    r = Curriculum.nextReview('a#1', 2, false, d);
    expect(r['due'], '2026-11-23');
    expect(r['step'], 0);
    expect(Curriculum.addDays('2026-12-31', 1), '2027-01-01');
  });

  test('시험 통과·불통과와 연속 일수', () async {
    SharedPreferences.setMockInitialValues({});
    final c = Curriculum.instance;
    await c.load();
    c.data = {};
    const t = DialogueTurn(num: 1, speaker: 'A', tl: 'Сәлем', gloss: '', rd: '', ko: '안녕', note: '', tags: [], align: [], lemmas: [], newWords: []);
    final d = Dialogue(id: 'x1', region: 'R1', island: 'life', title: 'x', emoji: '', scene: '', speakers: const {}, genders: const {}, expressions: const [], turns: const [t]);
    c.startCourse(['x1', 'x2'], '2026-11-22');
    c.finishPractice(d, const [], '2026-11-22');
    expect(c.practiced, ['x1']);
    expect(c.newDoneToday('2026-11-22'), 1);
    expect(c.dueReview('2026-11-23'), ['x1#1']);
    expect(c.finishExam(7, 10, ['x2'], '2026-11-22'), isFalse);
    expect(c.course, isNotNull);
    expect(c.finishExam(8, 10, const [], '2026-11-22'), isTrue);
    expect(c.passed.toSet(), {'x1', 'x2'});
    expect(c.course, isNull);
    c.answerReview('x1#1', true, '2026-11-23');
    expect(c.streak, 2);
  });
}
