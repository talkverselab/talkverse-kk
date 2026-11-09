# 카자흐어 회화 Claude 초안 작성 규칙 (2026-11-09, 몽골어 규칙에서)

공통 원칙 https://talkverse.uk/talkverse/dialogue-rules/ (특히 §9) · 카자흐어 특이점 `docs/DIALOGUE.md` · 인물 `CHARACTERS.md`.
견본: `app/assets/data/dialogues/R1/love/r1_love_a1.json` (먼저 읽고 형식·톤을 맞출 것). 몽골어 초안 `~/talkverse/mn/app/assets/data/dialogues/` 는 형식 참고만(내용·농담을 베끼지 않는다).

## 일상 속에서 터지게 (사용자 지시 2026-11-09, 정정 반영)
- 반전·러브·플러팅은 비율 기준(카오스 30%+, 연애 편마다 심쿵) 그대로 **다 넣는다** — 줄이지 않는다.
- 다만 실제 일상 장면(가게·식당·길·집·학교·직장·약속·전화·메신저)과 그 자리의 실제 표현 흐름 속에서 터지게 한다. 장면의 흔한 표현이 먼저 오가고, 그 흐름에서 반전·설렘이 나온다.
- 일상과 동떨어진 비현실적 설정(동물 떼·건물 정전·경주 우승·수백 명·억지 우연)으로 반전을 만들지 않는다. 카오스는 「현실에서 있을 법하게 커지는 꼬임」(사과 1킬로가 3킬로로, 친구 한두 명이 더 옴, 단톡방에 잘못 보냄 정도).

## 파일
- 경로 `app/assets/data/dialogues/R<레벨>/<주제>/<편id>.json`, 들여쓰기 1칸 JSON, 끝에 줄바꿈. id = `r1_love_a1` 꼴(받은 배정의 id 그대로).
- 편 칸: `id region island kind(short|long|chat|survival) draft(true) purpose[] domain[] title(한국어) emoji scene(한국어 한 줄) speakers{A:"{name}", B:…, C:…} register(polite|casual|chat|mixed) twist(반전 턴 번호) twist_type flags[] expressions[] goal turns[]`.
- 턴 칸: `num speaker tl(카자흐어 키릴) rd("" — 검사기가 채움) ko note(핵심 낱말 한 줄, 「카자흐어 = 뜻」) tags[] new[] emotion` (+ 감정이 바뀌는 턴만 `segs`).
- 다 쓰면 `python3 tools/check_dialogues.py --fix-rd <자기 파일들>` → 오류 0 까지 고친다.

## 분량
- 턴 수 R1 6~8 · R2 8~12 · R3 12~16. 한 턴 낱말 수 R1 ≤7 · R2 ≤9 · R3 ≤12(키릴 낱말 기준). 1~2문장.
- R1 은 짧고 쉬운 문형, R2 는 이유·조건·과거 이야기, R3 는 감정·의견·완곡 표현까지.
- 1단어 턴은 반전 턴·마지막 턴·표현 풀 한마디(「Жарайды」「Шынымен бе?」 등)만.

## 톤 (가장 중요)
- 카자흐 사람이 실제로 쓰는 짧은 구어. 교과서체·번역투·설명 대사·다짐/감사로 끝내기 금지.
- 편마다 입에 남는 한 줄 + 코믹한 킥 1개 이상. 반전은 본론 후반에 1회(`twist` 턴).
- 표현 풀 `data/expressions/kk_top_expressions.csv` 에서 편마다 2개 이상(`expressions` 칸에 실제로 쓴 것을 풀의 표기 그대로 적는다).
- 연애·플러팅은 썸까지(12+), 편마다 심쿵 한 줄(마음을 들키는 말·말끝 흐리기·여운, emotion shy/gentle). **여성이 먼저 다가가는 편을 더 많이.**
- SNS·채팅·데이팅앱 장면을 많이(kind `chat`, register `chat`, 이모지 가능).
- 말투: 처음 보는 사이·가게·일 = Сіз(존대), 친구·연인 = Сен(반말). 가까워지는 전환 장면도 가끔. 한국어 번역도 같은 말투.
- A 는 학습자 `{name}`(국적 비고정, 성별이 드러나지 않게 — 한국어 번역에 오빠·누나·형 금지, 카자흐어도 성별 드러나는 호칭 피함). 이름이 필요하면 `{name}`.
- 실존 인물·가게·브랜드·작품 이름 금지(지어낸 이름만). 술은 드물게(flags `alcohol`).

## 반전 유형(twist_type, 편마다 하나)
chaos(일이 커짐) · slip(말실수·오해) · reveal(의외 사실) · emotion(심쿵·감정) · ignore(읽씹).
받은 배정의 개수를 지킨다.

## 감정(emotion) — 턴마다
neutral polite stiff cheerful amused teasing excited surprised shout tsukkomi annoyed sad worried flustered shy gentle.
neutral 만 쓰지 말 것(편의 절반 넘으면 검사기 오류). 점원 안내 polite, 츳코미 tsukkomi, 심쿵 shy·gentle.
한 턴에서 감정이 바뀌면 `segs: [[감정, 본문], …]`, 이어 붙이면 tl 과 같아야 한다(4글자 미만 조각 만들지 말 것). 음성(TTS)이 이 감정을 읽는다.

## 카자흐어
- 표준 카자흐어(키릴 42자). 모음조화·격어미를 정확히(-да/-де/-та/-те, -дан/-ден/-нан/-нен/-тан/-тен, -ға/-ге/-қа/-ке, -мен/-бен/-пен …). 의문 첨사 ма/ме/ба/бе/па/пе 구분.
- 러시아어 섞기는 일상 외래어(кофе·такси·метро·телефон 등)까지만. 확실하지 않은 표현은 더 쉬운 확실한 표현으로.
- 명령·부탁: -ыңыз/-іңіз + -шы/-ші(Беріңізші), 권유 -йық/-йік·-айық/-ейік.
