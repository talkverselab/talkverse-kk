import '../core/embed_env.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import 'learner_prefs.dart';
import 'script_sync.dart';

/// 회화 리더(일본어앱 시안 02 「만화책 읽기형」)용 회화 모델 — 2026-11-02, 일본어앱 `dialogue_service.dart` 를 옮김.
///
/// 2026-11-22: 새 구조 `assets/data/dialogues/R<레벨>/<주제>/<편id>.json`(일본어앱과 같음)을 읽는다. 대사는 Grok 이 쓴 것(2026-11-18 원칙).
/// 각 파일은 서버에 더 새 판이 있으면 그것([ScriptSync], 사용자 지시 2026-11-18 「다이얼로그까지 DB 에서」).
/// 칸: tl = 카자흐어(키릴), gloss = 없음, rd = 한글 독음, ko = 한국어, emotion = 음성 감정.
class DialogueTurn {
  final int num;
  final String speaker; // A·B
  final String tl;
  final String gloss;
  final String rd;
  final String ko;
  final String note;
  final List<String> tags;
  final String? art; // 장면 그림 URL(나중에 채움)
  /// 「어순 맞대기」 낱말 대응 [(카자흐어, 한국어)] — 데이터에 `align: [[kk, ko], …]` 가 있을 때만(회화 작업 때 채움).
  final List<(String, String)> align;
  /// 문장 내용어 `lemmas: [[표면형, 기본형, 읽기]]`(있을 때만 — 없으면 앱이 접사 분석으로 만든다, 2026-11-04).
  final List<(String, String, String)> lemmas;
  final List<String> newWords;
  final String emotion;
  const DialogueTurn({
    required this.num,
    required this.speaker,
    required this.tl,
    required this.gloss,
    required this.rd,
    required this.ko,
    required this.note,
    required this.tags,
    this.art,
    this.align = const [],
    this.lemmas = const [],
    this.newWords = const [],
    this.emotion = 'neutral',
  });

  factory DialogueTurn.fromJson(Map<String, dynamic> j) => DialogueTurn(
        num: j['num'] as int? ?? 0,
        speaker: j['speaker'] as String? ?? 'A',
        tl: (j['tl'] ?? j['es']) as String? ?? '',
        newWords: (j['new'] as List?)?.cast<String>() ?? const [],
        emotion: j['emotion'] as String? ?? 'neutral',
        gloss: j['gloss'] as String? ?? '',
        rd: j['rd'] as String? ?? '',
        ko: j['ko'] as String? ?? '',
        note: j['note'] as String? ?? '',
        tags: (j['tags'] as List?)?.cast<String>() ?? const [],
        art: j['art'] as String?,
        align: [
          for (final a in (j['align'] as List? ?? const []))
            if (a is List && a.length >= 2) ('${a[0]}', '${a[1]}'),
        ],
        lemmas: [
          for (final l in (j['lemmas'] as List? ?? const []))
            if (l is List && l.length >= 2) ('${l[0]}', '${l[1]}', l.length > 2 ? '${l[2]}' : ''),
        ],
      );

  /// 그림 조회용 핵심 단어 후보: 새 단어(new) 먼저, 그다음 카자흐어 문장의 낱말(소문자, 2자 이상).
  List<String> get pictureWords => [
        ...newWords.map((w) => w.toLowerCase()),
        for (final w in tl.toLowerCase().split(RegExp(r'[^\p{L}\p{M}]+', unicode: true)))
          if (w.length >= 2) w,
      ];
}

class Dialogue {
  final String id;
  final String region; // R0..R4
  final String island; // 주제
  final String kind; // survival short long chat
  final int twist;
  final String title;
  final String emoji;
  final String scene;
  final Map<String, String> speakers;
  final Map<String, String> genders;
  final List<String> expressions;
  final List<DialogueTurn> turns;
  final String? art;
  const Dialogue({
    required this.id,
    required this.region,
    required this.island,
    this.kind = 'long',
    this.twist = 0,
    required this.title,
    required this.emoji,
    required this.scene,
    required this.speakers,
    required this.genders,
    required this.expressions,
    required this.turns,
    this.art,
  });

  factory Dialogue.fromJson(Map<String, dynamic> j) => Dialogue(
        id: j['id'] as String,
        region: j['region'] as String? ?? 'R1',
        island: j['island'] as String? ?? '',
        kind: j['kind'] as String? ?? 'long',
        twist: j['twist'] as int? ?? 0,
        title: j['title'] as String? ?? '',
        emoji: j['emoji'] as String? ?? '💬',
        scene: j['scene'] as String? ?? '',
        speakers: ((j['speakers'] as Map?) ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
        genders: ((j['genders'] as Map?) ?? const {}).map((k, v) => MapEntry(k.toString(), v.toString())),
        expressions: (j['expressions'] as List?)?.cast<String>() ?? const [],
        turns: ((j['turns'] as List?) ?? const []).map((t) => DialogueTurn.fromJson(t as Map<String, dynamic>)).toList(),
        art: j['art'] as String?,
      );

  bool get isChat => kind == 'chat';

  /// 화면에 보일 장면 설명 — 원고의 「A」(학습자)를 이름(없으면 「나」)으로(일본어앱 빌드 111, 사용자 지시 2026-11-17).
  String get sceneShown => scene.replaceAllMapped(RegExp(r'(?<![A-Za-z])A(?![A-Za-z]) ?(?=[가-힣])'), (_) => speakerName('A'));

  /// 화면에 보일 글 — 「〇〇」(학습자 자리)·`{name}` 을 이름으로(일본어앱 빌드 111).
  String nameIn(String s) {
    final n = speakerName('A');
    return s.replaceAll('{name}', n).replaceAll('〇〇', n).replaceAll('{country}', '한국').replaceAll('{city}', '서울');
  }

  /// 편 순서 키: survival → a → b → c, 번호 순.
  String get orderKey {
    final m = RegExp(r'_([abcs])(\d+)$').firstMatch(id);
    if (m == null) return id;
    const o = {'s': 0, 'a': 1, 'b': 2, 'c': 3};
    return '${o[m.group(1)]}${m.group(2)!.padLeft(2, '0')}';
  }

  /// 화자 표시 이름. `{name}` 자리는 학습자 이름(없으면 「나」).
  String speakerName(String sp) {
    final raw = speakers[sp] ?? sp;
    if (raw.contains('{name}')) return LearnerPrefs.name.value.isNotEmpty ? LearnerPrefs.name.value : '나';
    return raw.replaceAll(RegExp(r'[{}]'), '');
  }

  /// 목소리 성별 — 지금 회화는 화자 이름·성별이 정해진 이야기(A 민 남 · B 사라 여)라 데이터의 성별을 따른다.
  String voiceGender(String sp) => genders[sp] ?? LearnerPrefs.voiceGender(sp);
}

class DialogueService {
  DialogueService._();
  static final DialogueService instance = DialogueService._();

  static const islands = ['survival', 'friends', 'love', 'life', 'travel', 'culture', 'work', 'study'];
  static const islandKo = {
    'survival': '서바이벌',
    'friends': '친구',
    'love': '사랑',
    'life': '생활',
    'travel': '여행',
    'culture': '문화',
    'work': '일',
    'study': '학업',
  };
  static const islandEmoji = {
    'survival': '🆘',
    'friends': '🤝',
    'love': '💘',
    'life': '🏠',
    'travel': '✈️',
    'culture': '🎬',
    'work': '💼',
    'study': '🎓',
  };
  static const levels = ['R0', 'R1', 'R2', 'R3', 'R4'];
  static const levelKo = {'L1': '이야기', 'R0': '왕초보', 'R1': '초보', 'R2': '중급', 'R3': '고급', 'R4': '최상급'};
  static final _prefLast = pk('dialogue_last');

  final List<Dialogue> _all = [];
  Future<void>? _loading;
  String? _lastOpened;
  String? get lastOpenedId => _lastOpened;
  Future<void> setLastOpened(String id) async {
    _lastOpened = id;
    (await SharedPreferences.getInstance()).setString(_prefLast, id);
  }

  /// 넓은 화면에서 탭이 동시에 떠 두 번 불려도 한 번만 읽는다(플래그로 막으면 경쟁으로 목록이 두 번 찬다).
  Future<void> ensureLoaded() => _loading ??= _load();

  /// 원고가 서버 판으로 바뀌어 다시 읽힐 때마다 오른다.
  final ValueNotifier<int> revision = ValueNotifier(0);

  Future<void> _load() async {
    _lastOpened = (await SharedPreferences.getInstance()).getString(_prefLast);
    await _readAll();
    // 서버에 더 새 원고가 있으면 뒤에서 받아 다시 읽는다(없거나 실패하면 그대로)
    ScriptSync.instance.refresh().then((changed) async {
      if (!changed) return;
      await _readAll();
      revision.value++;
    });
  }

  /// 앱 안 편 + 서버에서 받은 새 편 − 서버에서 빠진 편. 각 파일은 덮어쓴 판이 있으면 그것.
  Future<void> _readAll() async {
    final sync = ScriptSync.instance;
    await sync.init();
    final pat = RegExp(r'^assets/data/dialogues/R[0-4]/[^/]+/[^/]+\.json$');
    final rels = <String>{};
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      // 통합 앱이면 키에 packages/kk_app/ 가 붙어 있다 — 떼고 견준다
      rels.addAll([for (final p in manifest.listAssets().map(stripAssetPrefix).where(pat.hasMatch)) p.substring('assets/data/'.length)]);
    } catch (_) {}
    rels
      ..addAll(sync.added.where((p) => pat.hasMatch('assets/data/$p')))
      ..removeAll(sync.removed);
    final next = <Dialogue>[];
    for (final rel in rels) {
      try {
        final d = Dialogue.fromJson(json.decode(await sync.load(rel)) as Map<String, dynamic>);
        if (d.turns.isNotEmpty) next.add(d);
      } catch (_) {}
    }
    next.sort((a, b) => a.region != b.region ? a.region.compareTo(b.region) : a.orderKey.compareTo(b.orderKey));
    _all
      ..clear()
      ..addAll(next);
  }

  Dialogue? byId(String id) => _all.where((d) => d.id == id).firstOrNull;
  List<Dialogue> get all => List.unmodifiable(_all);
  List<String> get regions => [for (final r in levels) if (_all.any((d) => d.region == r)) r];

  List<Dialogue> list({String? region, String? island}) =>
      _all.where((d) => (region == null || d.region == region) && (island == null || d.island == island)).toList();

  List<String> islandsOf(String region) {
    final has = _all.where((d) => d.region == region).map((d) => d.island).toSet();
    return islands.where(has.contains).toList();
  }

  int count(String region) => _all.where((d) => d.region == region).length;
}
