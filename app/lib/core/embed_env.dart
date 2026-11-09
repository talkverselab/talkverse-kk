import 'package:flutter/foundation.dart';

/// 통합 앱(Talkverse, `~/talkverse/talkverse-app`) 임베드 환경 — EMBED_GUIDE.md(2026-11-09, 한국어앱 구현을 따름).
/// 단독 앱이면 [embedded] = false 로 지금과 똑같이 돈다.
class Embed {
  Embed._();
  static bool embedded = false;
  static VoidCallback? onSwitchLanguage; // 있으면 프로필 설정 맨 위에 「다른 언어 배우기」
  static const package = 'kk_app';
  static const code = 'kk';
}

/// 에셋 경로 — 통합 앱이 패키지로 부르면 `packages/kk_app/assets/…`.
String assetPath(String p) => Embed.embedded && !p.startsWith('packages/') ? 'packages/${Embed.package}/$p' : p;

/// audioplayers AssetSource 의 접두(AudioCache prefix). 단독 = 'assets/', 통합 = 'packages/kk_app/assets/'.
String get audioAssetPrefix => assetPath('assets/');

/// 이 언어 전용 저장 이름(SharedPreferences 키·파일·폴더) — `kk_` 접두. 학습자 이름·성별·표시 언어·로그인은 접두 없이 공유.
String pk(String key) => '${Embed.code}_$key';
