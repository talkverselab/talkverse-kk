# HANDOFF — talkverse-kk (카자흐어) — 2026-11-09

> 공통 지침 `~/talkverse/LANG_APP_REPLICATE_PROMPT.md`. 이름·서명·배포 규칙은 `app/CLAUDE.md`.
> **범위 = 소수언어(2026-11-08 사용자 결정, 몽골어와 같음)**: 절벽 단어 약 1,500, 회화 150편(R3 까지), 회화 흐름 Claude 초안 → Grok → Gemini 검수 → DB.
> **출시 = Talkverse 통합 앱 하나(com.talkverse.app)** — 이 저장소는 통합 앱이 패키지(`app/`, 이름 `kk_app`)로 가져간다. 단독 앱 빌드(Zealot·TestFlight)는 개발·시험용으로 그대로 유지.

## 진행 단계

| 단계 | 상태 |
|---|---|
| 초기 빌드 | 2026-11-08 — 몽골어앱 코드 복사, 콘텐츠 없음(`6cc00b7`). 아이콘 Қ·사이트 색(`f7969ee`) |
| GitHub | https://github.com/talkverselab/talkverse-kk (공개, master). 리포 시크릿 `ANDROID_DEBUG_KEYSTORE_BASE64`, CI Release APK 동작 — 서명 SHA-1 `9cc4bc93…476b` |
| 절벽 구간 | v1 — R1 45 · R2 62 · R3 160 · R4 477, 1,500위 88.5%(`data/corpus/cliff_v1/`, `lib/core/cliff.dart`, `31e87b7`). 사이트 반영됨 |
| 문자와 발음 | `523da4d` — 키릴 42자 격자·묶음 칩·로마자, 발음 시트(자동 재생·IPA·모음 차트·조음 그림·한국어 비교), 모음조화 표, 글자 소리 40개 |
| 가격·결제 | `1ff96bc` — `lang_kk_1m·3m·1y·life` + `all_1y·all_life`, 정가 취소선·출시 기념 30%, 규정 표기·복원·약관/방침 링크(결제·로그인·설정). 스토어 문서 `app/docs/store/listing.md`·`review_notes.md`(4.3 필수 문단)·`app/docs/STORE_PRODUCTS.md` |
| 통합 앱 연결 준비 | `330a573` — `lib/embed.dart`(embedInit·embedApp), `lib/core/embed_env.dart`(assetPath·pk), 저장 이름 `kk_` 접두(단독 앱은 옛 키·`art` 폴더 1회 이전), 통합 모드 clientId `talkverse`·로그아웃은 tv_* 만, 결제 스트림 분리(`Purchase.onPurchaseUpdates`, lang_kk_*·all_* 만), 「다른 언어 배우기」. drift 2.34.4·drift_flutter 0.3.1·sqlite3_flutter_libs 0.6.0+eol. uk 가 연결 — **통합 앱 빌드 4(12개 언어) https://apps.talkverse.uk/IfB4M/419 에 포함** |
| 배포(최신) | Zealot 빌드 6 https://apps.talkverse.uk/ABjlY/413 (로컬 빌드) · TestFlight 2611091205 |
| ① 캐릭터 시안 · ② UX 시안 | 미착수 — Grok 은 직접(한자 세션 대행 중단 2026-11-09): 자기 크롬을 켜고 M4 `~/talkverse-uk/tools/grok_cookie_sync.py 9231 <포트>` 로 쿠키 동기화, 도구는 M6 `~/Hanja/tools/grok_req.py`·`grok_cdp.py` 복사. uk 의 Grok 방은 건드리지 않음 |
| 회화 | **Claude 초안 150편 완료(검수 전, 2026-11-09)** — R1 90 · R2 36 · R3 24, 카오스 33%, 모든 턴 감정 열. 상태·다음 순서·원어민 확인 목록 `docs/DIALOGUE.md`. **Grok 카자흐어 점검 150편 끝(2026-11-09, 사용자 선택 「점검만」)** — 고친 줄 3(`data/grok/check_fixes.md`), Grok 이 한국어 칸(ko·note·scene)에 키릴을 섞는 일이 잦아 반영 전 원문으로 되돌림. 다음: 원어민 확인 표현 목록 Grok 질의 → 겹치는 농담 정리 → Gemini 검수(사용자 지시 때) |
| 콘텐츠(단어·문법·접사 표) | 사용자 지시 뒤. 단어 목록은 외국 인명을 걸러 `talkversehanja` `talkverse_art/words/kk.csv`(mn.csv 형식) → uk 에 알림 |

## 출시 판단
- **지금은 출시 불가** — 회화·단어·문법 레슨·접사 표·주제 단어·표현 메뉴가 비어 있다(지침 2.1). 출시 순서 = 한자앱 → 완성된 언어앱부터 하나씩(uk 공지).
- 4.3 위험이 큼(몽골어와 구조 비슷) — 스토어 설명·스크린샷은 고유 9자·모음조화 짝·қ/к·ғ/г 로 시작(`listing.md`). 숫자 「(채울 것)」은 콘텐츠 뒤 실측.

## 만든 것(파일)
- 이름: applicationId·번들 ID `com.talkverse.kk`, Zealot 「카자흐어유니버스」, client_id `kk`(통합 모드 `talkverse`), 딥링크 `talkverse.kk://auth`.
- 메뉴: 기초(문자와 발음) → 문법 → 회화 → 단어 → 참고.
- 문자와 발음: `lib/data/kk_letters.dart`, `lib/screens/alphabet_screen.dart`, `lib/widgets/letter_sound_sheet.dart`, `lib/widgets/vowel_compare_chart.dart`, 조음 그림 `assets/images/ipa/places_of_articulation.png`(임시 — 출시 전 Grok 그림으로 교체, 출처 표기 넣지 않음 = 사용자 지시). 소리 = `tools/tts/letters_tts.py`(edge-tts `kk-KZ-AigulNeural`, venv `~/.venvs/kk-corpus`).
- 비어 있는 데이터: `L1.json` episodes [], `kk_words.csv` 머리줄, vocab themes [], 문법 레슨 없음, `kKkAffixes` [].
- 확인: `flutter analyze` 0, `flutter test` 19개 통과(넘침·결제 시트·저장 이름 이전).

## 알아 둘 것
- 새 코드에서 SharedPreferences 키·기기 폴더는 `pk('이름')`(kk_ 접두), 에셋은 `assetPath('assets/…')`, 음성 AssetSource 는 플레이어 `audioCache` 접두로. 학습자 이름·성별·표시 언어·로그인만 접두 없이 공유.
- 글자 소리는 사람이 들어 확인하지 않았다 — ә·ө·ү 등 모음 하나만 합성한 파일이 글자 이름으로 읽혔을 수 있음. 이상하면 `say` 를 바꿔 `letters_tts.py --force`.
- 홈 화면에 스페인어 템플릿 문구(「¡Hola!」 등) 남아 있음 — 콘텐츠 작업 때.
- 빌드 번호: 로컬 Zealot 빌드 6 까지. CI 실행 번호가 아직 작으니 Zealot 은 로컬 `--build-number=<7 이상>`.
- 절벽 순위표 CSV 는 외국 인명이 섞여 저장소 밖 M6 `~/corpus/kk/out/lang_kk_top2500.csv`(말뭉치·분석기 모델 `~/corpus/kk/`).
- iOS 빌드 뒤 pbxproj·xcscheme·xcworkspace·swiftpm 잡음은 되돌린다. 아이콘은 uk 세션 담당.
- 2026-11-09 M6 디스크가 가득 차 명령이 한때 멈췄다 — 빌드 전 `df -h ~` 확인.

## 사용자가 할 일
1. TestFlight 빌드 2611091205 설치 확인, 「문자와 발음」 소리 몇 개 들어 보기.
2. (출시를 정할 때) 스토어 상품 등록 — `app/docs/STORE_PRODUCTS.md`. 개발자 포털 App ID 에 Sign in with Apple.
3. 결제 시트에서 종합 평생 정가(469,000) 취소선을 보일지 결정(PRICING.md 「할인 없음」과 일본어앱 표기가 다름 — 지금은 일본어앱과 같이 표시).

## 작업 규칙(2026-11-09 uk 경유 사용자 지시)
- **Grok 프롬프트 최소화**: 공통 규칙(화풍·인물·구도)은 저장소 문서에 한 번만 적고, 방 첫 메시지에서 "앞으로 파일 이름 한 줄만 보낸다"고 약속한 뒤 채팅은 한 줄씩. 그림이 처음과 달라지면 최초 통과 그림을 기준으로 맞춘다(이미 만든 것은 그대로).
- **회화에 감정 열**: 회화를 만들 때 줄마다 음성(TTS)에 쓸 감정 열을 넣는다.
- **회화는 일상 속에서 터지게**(2026-11-09 정정 반영): 반전·러브·플러팅은 비율 기준대로 다 넣는다(줄이지 않음). 다만 가게·식당·길·집·학교·직장·약속·전화 같은 실제 일상 장면과 그 자리의 실제 표현 흐름 안에서 터지게 하고, 일상과 동떨어진 비현실적 설정·판타지로 가지 않는다. 원칙 페이지 §9 https://talkverse.uk/talkverse/dialogue-rules/
- **Grok 은 PC 에서**: PC 크롬 포트 9257(프로필 `D:\chrome-grok\kk`, M4 `GROK_CHROME_PORTS.md` 에 배정). PC 작업 스케줄러 등록은 권한 정책에 막힘 → 사용자가 PC 에서 크롬을 띄운 뒤 M4 터널 + `grok_cookie_sync.py 9231 9257`. 한도는 공유라 회차는 작게.
