# HANDOFF — talkverse-kk (카자흐어) — 2026-11-08

> 공통 지침 `~/talkverse/LANG_APP_REPLICATE_PROMPT.md`. 이름·서명·배포 규칙은 `app/CLAUDE.md`.
> **범위 = 소수언어(2026-11-08 사용자 결정, 몽골어와 같음)**: 절벽 단어 약 1,500, 회화 150편(R3 까지), 회화 흐름 Claude 초안 → Grok → Gemini 검수 → DB.

## 진행 단계

| 단계 | 상태 |
|---|---|
| 초기 빌드(앱 뼈대) | 2026-11-08 — 몽골어앱(`talkverse-mn` `afa1dc8`) 코드 복사, 콘텐츠 없음. 로컬 커밋 `6cc00b7`. Zealot https://apps.talkverse.uk/ABjlY/341 (0.1.0 빌드 2, 로컬 빌드 — 아이콘 Қ·사이트 색), PC 백업 `D:\OneDrive\app project\kk_app\kk_app-latest.apk` |
| GitHub | **미생성** — `talkverselab/talkverse-kk` 공개 저장소 만들기가 세션 권한 정책에 막힘(사용자 확인 필요). 만든 뒤: `git remote add origin …` → push → 리포 시크릿 `ANDROID_DEBUG_KEYSTORE_BASE64`(= `app/android/app/signing-key.jks` base64) 등록 |
| iOS | 아카이브·서명 export 성공(빌드 2611081442, 번들 ID 포털 자동 등록, PC 백업 `kk_app\ios\`) — **업로드는 App Store Connect 앱 레코드가 없어 실패**. 레코드가 생기면 `bash app/tools/ios_release.sh` 다시(아이콘·색 반영된 새 빌드) |
| ① 캐릭터 시안 · ② UX 시안 | 미착수 |
| 절벽 구간 | **2026-11-08 산출** — R1 45 · R2 62 · R3 160 · R4 477, 1,500위 88.5%(`data/corpus/cliff_v1/README.md`, 앱 `lib/core/cliff.dart`). uk 에 전달 |
| 콘텐츠(단어·회화·접사 표) | 사용자 지시 뒤 |

## 만든 것
- 이름: 폴더 `~/talkverse/kk`, applicationId·번들 ID `com.talkverse.kk`, Zealot 「카자흐어유니버스」, client_id `kk`, 딥링크 `talkverse.kk://auth`, 상품 iOS `com.talkverse.kk.lifetime` / Android `lang_kk`.
- 메뉴·화면은 몽골어앱 그대로(문법 → 회화 → 단어 → 참고, 회화 리더, 접사 사전, 동사 맵, 절벽 단어, 앱 소개, 프로필·로그인·결제). 메뉴 부제는 카자흐어 낱말(Жалғау·Етістік·Диалог·Сөз …).
- 비어 있는 데이터: 회화(`L1.json` episodes []), 단어(`kk_words.csv` 머리줄), 여행 단어·표현(themes []), 문법 레슨 없음, 음성 없음, 접사 표 `kKkAffixes` [] (모음조화 `harmonyOf` 는 카자흐어 앞/뒤 모음으로 바꿈), 절벽 경계는 산출함(위 표).
- 색: 사이트 kk 페이지 `--a #0a9fb0`(글자용 `#08808E`)·`--a2 #b3e3e8`, 카드 금색 `#D9A50C`. 아이콘 Қ(uk 세션 제작).
- 확인: `flutter analyze` 0, `flutter test` 11개 통과(300~1024 폭 넘침 없음). 아이패드 스크린샷은 아직(콘텐츠가 없어 빈 화면).

## 알아 둘 것
- 홈 화면에 몽골어앱에서 온 스페인어 템플릿 문구(「¡Hola!」 등)가 남아 있음 — 문구 정리는 콘텐츠 작업 때.
- 음성: 기기 TTS 에 카자흐어가 없어 몽골어앱처럼 번들 mp3 + Azure `kk-KZ-AigulNeural`(빌드 때 `--dart-define=AZURE_SPEECH_KEY`) 구조. 지금은 음성 없음.
- 로컬 빌드 번호 2 까지 Zealot 에 올렸다. CI 가 생기면 실행 번호가 작다 → 처음 몇 번은 로컬에서 `--build-number=<3 이상>` 으로 올리거나 CI 번호가 넘을 때까지 기다린다.
- 아이콘은 talkverse.uk 세션 담당(Қ, 2026-11-08) — 직접 고치지 말 것.

## 사용자가 할 일
1. GitHub 공개 저장소 `talkverselab/talkverse-kk` 생성 허락(또는 직접 생성).
2. App Store Connect 앱 레코드: 이름 「카자흐어유니버스」 · 기본 언어 한국어 · 번들 ID `com.talkverse.kk` · SKU `kk-universe` → TestFlight 내부 테스트 그룹에 본인 추가. 그 뒤 `bash app/tools/ios_release.sh`.
3. (나중) 개발자 포털 App ID `com.talkverse.kk` 에 Sign in with Apple, 스토어 인앱 상품.
