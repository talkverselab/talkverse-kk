import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/embed_env.dart';
import 'core/l10n.dart';
import 'data/account.dart';
import 'data/db/app_database.dart';
import 'data/db/seed_loader.dart';
import 'data/purchase.dart';
import 'main.dart';
import 'services/achievement_service.dart';
import 'services/content_sync.dart';
import 'services/ko_reading.dart';
import 'services/learner_prefs.dart';

/// 임베드 약속(~/talkverse/talkverse-app/EMBED_GUIDE.md, 2026-11-09) — 단독 앱 main() 과 통합 앱이 같은 두 함수를 쓴다.
/// 통합 앱: `await embedInit(embedded: true); … embedApp(onSwitchLanguage: …)`. 단독: main.dart.
bool _syncFirst = false;
Future<void>? _init;

/// 가격표 = ~/talkverse/PRICING.md(사용자 확정 2026-11-09) — 앱 할인가(출시 기념 30%)·앱 정가(취소선). 스토어 등록 목록 docs/STORE_PRODUCTS.md
const plans = [
  Plan('lang_kk_1m', 1, 3900, listKrw: 5500),
  Plan('lang_kk_3m', 3, 9000, listKrw: 12900),
  Plan('lang_kk_1y', 12, 19900, listKrw: 28500),
  Plan('lang_kk_life', 0, 49000, listKrw: 69900),
  Plan('all_1y', 12, 79000, listKrw: 112900, bundle: true),
  Plan('all_life', 0, 329000, listKrw: 469000, bundle: true),
];

/// 지금까지의 main() 초기화 전부(runApp·화면 방향 제외). 두 번 불러도 한 번만 돈다.
Future<void> embedInit({bool embedded = false}) => _init ??= _embedInit(embedded);

Future<void> _embedInit(bool embedded) async {
  WidgetsFlutterBinding.ensureInitialized();
  Embed.embedded = embedded;
  if (!embedded) await migrateStorage(); // 단독 앱만 옛 저장 이름에서 한 번 옮긴다
  appDb = AppDatabase();
  await SeedLoader(appDb).seedIfNeeded();
  await KoReadingPrefs.load();
  await AppLangPrefs.load();
  await LearnerPrefs.load(); // 학습자 이름·성별 — 화자 A 의 목소리·{name}(언어 공통)
  await AchievementService.instance.load(); // 성과(편 완주·그림 카드)
  Account.load(); // Talkverse ID — 저장된 로그인 표시 + 뒤에서 토큰 갱신(기다리지 않음)
  Purchase.configure(Embed.code, plans);
  // 그림(장면 컷·단어 그림) 기기 내려받기: 버전이 다르면 로딩 화면에서 받고 시작(사용자 지시 2026-11-04)
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final shortest = view.physicalSize.shortestSide / view.devicePixelRatio;
  try {
    _syncFirst = await ContentSync.instance.init(large: shortest >= 600).timeout(const Duration(seconds: 10));
  } catch (_) {}
}

/// runApp 에 넘기는 위젯(MaterialApp). onSwitchLanguage 가 있으면 프로필 설정 맨 위에 「다른 언어 배우기」.
Widget embedApp({VoidCallback? onSwitchLanguage}) {
  Embed.onSwitchLanguage = onSwitchLanguage;
  return GermanUniverseApp(syncFirst: _syncFirst);
}

/// 설계 문서 이름(init/app)으로도 부를 수 있게.
Future<void> init() => embedInit(embedded: true);
Widget app({VoidCallback? onSwitchLanguage}) => embedApp(onSwitchLanguage: onSwitchLanguage);

/// 옛 저장 이름(접두 없음) → `kk_` 접두로 한 번 옮긴다: SharedPreferences 키·그림 폴더.
/// 학습자 이름·성별(learner_*)·표시 언어(app_lang)·로그인(보안 저장소 tv_*)은 언어 공통이라 그대로.
/// DB 파일 `kk_universe.sqlite` 는 처음부터 언어 접두라 그대로 둔다.
Future<void> migrateStorage() async {
  final p = await SharedPreferences.getInstance();
  if (p.getBool(pk('storage_migrated_v1')) ?? false) return;
  const fixed = ['iap_owned2', 'iap_owned', 'iap_pending', 'achievements_v1', 'db_version', 'dialogue_last', 'ko_reading_show_v2',
    'art_version_v1', 'art_scene_manifest_v1', 'memorized_words', 'card_ko_first', 'card_show_hint', 'speak_stage', 'speak_show_hint'];
  final keys = [...fixed, ...p.getKeys().where((k) => k.startsWith('speak_best_') || k.startsWith('memo:'))];
  for (final k in keys) {
    final v = p.get(k);
    final nk = k.startsWith('memo:') ? '${pk('memo')}${k.substring(4)}' : pk(k);
    if (v == null || p.containsKey(nk)) continue;
    switch (v) {
      case String s: await p.setString(nk, s);
      case bool b: await p.setBool(nk, b);
      case int i: await p.setInt(nk, i);
      case double d: await p.setDouble(nk, d);
      case List l: await p.setStringList(nk, l.cast<String>());
    }
    await p.remove(k);
  }
  try {
    final sup = (await getApplicationSupportDirectory()).path;
    final art = Directory('$sup/art'), artn = Directory('$sup/${pk('art')}');
    if (await art.exists() && !await artn.exists()) await art.rename(artn.path);
  } catch (e) {
    debugPrint('migrateStorage: $e');
  }
  await p.setBool(pk('storage_migrated_v1'), true);
}
