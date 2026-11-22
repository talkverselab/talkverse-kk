import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/embed_env.dart';
import 'dialogue_service.dart';

/// 토크버스 커리큘럼 — 전 언어 공통 기준 `~/talkverse/CURRICULUM_SPEC.md`(2026-11-22).
/// 저장 키 이름 `curriculum_v1`(통합 앱에서는 언어 접두가 붙어 `kk_curriculum_v1` — 언어마다 진도가 따로).
/// 형식: {level, dailyGoal, course:{id, dialogueIds[], practiced[], examScores[], passedAt}, passedDialogues[], review:[{lineId, due, step}], streak:{count, lastDay}, today:{day, newDone, reviewDone}}
class Curriculum {
  Curriculum._();
  static final Curriculum instance = Curriculum._();
  static final String key = pk('curriculum_v1');

  /// 간격 반복 — 1일 → 3일 → 7일, 맞히면 다음 간격, 틀리면 1일로.
  static const intervals = [1, 3, 7];
  static const passRate = 80;
  static const goals = {'light': 1, 'normal': 2, 'focus': 3};

  Map<String, dynamic> data = {};

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    try {
      data = json.decode(p.getString(key) ?? '{}') as Map<String, dynamic>;
    } catch (_) {
      data = {};
    }
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, json.encode(data));
  }

  // ── 값 ─────────────────────────────────────
  String? get level => data['level'] as String?;
  set level(String? v) => data['level'] = v;
  String get dailyGoal => (data['dailyGoal'] as String?) ?? 'normal';
  set dailyGoal(String v) => data['dailyGoal'] = v;
  Map<String, dynamic>? get course => data['course'] as Map<String, dynamic>?;
  List<String> get passed => [...((data['passedDialogues'] as List?) ?? const []).cast<String>()];
  List<Map<String, dynamic>> get review => [...((data['review'] as List?) ?? const []).cast<Map<String, dynamic>>()];
  int get streak => ((data['streak'] as Map?)?['count'] as int?) ?? 0;

  List<String> get courseIds => [...((course?['dialogueIds'] as List?) ?? const []).cast<String>()];
  List<String> get practiced => [...((course?['practiced'] as List?) ?? const []).cast<String>()];
  bool get allPracticed => course != null && courseIds.every(practiced.contains);

  // ── 날짜 ───────────────────────────────────
  static String day(DateTime t) => '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
  static String addDays(String d, int n) => day(DateTime.parse(d).add(Duration(days: n)));

  // ── 채점 ───────────────────────────────────
  /// 정답 수 / 문제 수, 소수점 버림.
  static int score(int right, int total) => total == 0 ? 0 : (right * 100) ~/ total;
  static bool passes(int right, int total) => score(right, total) >= passRate;

  // ── 복습 ───────────────────────────────────
  /// 한 줄의 다음 상태 — 맞히면 다음 간격, 틀리면 1일로.
  static Map<String, dynamic> nextReview(String lineId, int step, bool correct, String today) {
    final s = correct ? min(step + 1, intervals.length - 1) : 0;
    final gap = correct ? intervals[s] : intervals[0];
    return {'lineId': lineId, 'step': s, 'due': addDays(today, gap)};
  }

  void _putReview(Map<String, dynamic> r) {
    final list = review..removeWhere((e) => e['lineId'] == r['lineId']);
    list.add(r);
    data['review'] = list;
  }

  /// 연습한 편의 줄은 복습 대기열에 넣는다(이미 있으면 그대로).
  void enqueueLines(Iterable<String> lineIds, String today) {
    final have = review.map((e) => e['lineId']).toSet();
    for (final id in lineIds) {
      if (!have.contains(id)) _putReview({'lineId': id, 'step': 0, 'due': addDays(today, intervals[0])});
    }
  }

  void answerReview(String lineId, bool correct, String today) {
    final cur = review.where((e) => e['lineId'] == lineId).firstOrNull;
    _putReview(nextReview(lineId, (cur?['step'] as int?) ?? 0, correct, today));
    if (cur != null && (cur['due'] as String).compareTo(today) <= 0) _bump('reviewDone', today);
  }

  List<String> dueReview(String today) =>
      [for (final r in review) if ((r['due'] as String).compareTo(today) <= 0) r['lineId'] as String];

  // ── 오늘 분량 · 연속 일수 ──────────────────
  Map<String, dynamic> _today(String today) {
    final t = (data['today'] as Map?)?.cast<String, dynamic>();
    if (t == null || t['day'] != today) return {'day': today, 'newDone': 0, 'reviewDone': 0};
    return t;
  }

  void _bump(String k, String today) {
    final t = _today(today);
    t[k] = (t[k] as int) + 1;
    data['today'] = t;
    _touchStreak(today);
  }

  void _touchStreak(String today) {
    final s = (data['streak'] as Map?)?.cast<String, dynamic>() ?? {'count': 0, 'lastDay': ''};
    if (s['lastDay'] == today) return;
    final yesterday = addDays(today, -1);
    s['count'] = s['lastDay'] == yesterday ? (s['count'] as int) + 1 : 1;
    s['lastDay'] = today;
    data['streak'] = s;
  }

  int newGoal() => goals[dailyGoal] ?? 2;
  int newDoneToday(String today) => _today(today)['newDone'] as int;
  int reviewDoneToday(String today) => _today(today)['reviewDone'] as int;
  int newLeftToday(String today) => max(0, newGoal() - newDoneToday(today));
  bool todayDone(String today) => newLeftToday(today) == 0 && dueReview(today).isEmpty;

  // ── 코스 ───────────────────────────────────
  void startCourse(List<String> ids, String today) {
    data['course'] = {
      'id': 'c$today-${ids.length}-${DateTime.now().millisecondsSinceEpoch % 100000}',
      'dialogueIds': ids,
      'practiced': <String>[],
      'examScores': <int>[],
      'passedAt': null,
    };
  }

  /// 편 하나의 연습(듣기 + 확인 문제)이 끝남. wrong = 틀린 줄 id.
  void finishPractice(Dialogue d, List<String> wrong, String today) {
    final c = course;
    if (c == null) return;
    final pr = practiced;
    if (!pr.contains(d.id)) {
      pr.add(d.id);
      _bump('newDone', today);
    }
    c['practiced'] = pr;
    enqueueLines(lineIdsOf(d), today);
    for (final w in wrong) {
      _putReview({'lineId': w, 'step': 0, 'due': addDays(today, intervals[0])});
    }
  }

  /// 코스 시험 결과. 통과하면 코스 편을 통과 목록에 넣고 코스를 닫는다.
  bool finishExam(int right, int total, List<String> wrongDialogues, String today) {
    final c = course;
    if (c == null) return false;
    final sc = score(right, total);
    c['examScores'] = [...((c['examScores'] as List?) ?? const []).cast<int>(), sc];
    if (sc >= passRate) {
      c['passedAt'] = today;
      data['passedDialogues'] = {...passed, ...courseIds}.toList();
      data['course'] = null;
      return true;
    }
    // 80% 미만 = 틀린 편만 다시 연습
    c['practiced'] = practiced.where((id) => !wrongDialogues.contains(id)).toList();
    return false;
  }

  /// 그 레벨 편을 모두 통과했는가 — 다음 레벨을 연다.
  bool levelCleared(String region, DialogueService svc) {
    final ids = svc.list(region: region).map((d) => d.id);
    return ids.isNotEmpty && ids.every(passed.contains);
  }

  /// 열린 레벨 = 첫 레벨 + 앞 레벨을 다 통과한 레벨.
  List<String> openLevels(DialogueService svc) {
    final out = <String>[];
    for (final r in svc.regions) {
      out.add(r);
      if (!levelCleared(r, svc)) break;
    }
    return out;
  }

  /// 「추천으로 채우기」 — 안 한 편에서 주제(섬)가 겹치지 않게.
  static List<String> recommend(List<Dialogue> pool, Set<String> passed, int n, {Set<String> already = const {}}) {
    final picked = [...already];
    final fresh = pool.where((d) => !passed.contains(d.id) && !already.contains(d.id)).toList();
    final usedIsland = pool.where((d) => already.contains(d.id)).map((d) => d.island).toSet();
    for (final d in fresh) {
      if (picked.length >= n) break;
      if (usedIsland.add(d.island)) picked.add(d.id);
    }
    for (final d in fresh) {
      if (picked.length >= n) break;
      if (!picked.contains(d.id)) picked.add(d.id);
    }
    for (final d in pool) {
      if (picked.length >= n) break;
      if (!picked.contains(d.id)) picked.add(d.id);
    }
    return picked;
  }

  // ── 문제 ───────────────────────────────────
  static String lineId(Dialogue d, DialogueTurn t) => '${d.id}#${t.num}';
  static bool _speakable(DialogueTurn t) => t.ko.trim().isNotEmpty && RegExp(r'\p{L}', unicode: true).hasMatch(t.tl);
  static List<String> lineIdsOf(Dialogue d) => [for (final t in d.turns) if (_speakable(t)) lineId(d, t)];

  /// 뜻 고르기(4지선다) — 카자흐어 줄을 보고 한국어 뜻을 고른다. 오답은 같은 편·다른 편의 다른 줄 뜻.
  static List<Question> questionsFor(Dialogue d, List<Dialogue> others, {int max = 10, Random? rnd}) {
    final r = rnd ?? Random();
    final turns = d.turns.where(_speakable).toList()..shuffle(r);
    final poolKo = <String>{
      for (final t in d.turns) if (_speakable(t)) t.ko.trim(),
      for (final o in others) for (final t in o.turns) if (_speakable(t)) t.ko.trim(),
    };
    return [
      for (final t in turns.take(max))
        if (poolKo.length >= 4) Question.meaning(d, t, poolKo.where((k) => k != t.ko.trim()).toList()..shuffle(r), r),
    ];
  }

  static DialogueTurn? turnOf(String lineId, DialogueService svc) {
    final i = lineId.lastIndexOf('#');
    if (i < 0) return null;
    final d = svc.byId(lineId.substring(0, i));
    final n = int.tryParse(lineId.substring(i + 1));
    return d?.turns.where((t) => t.num == n).firstOrNull;
  }
}

class Question {
  final String dialogueId;
  final String lineId;
  final String prompt; // 카자흐어 줄
  final String rd;
  final List<String> choices;
  final int answer;
  const Question(this.dialogueId, this.lineId, this.prompt, this.rd, this.choices, this.answer);

  factory Question.meaning(Dialogue d, DialogueTurn t, List<String> wrongs, Random r) {
    final ch = [t.ko.trim(), ...wrongs.take(3)]..shuffle(r);
    return Question(d.id, Curriculum.lineId(d, t), t.tl.replaceAll(RegExp(r'\{name\}'), '…'), t.rd, ch, ch.indexOf(t.ko.trim()));
  }
}
