import 'dart:math';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/pane.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/curriculum.dart';
import '../services/dialogue_service.dart';
import 'dialogue_screen.dart';

/// 토크버스 커리큘럼 — 기준 `~/talkverse/CURRICULUM_SPEC.md`(2026-11-22, 전 언어 공통).
/// 회화 레벨에서 편을 3·5·10 골라 코스 → 편마다 듣기 + 확인 문제 → 간격 반복 복습 → 코스 시험 80% 이상이면 다음 코스.
class CurriculumScreen extends StatefulWidget {
  const CurriculumScreen({super.key});
  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  final cur = Curriculum.instance;
  final svc = DialogueService.instance;
  bool _loading = true;
  bool _askNew = false; // 새 코스 시작 확인(화면 안)
  int _size = 5;
  final Set<String> _pick = {};

  String get today => Curriculum.day(DateTime.now());

  @override
  void initState() {
    super.initState();
    Future.wait([cur.load(), svc.ensureLoaded()]).then((_) {
      if (mounted) setState(() => _loading = false);
    });
  }

  Future<void> _save() async {
    await cur.save();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(tr('토크버스 커리큘럼'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context)),
              children: cur.level == null ? _levelPicker() : _main(),
            ),
    );
  }

  // ── 레벨 고르기 ─────────────────────────────
  List<Widget> _levelPicker() {
    final open = cur.openLevels(svc);
    return [
      Text(tr('회화 레벨을 고르세요'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4),
      Text(tr('처음이면 가장 낮은 레벨을 권합니다.'), style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
      const SizedBox(height: 12),
      for (final r in svc.regions)
        Card(
          child: ListTile(
            enabled: open.contains(r),
            leading: CircleAvatar(backgroundColor: AppColors.kazakh, child: Text(r, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800))),
            title: Text(trf('{0} 회화', [r])),
            subtitle: Text(trf('{0}편 · 통과 {1}', [svc.count(r), svc.list(region: r).where((d) => cur.passed.contains(d.id)).length])),
            trailing: open.contains(r) ? (r == svc.regions.first ? Text(tr('추천'), style: const TextStyle(color: AppColors.rojo, fontWeight: FontWeight.w700)) : null) : const Icon(Icons.lock_outline),
            onTap: () async {
              cur.level = r;
              await _save();
            },
          ),
        ),
    ];
  }

  // ── 본 화면 ────────────────────────────────
  List<Widget> _main() {
    final lv = cur.level!;
    return [
      _todayCard(),
      const SizedBox(height: 12),
      Row(children: [
        Text(trf('{0} 회화', [lv]), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
        const Spacer(),
        TextButton(onPressed: () async { cur.level = null; await _save(); }, child: Text(tr('레벨 바꾸기'))),
      ]),
      if (cur.course == null) ..._builder(lv) else ..._courseView(),
    ];
  }

  Widget _todayCard() {
    final due = cur.dueReview(today).length;
    final newLeft = cur.newLeftToday(today);
    final goal = cur.newGoal();
    final doneN = cur.newDoneToday(today) + cur.reviewDoneToday(today);
    final total = doneN + due + newLeft;
    return Card(
      color: AppColors.kazakh.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(cur.todayDone(today) ? tr('오늘 분량 끝') : trf('오늘: 복습 {0} · 새 편 {1}', [due, newLeft]),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const Spacer(),
            if (cur.streak > 0) Text(trf('🔥 {0}일 연속', [cur.streak]), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: total == 0 ? 1 : doneN / total, minHeight: 6, borderRadius: BorderRadius.circular(3)),
          const SizedBox(height: 10),
          Wrap(spacing: 6, children: [
            for (final g in Curriculum.goals.keys)
              ChoiceChip(
                label: Text({'light': tr('가볍게'), 'normal': tr('보통'), 'focus': tr('집중')}[g]!),
                selected: cur.dailyGoal == g,
                onSelected: (_) async { cur.dailyGoal = g; await _save(); },
              ),
          ]),
          Text(trf('하루 새 편 {0} + 복습', [goal]), style: const TextStyle(fontSize: 11, color: AppColors.tintaLight)),
          if (due > 0) ...[
            const SizedBox(height: 8),
            FilledButton.icon(onPressed: _review, icon: const Icon(Icons.replay), label: Text(trf('복습 {0}줄 하기', [due]))),
          ],
        ]),
      ),
    );
  }

  // ── 코스 만들기 ─────────────────────────────
  List<Widget> _builder(String lv) {
    final pool = svc.list(region: lv);
    final passed = cur.passed.toSet();
    return [
      Text(tr('코스에 넣을 회화를 고르세요'), style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Wrap(spacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
        for (final n in const [3, 5, 10])
          ChoiceChip(label: Text(trf('{0}편', [n])), selected: _size == n, onSelected: (_) => setState(() {
                _size = n;
                while (_pick.length > n) { _pick.remove(_pick.last); }
              })),
        OutlinedButton(
          onPressed: () => setState(() {
            final r = Curriculum.recommend(pool, passed, _size, already: _pick);
            _pick..clear()..addAll(r);
          }),
          child: Text(tr('추천으로 채우기')),
        ),
      ]),
      const SizedBox(height: 6),
      for (final d in pool)
        CheckboxListTile(
          dense: true,
          value: _pick.contains(d.id),
          onChanged: (v) => setState(() {
            if (v == true && _pick.length < _size) _pick.add(d.id);
            if (v == false) _pick.remove(d.id);
          }),
          title: Text('${d.emoji} ${d.title}'),
          subtitle: Text(passed.contains(d.id) ? tr('통과함') : d.island),
          secondary: passed.contains(d.id) ? const Icon(Icons.check_circle, color: AppColors.oliva) : null,
        ),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: _pick.length == _size
            ? () async {
                cur.startCourse(pool.where((d) => _pick.contains(d.id)).map((d) => d.id).toList(), today);
                _pick.clear();
                await _save();
              }
            : null,
        child: Text(trf('코스 시작 ({0}/{1})', [_pick.length, _size])),
      ),
    ];
  }

  // ── 진행 중인 코스 ──────────────────────────
  List<Widget> _courseView() {
    final ids = cur.courseIds;
    final pr = cur.practiced;
    final scores = ((cur.course?['examScores'] as List?) ?? const []).cast<int>();
    return [
      Text(trf('지금 코스 — {0}편 중 {1}편 연습함', [ids.length, ids.where(pr.contains).length]), style: const TextStyle(fontWeight: FontWeight.w700)),
      if (scores.isNotEmpty) Text(trf('지난 시험 {0}점 — 80점 이상이면 통과', [scores.last]), style: const TextStyle(fontSize: 12, color: AppColors.rojo)),
      const SizedBox(height: 6),
      for (final id in ids)
        if (svc.byId(id) case final d?)
          Card(
            child: ListTile(
              leading: Text(d.emoji, style: const TextStyle(fontSize: 22)),
              title: Text(d.title),
              subtitle: Text(pr.contains(id) ? tr('연습 끝') : tr('듣기 → 확인 문제')),
              trailing: Icon(pr.contains(id) ? Icons.check_circle : Icons.play_circle_outline, color: pr.contains(id) ? AppColors.oliva : AppColors.kazakh),
              onTap: () => _practice(d),
            ),
          ),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: cur.allPracticed ? _exam : null,
        icon: const Icon(Icons.flag),
        label: Text(cur.allPracticed ? tr('코스 시험 보기') : tr('모든 편을 연습하면 코스 시험')),
      ),
      const SizedBox(height: 16),
      if (!_askNew)
        TextButton(onPressed: () => setState(() => _askNew = true), child: Text(tr('새 코스 시작')))
      else
        Card(
          color: AppColors.rojo.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              Text(tr('지금 코스를 버리고 새 코스를 만들까요? 통과한 편과 복습은 그대로 남습니다.')),
              const SizedBox(height: 8),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(onPressed: () => setState(() => _askNew = false), child: Text(tr('그대로 두기'))),
                FilledButton(
                  onPressed: () async {
                    cur.data['course'] = null;
                    _askNew = false;
                    await _save();
                  },
                  child: Text(tr('새 코스 만들기')),
                ),
              ]),
            ]),
          ),
        ),
    ];
  }

  List<Dialogue> get _levelPool => svc.list(region: cur.level);

  Future<void> _practice(Dialogue d) async {
    final res = await openPane<_QuizResult>(context, (_) => _PracticeScreen(d: d, others: _levelPool));
    if (res == null) return;
    cur.finishPractice(d, res.wrongLines, today);
    await _save();
  }

  Future<void> _exam() async {
    final ds = [for (final id in cur.courseIds) ?svc.byId(id)];
    final per = max(3, 30 ~/ max(1, ds.length));
    final qs = <Question>[for (final d in ds) ...Curriculum.questionsFor(d, _levelPool, max: per)].take(30).toList()..shuffle();
    final res = await openPane<_QuizResult>(context, (_) => _QuizScreen(title: tr('코스 시험'), questions: qs));
    if (res == null) return;
    final wrongDs = {for (final q in qs) if (res.wrongLines.contains(q.lineId)) q.dialogueId}.toList();
    for (final w in res.wrongLines) {
      cur.answerReview(w, false, today);
    }
    final ok = cur.finishExam(res.right, res.total, wrongDs, today);
    await _save();
    if (!mounted) return;
    final sc = Curriculum.score(res.right, res.total);
    final lvDone = cur.level != null && cur.levelCleared(cur.level!, svc);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (lvDone ? trf('{0}점 통과! 이 레벨을 모두 끝내 다음 레벨이 열렸습니다.', [sc]) : trf('{0}점 통과! 다음 코스를 고르세요.', [sc]))
            : trf('{0}점 — 틀린 편을 다시 연습한 뒤 시험을 다시 보세요.', [sc]))));
  }

  Future<void> _review() async {
    final qs = <Question>[];
    final rnd = Random();
    for (final id in cur.dueReview(today).take(20)) {
      final i = id.lastIndexOf('#');
      final d = svc.byId(id.substring(0, i));
      final t = Curriculum.turnOf(id, svc);
      if (d == null || t == null) continue;
      final wrongs = {
        for (final x in [d, ..._levelPool]) for (final u in x.turns) if (u.ko.trim().isNotEmpty && u.ko.trim() != t.ko.trim()) u.ko.trim(),
      }.toList()..shuffle(rnd);
      if (wrongs.length >= 3) qs.add(Question.meaning(d, t, wrongs, rnd));
    }
    if (qs.isEmpty) return;
    final res = await openPane<_QuizResult>(context, (_) => _QuizScreen(title: tr('복습'), questions: qs));
    if (res == null) return;
    for (final q in qs) {
      cur.answerReview(q.lineId, !res.wrongLines.contains(q.lineId), today);
    }
    await _save();
  }
}

class _QuizResult {
  final int right, total;
  final List<String> wrongLines;
  const _QuizResult(this.right, this.total, this.wrongLines);
}

/// 편 연습 — ① 회화 듣기(녹음 있으면 녹음, 없으면 합성 음성) ② 확인 문제.
class _PracticeScreen extends StatefulWidget {
  final Dialogue d;
  final List<Dialogue> others;
  const _PracticeScreen({required this.d, required this.others});
  @override
  State<_PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<_PracticeScreen> {
  bool _listened = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.d;
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text('${d.emoji} ${d.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
      body: ListView(padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)), children: [
        Text(d.scene, style: const TextStyle(fontSize: 13, color: AppColors.tintaLight)),
        const SizedBox(height: 16),
        _Step(n: 1, title: tr('듣기·읽기'), sub: tr('회화 전체를 듣고 줄마다 뜻을 확인합니다. 줄을 눌러 따라 말해 보세요.'), done: _listened,
            onTap: () async {
              await openPane(context, (_) => DialogueScreen(dialogue: d));
              if (mounted) setState(() => _listened = true);
            }),
        const SizedBox(height: 10),
        _Step(n: 2, title: tr('확인 문제'), sub: tr('카자흐어 줄을 보고 뜻을 고릅니다(최대 10문제).'), done: false, enabled: _listened,
            onTap: () async {
              final qs = Curriculum.questionsFor(d, widget.others);
              final nav = Navigator.of(context);
              final res = await nav.push<_QuizResult>(MaterialPageRoute(builder: (_) => _QuizScreen(title: tr('확인 문제'), questions: qs)));
              if (res != null && mounted) nav.pop(res);
            }),
      ]),
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final String title, sub;
  final bool done, enabled;
  final VoidCallback onTap;
  const _Step({required this.n, required this.title, required this.sub, required this.done, required this.onTap, this.enabled = true});
  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          enabled: enabled,
          leading: CircleAvatar(backgroundColor: done ? AppColors.oliva : AppColors.kazakh, child: done ? const Icon(Icons.check, color: Colors.white) : Text('$n', style: const TextStyle(color: Colors.white))),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right),
          onTap: enabled ? onTap : null,
        ),
      );
}

/// 4지선다 문제 풀이 — 끝나면 점수 화면, 닫으면 결과를 돌려준다.
class _QuizScreen extends StatefulWidget {
  final String title;
  final List<Question> questions;
  const _QuizScreen({required this.title, required this.questions});
  @override
  State<_QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<_QuizScreen> {
  int _i = 0, _right = 0;
  int? _chosen;
  final List<String> _wrong = [];

  @override
  Widget build(BuildContext context) {
    final qs = widget.questions;
    final done = _i >= qs.length;
    return Scaffold(
      backgroundColor: AppColors.cal,
      appBar: AppBar(title: Text(done ? widget.title : '${widget.title} ${_i + 1}/${qs.length}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800))),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset(context)),
        child: done ? _result(qs.length) : _question(qs[_i]),
      ),
    );
  }

  Widget _result(int total) {
    final sc = Curriculum.score(_right, total);
    return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('$sc', textAlign: TextAlign.center, style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: sc >= Curriculum.passRate ? AppColors.oliva : AppColors.rojo)),
      Text(trf('{0}문제 중 {1}개 맞힘', [total, _right]), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton(onPressed: () => Navigator.of(context).pop(_QuizResult(_right, total, _wrong)), child: Text(tr('끝'))),
    ]);
  }

  Widget _question(Question q) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(q.prompt, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
      if (q.rd.isNotEmpty) Text(q.rd, style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
      const SizedBox(height: 6),
      Text(tr('뜻을 고르세요'), style: const TextStyle(fontSize: 12, color: AppColors.tintaLight)),
      const SizedBox(height: 12),
      for (var k = 0; k < q.choices.length; k++)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(14),
              backgroundColor: _chosen == null ? null : (k == q.answer ? AppColors.oliva.withValues(alpha: 0.18) : (k == _chosen ? AppColors.rojo.withValues(alpha: 0.15) : null)),
            ),
            onPressed: _chosen != null ? null : () => setState(() {
              _chosen = k;
              if (k == q.answer) {
                _right++;
              } else {
                _wrong.add(q.lineId);
              }
            }),
            child: Text(q.choices[k], style: const TextStyle(fontSize: 15)),
          ),
        ),
      const Spacer(),
      if (_chosen != null) FilledButton(onPressed: () => setState(() { _i++; _chosen = null; }), child: Text(tr('다음'))),
    ]);
  }
}
