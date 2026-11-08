# CLAUDE.md — talkverselab/talkverse-kk

이 폴더에서 작업하는 모든 세션이 먼저 읽는 규칙. **빌드·배포를 건드리기 전에 반드시 확인할 것.**

## 1. 서명 (가장 자주 사고 나는 곳)

이 앱은 GitHub 릴리스로 **앱 안에서 스스로 업데이트**한다.
폰에 이미 깔린 앱과 **서명 키가 같아야만** 덮어쓰기 설치가 된다.

### 쓰는 키 — 새로 만들지 말 것

- 폰에 깔린 앱과 같은 키: 로컬 `~/.android/debug.keystore`
  (alias `androiddebugkey`, store/key 비밀번호 `android`)
- SHA-1 `9C:C4:BC:93:26:38:BE:43:A3:98:2D:F2:0B:71:C4:75:02:88:47:6B`
- 같은 키가 리포 시크릿 **`ANDROID_DEBUG_KEYSTORE_BASE64`** 에 base64로 들어 있고, CI가 이걸 복원해 서명한다.
- 로컬에서 릴리스 빌드할 때도 같은 키를 쓴다. `android/key.properties`가 없으면 이렇게 만든다:

```bash
cp ~/.android/debug.keystore android/app/signing-key.jks
printf 'storePassword=android\nkeyPassword=android\nkeyAlias=androiddebugkey\nstoreFile=signing-key.jks\n' > android/key.properties
```

### 절대 하지 말 것

- **새 키스토어를 만들지 말 것.** 서명이 바뀌면 폰에서 앱을 지웠다 다시 깔아야 하고, **학습 기록이 전부 사라진다.**
- CI의 `Restore signing key` 단계를 지우거나, `build.gradle.kts`의 release 서명을
  `signingConfigs.getByName("debug")` 로 되돌리지 말 것.
  GitHub 러너는 빌드할 때마다 debug 키를 **새로 만들어** 서명이 매번 달라진다.
  (2026-09-10에 실제로 겪은 문제 — 17개 앱 설치가 전부 `INSTALL_FAILED_UPDATE_INCOMPATIBLE`로 실패했다.)
- `android/key.properties`, `android/app/signing-key.jks`를 커밋하지 말 것 (`.gitignore`에 있음).

### 설치가 실패하면

```
INSTALL_FAILED_UPDATE_INCOMPATIBLE: signatures do not match
```

→ 앱을 지우지 말고 **서명부터 확인**한다:

```bash
apksigner verify --print-certs <apk> | grep SHA-1   # 9cc4bc932638be43a3982df20b71c4750288476b 여야 한다
```

## 폰에 설치할 때 (PC에서 케이블로)

폰에 **듀얼 메신저 프로필(user 95)** 과 보안 폴더(user 150)가 있다. `adb install` 은 프로필을 지정하지 않으면
**모든 프로필에 설치**해서 앱 아이콘이 두 개(파란 말풍선 배지 달린 복제본)가 생긴다. 반드시 기본 프로필만 지정한다:

```bash
adb -s R3CY20HDN2K install --user 0 -r <apk>
```

(2026-09-11에 24개 앱이 전부 두 개씩 깔려 있던 것을 정리함. 앱 안의 「앱 업데이트」로 설치하면 이 문제는 생기지 않는다.)

## 2. 배포 흐름

- `master`(또는 기본 브랜치) 푸시 → GitHub Actions(`.github/workflows/release.yml`)가
  서명된 APK와 `latest.json`을 `latest` 릴리스에 올린다.
- **빌드 번호 = 워크플로 실행 번호**(`--build-number=${{ github.run_number }}`).
  앱은 자기 빌드 번호와 `latest.json`의 `build`를 견주어 새 빌드를 판단한다.
  로컬 `flutter build apk`로 만든 APK는 pubspec의 작은 번호를 써서 앱이 늘 "새 빌드 있음"으로 보인다 — 정상.
- `**.md`만 고친 푸시는 빌드하지 않는다(`paths-ignore`). 헛된 업데이트 알림 방지.
- **폰 업데이트**: 앱 → 설정(프로필) 화면 → **「앱 업데이트」** → 내려받아 설치. 케이블·adb 불필요.
  첫 설치 때 「출처를 알 수 없는 앱 설치」 허용이 한 번 필요하다(안드로이드 강제).

관련 파일: `lib/services/update_service.dart`, `lib/screens/update_screen.dart`,
`android/app/src/main/kotlin/**/MainActivity.kt`(설치 메서드 채널),
`android/app/src/main/res/xml/file_paths.xml`, `.github/workflows/release.yml`

구현 안내서: https://github.com/talkverselab/talkverse-th/blob/master/docs/in-app-update-via-github.md

## 3. 리포

- 이름은 **`talkverselab/talkverse-<언어코드>`** 로 통일(2026-09-10) — 이 앱은 `talkverselab/talkverse-kk`.
- **공개(PUBLIC) 저장소**다. 앱이 토큰 없이 APK를 받으려면 공개여야 한다.
- 다운로드 허브: https://github.com/talkverselab/talkverse-releases

## 4. 공개 저장소라서 지킬 것

- **출처를 드러내지 말 것.** 자막·말뭉치 제공처 이름(스트리밍 서비스, 공개 자막 데이터셋 등), 책 이름·쪽수,
  드라마·영화 제목을 코드·에셋·문서·파일명·화면 문구 어디에도 남기지 않는다.
- 저작권 있는 원문(자막 대본, 원서 전사)을 리포에 넣지 않는다. 단어·빈도 통계만 쓰고 문장은 자체 제작한다.
- 새 파일을 추가할 때 위 두 가지를 먼저 확인할 것. 한 번 공개 커밋되면 히스토리에 남는다.

## 2026-11-08 — 몽골어앱 구조로 새로 만듦(초기 빌드)

- 몽골어앱(`talkverselab/talkverse-mn` 커밋 `afa1dc8`)의 코드 뼈대를 복사해 이름만 바꿨다 — 이력은 가져오지 않았다(새 저장소).
- **몽골어 콘텐츠(회화·단어·예문·문법·음성·접사 표)는 하나도 가져오지 않았다.** 데이터 파일은 비어 있다:
  `assets/data/dialogues/L1.json`(episodes []), `freq/kk_words.csv`(머리줄만), `vocab/*.json`(themes []), 문법 레슨 없음, `assets/audio/manifest.json` {}.
- 구조만 있는 것: 접사 사전·접사 블록·모음조화 점(`lib/data/kk_affixes.dart` — 표 `kKkAffixes` 비어 있음, `harmonyOf` = 카자흐어 앞/뒤 모음), 동사 맵(`verbForm` → null), 절벽(`lib/core/cliff.dart` `kCliffReady=false`).
- **범위 = 소수언어(2026-11-08 사용자 결정, 몽골어와 같음)**: 절벽 단어 약 1,500, 회화 150편(R3 까지), 회화 흐름 Claude 초안 → Grok → Gemini 검수 → DB. 콘텐츠는 사용자 지시가 있을 때.
- 대상어 문장 칸 이름은 템플릿 그대로 `es`/`tx` 다. 언어와 무관하게 "대상어"로 읽는다.

## 이름 (2026-11-08 정함 — 바꾸지 말 것)

| 항목 | 값 |
|---|---|
| 폴더 / 저장소 | `~/talkverse/kk` / `talkverselab/talkverse-kk` |
| Android applicationId · namespace | `com.talkverse.kk` |
| iOS 번들 ID | `com.talkverse.kk` |
| Zealot 앱이름 | **카자흐어유니버스** |
| Talkverse ID | client_id `kk`, 딥링크 `talkverse.kk://auth`, 이용권 lang `kk` |
| 스토어 상품 | iOS `com.talkverse.kk.lifetime` / Android `lang_kk` |
| 음성 | 기기 TTS 에 카자흐어 없음 → 번들 mp3(없음) + Azure `kk-KZ-AigulNeural`(`--dart-define`) |
| 포인트색 | 국기 하늘색 `#00AFCA`(글자용 `#00869B`) · 카드 금색 `#D9A50C` — 사이트 kk 페이지가 생기면 그 `--a`·`--a2` 로 |

## 5. 표시 언어 (한국어 / English / 日本語 / 中文) — 2026-09-12

- 프로필 · 설정 → 「언어 / Language」 를 탭할 때마다 한국어 → English → 日本語 → 中文 순으로 바뀐다.
  `AppLangPrefs`(`app/lib/core/l10n.dart`)가 값을 들고 있고, 바뀌면 `main.dart` 의 `MaterialApp` key 가 바뀌어
  앱 전체가 새로 그려진다(홈으로 돌아감).
- **UI 문구는 `tr('한국어')` / `trf('{0}개', [n])` 로 감싼다.** 번역은 `app/lib/core/l10n_dict.dart` 의
  `kDictEn` / `kDictJa` / `kDictZh` 에서 찾고, 없으면 한국어가 그대로 나온다.
  새 문구를 추가하면 세 사전에 한 줄씩 넣을 것. 키는 코드의 한국어 문자열 그대로(보간은 `{0},{1}` 템플릿).
- `tr()` 은 const 가 아니다 — `const Text(tr(...))` 처럼 쓰면 컴파일 오류. 그 위젯의 `const` 를 뺀다.
  enum 생성자·`static const`·`case` 패턴에는 못 쓴다(한국어를 두고 getter 에서 `tr()`).
- **회화·단어·문법 콘텐츠(뜻·번역·설명)는 번역 대상이 아니다** — 화면 문구(메뉴·버튼·안내)만 바뀐다.
- 사전은 12개 언어 앱이 공용(`_update_kit/l10n/l10n_dict.dart` 원본). 다른 앱에서 고친 번역이 있으면 원본도 같이 고칠 것.

## 6. 갤럭시·아이폰 공용 인터페이스 — 2026-09-12

- 플랫폼 판단은 `app/lib/core/platform.dart` 의 `isIOS` / `isAndroid` 만 쓴다(`dart:io` Platform 직접 호출 금지 — 웹·테스트에서 깨짐).
- **화면 아래 고정 버튼·목록 바닥 여백은 `bottomInset(context)` 를 더한다**
  (`EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset(context))`). 아이폰 홈 인디케이터(34pt)·갤럭시 제스처 바에 가려지지 않게.
  새 화면을 만들 때도 같은 규칙.
- 글자 확대 상한 1.2배(`main.dart` builder) — 아이폰 Dynamic Type 로 타일이 깨지는 것 방지.
- iOS 오디오: `TtsService` 와 `AudioService` 가 iOS 에서 재생 카테고리(playback)를 잡는다 — 무음 스위치에서도 소리가 난다. 지우지 말 것.
- 「앱 업데이트」 타일은 Android 전용(APK 설치 채널). iOS 는 TestFlight 안내 타일이 대신 나온다. `UpdateService.install` 은 Android 에서만 호출.

## 7. iOS 빌드 — 초안 (2026-09-12)

- `.github/workflows/ios-build.yml`: 푸시마다 GitHub macOS 러너가 **서명 없는** IPA 를 아티팩트로 올린다(동작 확인용).
- `.github/workflows/ios-testflight.yml`: 리포 Variables `IOS_TESTFLIGHT_ENABLED=true` 일 때만 돈다.
  Apple Developer Program(유료) 활성화 → App Store Connect API 키 → `tools/ios/make_ios_cert.py` 로 인증서·시크릿 생성 → 시크릿 등록.
  절차: `docs/ios-build-and-testflight.md`.
- `ios/Runner/Info.plist` 에 마이크·음성 인식 권한 문구가 있다(말하기 연습). 지우면 iOS 에서 크래시.
- `release.yml`(Android) 은 `ios/**`·`docs/**`·`tools/**` 만 바뀐 푸시는 건너뛴다.

## 8. Zealot 무선 설치 (apps.talkverse.uk)

- **Zealot 앱이름: 카자흐어유니버스** (2026-11-08 처음 올림. 바꾸면 Zealot 에 다른 앱이 새로 생긴다.)
- 올리기: `bash tools/zealot_push.sh ["변경 내용 한 줄"]` — `build/app/outputs/flutter-apk/` 의 가장 최근 release APK 를
  `~/bin/zealot-upload` 로 올린다(빌드는 하지 않음). 서명 SHA-1 이 §1 값과 다르면 올리지 않는다.
- 서명 = `android/key.properties` + `android/app/signing-key.jks`(M6 에 있음, 몽골어앱과 같은 키 SHA-1 `9C:C4:…:47:6B`). **M6 의 `~/.android/debug.keystore` 는 다른 키** — §1 의 `cp ~/.android/debug.keystore …` 를 M6 에서 실행하지 말 것.
- 로컬 빌드는 `--build-number=<CI 실행 번호보다 큰 값>`.

## 9. iOS TestFlight

- `bash tools/ios_release.sh` (백그라운드, 8~12분). 번들 ID `com.talkverse.kk`, 팀 `QP8QRMA9CC`, PC 백업 `D:\OneDrive\app project\kk_app\ios\`.
- App Store Connect 앱 레코드(사용자가 만듦): 이름 「카자흐어유니버스」 · 한국어 · 번들 ID `com.talkverse.kk` · SKU `kk-universe`.
