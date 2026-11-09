import '../core/embed_env.dart';
// ignore_for_file: prefer_interpolation_to_compose_strings — 동사 규칙형은 덧셈이 더 읽기 쉽다
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/dialogue_service.dart';

/// 카자흐어 접사 표 + 자동 분석 — 구조는 몽골어앱(2026-11-03)에서 옮김.
///
/// ⚠ 초기 빌드(2026-11-08): **접사 표는 비어 있다.** 카자흐어 접사(격어미·복수·소유·동사 어미)는
/// 콘텐츠 작업 지시가 있을 때 채운다. 표가 비면 접사 사전·접사 블록·동사 맵은 빈 안내만 나온다.
/// 분석은 규칙 기반이라 틀릴 수 있다(화면에 「자동 분석」 표시). 예문은 앱에 이미 있는 문장에서만 찾는다.
enum AffixKind { kase, plural, poss, verb }

extension AffixKindX on AffixKind {
  String get label => switch (this) {
        AffixKind.kase => '격어미',
        AffixKind.plural => '복수',
        AffixKind.poss => '소유',
        AffixKind.verb => '동사 어미',
      };
  Color get color => switch (this) {
        AffixKind.kase => AppColors.ai,
        AffixKind.plural => const Color(0xFFE8913A),
        AffixKind.poss => AppColors.matcha,
        AffixKind.verb => AppColors.beniDeep,
      };
}

/// 모음조화 열쇠(카자흐어): a = 뒤 모음(а о ұ ы), e = 앞 모음(ә ө ү і е). 마지막 모음이 정한다.
/// (표의 forms 키는 몽골어앱과 같은 a·o·e·ö 를 쓰되 카자흐어는 a·e 두 가지만 쓴다.)
String harmonyOf(String stem) {
  final s = stem.toLowerCase();
  for (var k = s.length - 1; k >= 0; k--) {
    final c = s[k];
    if ('аоұыяё'.contains(c)) return 'a';
    if ('әөүіеэ'.contains(c)) return 'e';
  }
  return 'e';
}

class Affix {
  final String id;
  final AffixKind kind;
  final String name; // 한국어 이름
  final String ko; // 대응 한국어(조사·어미)
  final List<String> koMarkers; // 한국어 낱말 속에서 찾을 조사(테두리 묶기)
  final Map<String, String> forms; // 모음조화 열쇠(a·o·e·ö) → 형태
  final List<String> extra; // 모음조화와 무관한 다른 형태
  final String rule;
  const Affix(this.id, this.kind, this.name, this.ko, this.koMarkers, this.forms, this.rule, {this.extra = const []});

  /// 화면에 늘어놓을 형태(중복 없이, a·o·e·ö 순).
  List<String> get variants => {for (final k in const ['a', 'o', 'e', 'ö']) if (forms[k] != null) forms[k]!, ...extra}.toList();
  List<String> get allForms => variants;
}

/// 카자흐어 접사 표 — 콘텐츠 작업 때 채운다(지금은 비어 있음).
const List<Affix> kKkAffixes = [];

Affix? affixById(String id) => kKkAffixes.where((a) => a.id == id).firstOrNull;

/// 나누지 않는 낱말 — 기능어·인사말처럼 끝이 접사와 같아 보이지만 한 덩어리인 것.
const Set<String> _noSplit = {};

class AffixHit {
  final String word; // 원래 낱말(대소문자 그대로)
  final String stem;
  final String suffix;
  final Affix affix;
  const AffixHit(this.word, this.stem, this.suffix, this.affix);
  String get harmony => harmonyOf(stem);
}

/// 낱말 하나를 어간 + 접사 하나로 나눈다(가장 긴 형태 우선). 못 나누면 null.
AffixHit? analyzeWord(String word) {
  final w = word.toLowerCase();
  if (w.length < 5 || _noSplit.contains(w)) return null;
  AffixHit? best;
  for (final a in kKkAffixes) {
    for (final f in a.allForms) {
      if (f.length < 2 || !w.endsWith(f)) continue;
      final stemLen = w.length - f.length;
      if (stemLen < 3) continue;
      if (best == null || f.length > best.suffix.length) {
        best = AffixHit(word, word.substring(0, stemLen), word.substring(stemLen), a);
      }
    }
  }
  return best;
}

List<String> splitWords(String s) =>
    s.split(RegExp(r'[^\p{L}\p{M}-]+', unicode: true)).where((w) => w.isNotEmpty).toList();

/// 예문 한 줄(앱에 이미 있는 문장).
class AffixExample {
  final String tl, ko, source;
  final AffixHit hit;
  const AffixExample(this.tl, this.ko, this.source, this.hit);
}

/// 회화(dialogue_service) + 여행 표현(assets/data/vocab/travel_expressions.json)에서 접사가 든 문장을 모은다.
class AffixCorpus {
  AffixCorpus._();
  static final AffixCorpus instance = AffixCorpus._();
  Future<void>? _loading;
  final List<AffixExample> _all = [];

  Future<void> ensureLoaded() => _loading ??= _load();

  Future<void> _load() async {
    final lines = <(String, String, String)>[];
    await DialogueService.instance.ensureLoaded();
    for (final d in DialogueService.instance.all) {
      for (final t in d.turns) {
        lines.add((t.tl, t.ko, d.title));
      }
    }
    try {
      final j = json.decode(await rootBundle.loadString(assetPath('assets/data/vocab/travel_expressions.json'))) as Map<String, dynamic>;
      for (final th in (j['themes'] as List? ?? const [])) {
        for (final sec in ((th as Map)['sections'] as List? ?? const [])) {
          for (final w in ((sec as Map)['words'] as List? ?? const [])) {
            final m = w as Map;
            lines.add(('${m['tx'] ?? ''}', '${m['ko'] ?? ''}', '${th['title'] ?? ''}'));
          }
        }
      }
    } catch (_) {}
    final seen = <String>{};
    for (final (tl, ko, src) in lines) {
      for (final w in splitWords(tl)) {
        final h = analyzeWord(w);
        if (h == null) continue;
        if (!seen.add('${h.affix.id}|${w.toLowerCase()}|$tl')) continue;
        _all.add(AffixExample(tl, ko, src, h));
      }
    }
  }

  List<AffixExample> examplesOf(String affixId) => _all.where((e) => e.hit.affix.id == affixId).toList();
  List<AffixExample> get all => List.unmodifiable(_all);
  int count(String affixId) => _all.where((e) => e.hit.affix.id == affixId).length;
}

// ── 동사 형태 맵(2026-11-03 사용자 지시 "동사 형태 맵") ──────────────────────────
// 앱 문장에서 나눈 동사 접사의 어간을 사전 어간으로 맞추고(연결 모음 떼기), 규칙으로 각 형태를 만든다.
// 앱 문장에 실제로 나온 형태는 예문과 함께, 나오지 않은 형태는 「규칙형」으로 표시한다.

/// 분석된 어간 → 사전 어간. 카자흐어 규칙은 콘텐츠 작업 때(지금은 그대로 돌려준다).
String verbStem(String stem) => stem.toLowerCase();

/// 동사 어간 + 접사 id → 규칙형. 카자흐어 규칙은 접사 표와 함께 채운다 — 지금은 늘 null(화면에 규칙형 칸 없음).
String? verbForm(String stem, String affixId) => null;

/// 동사 형태 맵에 펼칠 접사 순서.
const List<String> kVerbMapSlots = [];

class VerbEntry {
  final String stem;
  final Map<String, List<AffixExample>> seen; // 접사 id → 앱 문장 예문
  VerbEntry(this.stem, this.seen);
  int get count => seen.values.fold(0, (a, b) => a + b.length);

  /// 제목: 앱 문장에 나온 부정사가 있으면 그것, 없으면 「어간-」(모음이 빠지는 어간이 있어 규칙형 부정사는 제목에 쓰지 않는다).
  String get title => seen['inf']?.first.hit.word.toLowerCase() ?? '$stem-';
}

extension AffixCorpusVerbs on AffixCorpus {
  /// 앱 문장에 나온 동사 어간(사전 어간) 목록 — 형태가 많이 나온 순.
  List<VerbEntry> verbs() {
    final by = <String, Map<String, List<AffixExample>>>{};
    for (final e in all) {
      if (e.hit.affix.kind != AffixKind.verb) continue;
      final st = verbStem(e.hit.stem);
      by.putIfAbsent(st, () => {}).putIfAbsent(e.hit.affix.id, () => []).add(e);
    }
    final out = [for (final en in by.entries) VerbEntry(en.key, en.value)]
      ..sort((a, b) => b.seen.length != a.seen.length ? b.seen.length.compareTo(a.seen.length) : b.count.compareTo(a.count));
    return out;
  }
}
