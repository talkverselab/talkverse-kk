# HANDOFF — talkverse-kk (카자흐어) — 2026-11-08

> 공통 지침 `~/talkverse/LANG_APP_REPLICATE_PROMPT.md`. 이름·서명·배포 규칙은 `app/CLAUDE.md`.
> **범위 = 소수언어(2026-11-08 사용자 결정, 몽골어와 같음)**: 절벽 단어 약 1,500, 회화 150편(R3 까지), 회화 흐름 Claude 초안 → Grok → Gemini 검수 → DB.

## 진행 단계

| 단계 | 상태 |
|---|---|
| 초기 빌드(앱 뼈대) | 2026-11-08 — 몽골어앱(`talkverse-mn` `afa1dc8`) 코드 복사, 콘텐츠 없음(`6cc00b7`). 아이콘 Қ·사이트 색(`f7969ee`) |
| GitHub | https://github.com/talkverselab/talkverse-kk (공개, master). 리포 시크릿 `ANDROID_DEBUG_KEYSTORE_BASE64` 등록, CI Release APK 성공 — 서명 SHA-1 `9cc4bc93…476b` 확인 |
| 절벽 구간 | **v1 산출** — R1 45 · R2 62 · R3 160 · R4 477, 1,500위 88.5%(`data/corpus/cliff_v1/README.md`, 앱 `lib/core/cliff.dart`, `31e87b7`). uk 가 사이트 반영 |
| 문자와 발음 | **2026-11-08** (`523da4d`, 공통 프롬프터 §5-3) — 키릴 42자 격자·묶음 칩·로마자, 발음 시트(1초 뒤 자동 재생·IPA·모음 위치·조음 그림·한국어 비교), 모음조화 표. 글자 소리 40개 번들 mp3 |
| 배포 | Zealot 빌드 4 https://apps.talkverse.uk/ABjlY/362 (로컬 빌드), PC 백업 `D:\OneDrive\app project\kk_app\`. **TestFlight 빌드 2611081655 업로드 성공**(2026-11-08 20:40, `523da4d` 내용) |
| ① 캐릭터 시안 · ② UX 시안 | 미착수(Grok 은 11-09 13:30 재개 — 한자 세션 경유) |
| 콘텐츠(단어·회화·접사 표) | 사용자 지시 뒤. 단어 목록은 외국 인명을 걸러 `talkversehanja` `talkverse_art/words/kk.csv`(mn.csv 형식)로 → uk 에 알림 |

## 만든 것
- 이름: 폴더 `~/talkverse/kk`, applicationId·번들 ID `com.talkverse.kk`, Zealot 「카자흐어유니버스」, client_id `kk`, 딥링크 `talkverse.kk://auth`, 상품 iOS `com.talkverse.kk.lifetime` / Android `lang_kk`.
- 메뉴: 기초(문자와 발음) → 문법 → 회화 → 단어 → 참고. 나머지 화면은 몽골어앱 그대로(회화 리더, 접사 사전, 동사 맵, 절벽 단어, 앱 소개, 프로필·로그인·결제).
- 문자와 발음: `lib/data/kk_letters.dart`(42자 IPA·로마자·설명·한국어 비교·모음 차트 좌표), `lib/screens/alphabet_screen.dart`, `lib/widgets/letter_sound_sheet.dart`, `lib/widgets/vowel_compare_chart.dart`(일본어앱에서 옮김), 조음 그림 `assets/images/ipa/places_of_articulation.png`(임시 — 출시 전 Grok 그림으로 교체, 출처 표기 넣지 않음 = 사용자 지시). 소리 = `tools/tts/letters_tts.py`(edge-tts `kk-KZ-AigulNeural`, venv `~/.venvs/kk-corpus`) → `assets/audio/letters/` + `assets/audio/manifest.json`.
- 비어 있는 데이터: 회화(`L1.json` episodes []), 단어(`kk_words.csv` 머리줄), 여행 단어·표현(themes []), 문법 레슨 없음, 접사 표 `kKkAffixes` [](모음조화 `harmonyOf` 는 카자흐어 앞/뒤 모음).
- 색: 사이트 kk 페이지 `--a #0a9fb0`(글자용 `#08808E`)·`--a2 #b3e3e8`, 카드 금색 `#D9A50C`. 아이콘 Қ(uk 세션 제작).
- 확인: `flutter analyze` 0, `flutter test` 15개 통과. 아이패드 스크린샷(시뮬레이터 `kk-shots-ipad` CCC1D5CC…, iOS 27.0) 홈·문자 격자·발음 시트 2·모음조화 넘침 0.

## 알아 둘 것
- 글자 소리는 사람이 들어 확인하지 않았다 — 모음 하나만 합성한 파일(ә·ө·ү 등)이 글자 이름으로 읽혔을 수 있음. 사용자가 폰에서 들어 보고 이상하면 `say` 를 음절(예 әә·өө)로 바꿔 `--force` 재합성.
- 홈 화면에 스페인어 템플릿 문구(「¡Hola!」 등)가 남아 있음 — 문구 정리는 콘텐츠 작업 때.
- 음성: 기기 TTS 에 카자흐어가 없음 → 번들 mp3 + (빌드 때 키를 주면) Azure 온라인. Azure 키는 지금 없음 — 회화 음성은 edge-tts 로 미리 합성하는 쪽이 현실적.
- 빌드 번호: 로컬 Zealot 빌드 4 까지 올림. CI 실행 번호(지금 2)가 이보다 작으니 Zealot 은 당분간 로컬 빌드로 `--build-number=<5 이상>`.
- 절벽 순위표 CSV 는 외국 인명이 섞여 저장소 밖 M6 `~/corpus/kk/out/lang_kk_top2500.csv`. 말뭉치·분석기 모델 `~/corpus/kk/`.
- 아이콘은 talkverse.uk 세션 담당 — 직접 고치지 말 것.

## 사용자가 할 일
1. TestFlight 내부 테스트 그룹에 빌드 2611081655 추가·설치 확인.
2. 폰에서 「문자와 발음」 소리 몇 개 들어 보기.
3. (나중) 개발자 포털 App ID `com.talkverse.kk` 에 Sign in with Apple, 스토어 인앱 상품(iOS `com.talkverse.kk.lifetime` / Android `lang_kk`).
