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
| 배포(최신) | Zealot 빌드 9 https://apps.talkverse.uk/ABjlY/655 (2026-11-23 03:3x, PC 백업 kk_app) · TestFlight 2611230337 |
| ① 캐릭터 시안 · ② UX 시안 | 미착수 — Grok 은 직접(한자 세션 대행 중단 2026-11-09): 자기 크롬을 켜고 M4 `~/talkverse-uk/tools/grok_cookie_sync.py 9231 <포트>` 로 쿠키 동기화, 도구는 M6 `~/Hanja/tools/grok_req.py`·`grok_cdp.py` 복사. uk 의 Grok 방은 건드리지 않음 |
| 회화 | **Claude 초안 150편 완료(검수 전, 2026-11-09)** — R1 90 · R2 36 · R3 24, 카오스 33%, 모든 턴 감정 열. 상태·다음 순서·원어민 확인 목록 `docs/DIALOGUE.md`. **Grok 카자흐어 점검 150편 끝(2026-11-09, 사용자 선택 「점검만」)** — 고친 줄 3(`data/grok/check_fixes.md`), Grok 이 한국어 칸(ko·note·scene)에 키릴을 섞는 일이 잦아 반영 전 원문으로 되돌림. 다음: 원어민 확인 표현 목록 Grok 질의 → 겹치는 농담 정리 → Gemini 검수(사용자 지시 때) |
| 콘텐츠(단어·문법·접사 표) | 사용자 지시 뒤. 단어 목록은 외국 인명을 걸러 `talkversehanja` `talkverse_art/words/kk.csv`(mn.csv 형식) → uk 에 알림 |

## 출시 판단
- **2026-11-22: 콜드 출시 가능 상태** — 모든 메뉴에 내용 있음(아래 11-22 절). 통합 앱 심사(11-23)에 22개 언어 전부 들어감(uk). ~~지금은 출시 불가~~(11-09 기록). 출시 순서 = 한자앱 → 완성된 언어앱부터 하나씩(uk 공지).
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
- **Grok 답은 3분까지만(사용자 지시 2026-11-10)**: 넘으면 그 대화의 생성을 중지(토큰 낭비 방지) — `tools/grok/grok_text.py` 가 180초 상한·중지 단추/Escape 로 처리.
- **Grok 은 PC 에서**: PC 크롬 포트 9257(프로필 `D:\chrome-grok\kk`, M4 `GROK_CHROME_PORTS.md` 에 배정). PC 작업 스케줄러 `Grok-Chrome-kk-9257`(john, 2026-11-18 사용자 허락으로 등록) → M4 에서 `ssh -fN -L 9257:127.0.0.1:9257 pc` + `grok_cookie_sync.py 9231 9257`. 모델은 「빠른」(11-18). 한도는 공유라 회차는 작게.

## 현재 상태·다음 할 일 (2026-11-10 세션 종료 시점)
- 회화 150편: Claude 초안 → Grok 카자흐어 점검 완료(고친 줄 3, 원어민 확인 111줄 질의 지적 1건 원문 유지), r1_love_a23 은 찻잔 농담 겹침으로 「짠 밀크티」로 새로 씀(Grok 미점검).
- **Gemini 검수 0/150 — 다음 할 일 1순위.** 도구·150편 프롬프트 준비 끝(`tools/grok/gemini_send.py`·`gemini_batch.py`·`gemini_probe.py`·`gemini_wait_run.sh`, 틀 `tools/prompts/review_gemini_kk.md`, `data/review/dialogues/prompts/`). 재개: 사용자가 PC 크롬 9257(`D:\chrome-grok\kk`)에 구글 로그인 + 3.1 Pro 선택 → M6 `ssh -o BatchMode=yes -f -N -L 9257:127.0.0.1:9257 Administrator@100.127.143.37` → `bash tools/grok/gemini_wait_run.sh > data/review/dialogues/log.txt`(한 번에 한 건·60초 간격, BLOCKED/BADMODEL 이면 멈춤). 11-09 밤 uk 가 이 크롬 쿠키를 다른 크롬으로 복사하다 구글 세션이 끊김 — 쿠키 복사로 로그인하지 말 것.
- 그 뒤: 지적 반영(실제 오류만) → 사용자 리뷰 → 로더를 R 구조로 옮기고 빌드(Android·iOS 함께) → 장면 컷(아트 저장소 `talkverse_art/scene/kk/<편>/cutN.jpg`) → 회화 음성(D1 `audio_lines` + R2 `audio/kk/…`, 표준 `~/talkverse/ja/docs/DIALOGUE_AUDIO.md`).
- 단어 그림: talkversehanja `talkverse_art/words/kk.csv`(1,190, 그림 가능 327)·`kk_food.csv`(50) 푸시(17ec8a46) → uk 가 178장(겹치지 않는 128 + 음식 50) 공개 완료.
- DB: 회화 본문은 D1 표 없음(앱 에셋·저장소가 정본), 음성·장면 컷은 아직 없음 → 올린 것 0.
- Grok 은 주간 한도(11/16 초기화)까지 쓰지 말 것, 쓸 때는 답 3분 상한.
- 11-10 디스크 정리: app/build·.dart_tool·android/.gradle·ios/Pods·__pycache__ 삭제(다음 빌드 전 `flutter pub get`·`pod install`). 터널·Grok/Gemini 탭은 닫음.

## 2026-11-22 — 콜드 출시 준비(사용자 「막힌 것은 각자 판단대로 완료」, 빌드 범위 「콜드출시 가능할 때까지」 — uk 경유)
세션이 스스로 고른 것(사용자 확인 전):
- **회화 = Grok 대사 45편만**(급마다 30%: R1 27·R2 11·R3 7, 반전·형식 고르게 `data/grok/rewrite_45.txt`). 2026-11-18 원칙대로 Claude 초안 150편은 `data/drafts/` 로 빼 앱에 넣지 않음. 「빠른」 모드는 초안 대사를 첨부하면 베끼므로 대사 칸을 비운 뼈대(`tools/grok/brief.py`)를 보냄. 나머지 105편을 Grok 으로 쓸지는 사용자 결정 대기.
- **사용자 리뷰는 건너뜀**(uk: 「사용자 리뷰 — 그냥 진행」). Gemini 검수는 M4 9226(chrome-grok-vi, 구글 로그인된 공용 프로필)에서 페르시아어 다음 차례 — fa 가 「9226 끝」을 보내면 `GEMINI_CDP_PORT=9226 /usr/bin/python3 tools/grok/gemini_batch.py data/review/dialogues/list.tsv -j 1 --gap 60`(M6→M4 `ssh -fN -L 9226:127.0.0.1:9226 macmini4`), 끝나면 9226 크롬을 끈다. 지적 중 실제 오류만 Grok 에 다시 쓰게 해 반영(Claude 가 대사를 고치지 않음).
- **서버 원고**: ScriptSync(일본어앱 빌드 113·114) 이식, `assets/data/script_rev.json` 은 rev 0 자리표 — Gemini 반영 뒤 `cd app && python3 tools/script_publish.py --init` 으로 rev 1 올리고 커밋(R2 `script/kk/`, 읽는 주소 `https://auth.talkverse.uk/art/script/kk/…`).
- **빈 메뉴 채움**: 단어표 1,190(talkversehanja kk.csv) · 주제 단어(품사별 빈도순 + 음식 50) · 표현 66 · 접사 18(표준 문법 규칙) · 동사 80 활용(규칙 생성, 불규칙 есту, 단어표의 шықу 철자는 동사표에서만 шығу 로) · 언어감각 7급(문장은 Grok 회화에서 `tools/build_sense_course.py`, 설명만 한국어, 영상 없음 = 「영상 준비 중」).
- **장면 컷 10장**: 캐릭터 시트가 없어 시트 1 + 컷 10(3편 4+3+3). uk 그림 순서 ru → ar → hi → **kk** → my → pt, 힌디어앱의 「Grok 끝」이 시작 신호, 끝나면 크롬 끄고 「Grok 끝」을 uk·미얀마어앱에. 통과는 세션 판단.
- 음성은 새벽 01:00~07:00 만(전역 규칙) — 아직 없음.

남은 것: Gemini 45편 → 반영 → 서버 --init → 시트·장면 컷 → 빌드(Zealot·TestFlight, 빌드 번호 7 이상) → uk 에 통합 앱 연결 한 줄(커밋·`kk_app`·새 의존성 video_player·crypto·새 에셋 script_rev.json·grammar/·rev).

## 2026-11-22 저녁 — 결과·남은 것
- **Gemini 검수 44/45 끝**(Gemini 4 **Neon** — 3.1 Pro 가 없어짐, M4 9226, 결과 `data/review/dialogues/<id>_gemini.md`). 남은 1편 `r3_work_a2` — Neon 한도가 22:45 에 초기화돼서 남김. 9226 크롬은 끔(M4 0개).
  - 새 탭이 「자동」 모드로 떠서 `tools/grok/gemini_send.py` 가 선택기에서 Neon 을 고르게 고침(`GEMINI_MODE` 로 바꿀 수 있음, 카본은 클릭해도 안 바뀜). 백그라운드 작업이 두 번 죽어 배치는 `screen -dmS kk-gemini` 로 돌림.
  - 지적 수(①문법·③말투·④한국어·⑤풍습): 31·19·39·29, ②「교과서체」는 거의 모든 편. Gemini 의 문법 지적 중 틀린 것도 있음(түсу+탈격 강요, келмейді ме, рахмет 표기).
- **Grok 반영 아직** — 도구 준비 끝: `zsh tools/grok/fix_run.sh data/grok/fix_list.txt`(규칙 `tools/prompts/fix_grok_kk.md`: Grok 이 동의하는 실제 오류만 다시 씀, 취향 지적은 둠) → `python3 tools/grok/fix_apply.py --write` → `python3 tools/check_dialogues.py --fix-rd` → `python3 tools/build_sense_course.py` → `python3 tools/build_legacy_levels.py` + version.json db+1 → `cd app && python3 tools/script_publish.py --publish`(rev 2, 깔린 앱이 받음). **PC 크롬이 막혀 멈춤**: 18:16 재부팅 뒤 D: 디스크 과부하(uk 추정) — pl·hu·kk·mn 크롬 모두 grok.com 빈 화면. uk 가 「PC 크롬 풀림」을 보내면 pl → hu → kk → mn 순서로 켬. 켜기 전 9231→9257 쿠키 동기화·빠른 모드.
- **서버 원고 rev 1** 올림(46 파일, `https://auth.talkverse.uk/art/script/kk/index.json` 200).
- **장면 컷 12장 게시**(`/art/kk/scene/manifest` count 12) — `ssh macmini4 'zsh -lc "cd ~/talkverse-uk && /usr/bin/python3 tools/grok_art.py scene kk"'` 로 직접(uk 허락). 다음에 컷을 푸시하면 uk 에 「art 당겨 주세요」.
- **심사 전 빈 화면 정리**(`e2a18c4`): 학습 탭 = R 회화 목록(옛 L 목록은 전 급 「준비 중」이었음), 문장 카드·말하기·청크 검색·오늘의 학습은 옛 `L1~L3.json`(DB turns)만 읽어 비어 있었음 → `tools/build_legacy_levels.py` 가 R 회화에서 생성(441문장). 회화를 바꾸면 이 스크립트 + version.json db+1. 영상 칸은 주소 있을 때만.
- 빌드: Zealot 7 · TestFlight 2611221913.
- 사용자 결정 대기: 나머지 105편 Grok 작성 여부. 음성은 새벽만(아직 없음).

## 2026-11-23 새벽 — 60편·음성·커리큘럼·문법 서버
- **회화 60편**(사용자 「카자흐어 60편만 우선 완성」): 초안 105편 중 15편(R1 3·R2 6·R3 6, `data/grok/rewrite_15.txt`)을 M4 크롬 9257(`~/chrome-grok-kk`, `GROK_HOST=m4`)에서 Grok 빠른 모드로 → 앱(R1 30·R2 17·R3 13). 서버 원고 **rev 2**(61 파일). 나머지 90편은 그 뒤(사용자).
- **회화 음성 60편 1240줄**: Azure kk-KZ(Aigul·Daulet) 작업 기계에서 미리 생성 `doppler run -p keys -c prd -- python3 tools/tts/azure_pack.py <편…|all> --upload`(R2 audio/kk + D1 audio_lines). 앱은 `DialogueAudio`(서버 녹음이 지금 대사와 같을 때) → 기존 합성. 키는 앱에 넣지 않음(uk). 대사가 바뀐 편은 그 편만 다시.
- **토크버스 커리큘럼**: 일본어 기준(ja ceb91c3) 옮김 + 칩 줄 Wrap(c941757). 홈 카드로 보임(사용자 「넣어야지」). AI 회화 작성은 `kCustomScriptLive=false` 숨김.
- **언어감각 10급**: L8~10 은 Claude 작성(`data/sense/claude_levels.json`, 사용자 「언어감각 10급은 클로드로만」), 빈 스텝 숨김 + 서버 목록 그대로(테스트 `test/grammar_server_test.dart`).
- **Gemini 자동 이어 돌리기**: screen `kk-gem-auto`(`tools/grok/gemini_auto.sh`) — 검수 안 된 편(지금 16: r3_work_a2 + 새 15)을 M4 9226 에서, 남이 쓰면 30분 뒤, 한도면 1시간 뒤, 0 이면 끝. `data/review/dialogues/WAIT` 가 있으면 멈춤. 9226 은 00:05 에 로그아웃이었다가 hu 가 복구했다고 알림(사용자 허락이라고 hu 전언).
- **보류(uk 「재개」 전 Grok 금지)**: 옛 45편 Gemini 지적 반영 41편(3편은 `data/grok/fix/` 에 받음, 도구 `fix_run.sh`·`fix_apply.py`).
- 빌드: Zealot 8 · TestFlight 2611230007. iOS 는 디스크 10GB↑·`pgrep -x xcodebuild` 확인 후, 끝나면 build/ 삭제(uk 규칙).

## 2026-11-23 03시 — Gemini 60편 검수·Grok 반영 끝
- 사용자 「그록사용해!」 → 옛 45편 Gemini 지적 Grok 반영 140줄 + 새 16편 48줄(M4 9257 `GROK_HOST=m4`, `tools/grok/fix_run.sh` → `fix_apply.py --write`, 둔 지적은 이유와 함께 `data/grok/fix/applied.md`). 지난 expressions 정리, 서버 원고 **rev 4**, db 7, 바뀐 편 음성 다시(1240줄).
- Gemini 60편 검수 끝(9226, 사용자가 직접 로그인 — 쿠키 복사는 실패·금지). `gemini_send.py` 는 「로그인」 단추가 보이면 LOGGEDOUT 으로 물러남. 자동 예약 screen `kk-gem-auto` 는 WAIT 로 멈춰 둠(남은 편 0).
- 남은 것: 나머지 초안 90편(사용자 결정), 원어민 확인.

## 2026-11-28 — 세션 닫음(uk 「베트남어·일본어만 남기고 언어 세션 닫음」, 사용자 지시)
- **다시 열면 먼저** `~/talkverse/CHANGES.md`(전 앱 변경·공지) 를 읽는다.
- **끝난 상태**: 회화 60편(Gemini 검수·Grok 반영·음성 1240줄), 서버 원고 rev 5, 커리큘럼 JSON rev 2, 이용권(PAYWALL_SPEC)·로그인 제공자·iOS 시작 복원 끔·심사 수정(87095c4). 「데이팅앱」→「언어교류앱」(c6a7123): 앱·서버 원고엔 원래 없음, 초안 1곳·작성 프롬프트만 바꿈, 대사 목록 0줄, rev 그대로.
- **켜 둔 것 없음**: Grok·Gemini 크롬·터널·screen 루프·예약 0(PC 작업 스케줄러 `Grok-Chrome-kk-9257` 는 등록만, 트리거 없음). 음성·그림·빌드 백그라운드 없음.
- **멈춤 규칙(uk 전달, 사용자 말할 때까지)**: Grok 전부 중지(11-26), Gemini 는 베트남어만(11-25), 단어 작업·단어 그림 베트남어만(11-25), 회화 그림은 공개 편만. 첫 출시 언어 = 베트남어.
- **커밋 안 한 변경(중간 산출물, 일부러 둠)**: `data/review/dialogues/prompts/*.md` 55·`list.tsv`(gemini_prompts.py 가 다시 만든 검수 프롬프트), `data/grok/brief/*.json` 15(초안 재작성 브리프), `.wrangler/`·`app/.wrangler/`(캐시 — 지울 후보). 필요 없으면 `git checkout -- data/review/dialogues` 로 되돌려도 됨.
- **사용자에게 물을 것**: 남은 초안 90편(R1 60·R2 19·R3 11 쪽, `data/drafts`)을 Grok 으로 다시 쓸지 — Grok 중지가 풀린 뒤에만 가능. 원어민 확인 목록(`docs/DIALOGUE.md`).
- 마지막 빌드: Zealot 9(https://apps.talkverse.uk/ABjlY/655)·TestFlight 2611230337 — 11-23 오후 수정(이용권·로그인·복원)은 단독 빌드엔 아직 없음(통합 앱 1.0.0+15 에 묶임).
