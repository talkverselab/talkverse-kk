# 스토어 설명·스크린샷 — 카자흐어유니버스 (초안 2026-11-09, 애플 지침 4.3 차별화)

기준: `~/talkverse/STORE_DIFFERENTIATION.md`(사용자 "엄청 중요해"). 몽골어유니버스와 같은 키릴 문자·교착어라 화면 틀이 비슷하다 — **4.3 위험이 특히 크다.** 그래서 설명·스크린샷은 몽골어에 없는 것(42자 중 고유 9자, 앞·뒤 모음 짝과 자음 짝 қ/к·ғ/г, 러시아어 낱말용 글자 구분)으로 시작한다.

> ⚠ **출시 불가 상태(2026-11-09)**: 회화·단어·문법 레슨·접사 표·주제 단어·표현이 비어 있다(빈 메뉴 = 지침 2.1). 아래 숫자 중 「(채울 것)」은 콘텐츠가 들어온 뒤 실측해서 바꾼다. 지금 출시 = 한자앱만, 언어앱은 완성된 것부터 하나씩(uk 공지).

## 이름·부제
- 이름: 카자흐어유니버스
- 부제(30자): 키릴 42자·모음조화로 여는 카자흐어 회화

## 설명(한국어)

```
카자흐어의 첫 벽은 러시아어에도 없는 9글자(ә ғ қ ң ө ұ ү һ і)와, 낱말마다 앞 모음·뒤 모음을 맞추는 모음조화입니다. 카자흐어유니버스는 42자를 소리 짝으로 묶고, 접사를 한국어 조사·어미에 맞대어 그 벽을 넘게 합니다.

■ 카자흐어에만 있는 학습 도구
· 문자와 발음 — 키릴 42자(카자흐어 고유 9자는 금색 표시, 러시아어 낱말에만 쓰는 글자는 따로). 글자를 누르면 원어민 발음, IPA, 소리 나는 곳, 한국어 모음과 위치 비교.
· 모음조화 짝 — а↔ә · о↔ө · ұ↔ү · ы↔і 와 자음 짝 қ↔к · ғ↔г 를 한 화면에. 한국어에 없는 ә·ө·ү·қ·ғ 를 「외」「위」「목 안쪽 ㅋ」처럼 한국어 소리에 비춰 설명.
· 접사 = 조사 — 격어미(-да·-дан·-ға·-ны·-ның·-мен)를 한국어 조사에 1:1로 맞추고, 문장의 접사를 색 블록으로 나눠 보여 줌. (채울 것: 접사 수)
· 어순 맞대기 — 카자흐어 문장과 한국어 문장의 낱말을 같은 순서로 맞대어 봄(둘 다 주어-목적어-동사).

■ 숫자로 보는 카자흐어유니버스
· 카자흐어 대사 약 60만 토큰으로 잰 빈도(접사를 따로 세어): 처음 45단위가 대사의 55%, 477단위면 80%. 이 「절벽」을 따라 R1~R5, 약 1,500단어를 20단어 단원으로.
· 이 앱만을 위해 쓴 회화 (채울 것)편·(채울 것)턴, 원어민 음성 (채울 것)줄.

■ 그 밖에
Talkverse 계정(선택)으로 아이폰·아이패드·안드로이드에서 이용권을 함께 씁니다. 광고·추적 없음. 이용권: 1개월·3개월·1년(자동 갱신)·평생(서비스 운영 기간 동안).
```

## 설명(영어, 필요 시)

```
Kazakh's first wall is the nine letters even Russian doesn't have (ә ғ қ ң ө ұ ү һ і) and vowel harmony — every word keeps to front or back vowels. Kazakh Universe groups all 42 Cyrillic letters into sound pairs and lines up Kazakh suffixes with Korean particles.
Kazakh-only tools: 42-letter chart (9 native letters highlighted, Russian-loan letters separated) with native audio, IPA, articulation and a Kazakh-vs-Korean vowel chart · harmony pairs а↔ә, о↔ө, ұ↔ү, ы↔і and consonant pairs қ↔к, ғ↔г · case suffixes mapped to Korean particles with colour blocks · word-order matching (both SOV).
Measured on ~600k tokens of Kazakh dialogue with suffixes counted separately: 45 units cover 55%, 477 cover 80% — ~1,500 words in 20-word units. (Episode/audio counts to be filled.) Optional Talkverse account, no ads, no tracking.
```

## 스크린샷(순서 — 첫 두 장은 카자흐어 고유 화면, 홈·프로필로 시작하지 않는다)
1. 문자와 발음 — 42자 격자(고유 9자 금색 테두리)
2. 글자 발음 시트 — ө: 카자흐어 vs 한국어 모음 위치 차트
3. 모음조화 짝 — а↔ә … + қ↔к·ғ↔г
4. 회화 재생 — 장면 그림 + 접사 색 블록(회화가 들어온 뒤)
5. 접사 사전 — 격어미 = 한국어 조사(접사 표가 들어온 뒤)
6. 절벽 단어 — R1~R5, 20어 단원
7. 앱 소개 — 절벽 표
크기: iPhone 6.9″ 1320×2868, iPad 13″ 2064×2752, Play 폰·태블릿. 1~3 은 지금 찍을 수 있다(`integration_test/dialogue_pane_test.dart` 의 18~21번 샷).

## 심사 메모 필수 문단(영어) — `review_notes.md` 에도 넣음
> This app is one of a family of language-specific apps by Universal Talking Lab (Talkverse). Each app is built from scratch for one target language for Korean speakers and is NOT a re-skin: the Kazakh app has its own script & pronunciation module (all 42 Kazakh Cyrillic letters with the 9 Kazakh-specific letters ә ғ қ ң ө ұ ү һ і highlighted, Russian-loan letters separated, native audio, IPA, articulation and a Kazakh-vs-Korean vowel chart), its own grammar tools (front/back vowel-harmony pairs and the қ/к, ғ/г consonant pairs, case suffixes mapped one-to-one to Korean particles with colour-coded suffix blocks), [N] original conversation episodes with recorded audio written for this language, and a vocabulary list measured from a Kazakh conversation corpus (45 units = 55% and 477 units = 80% of dialogue, suffixes counted separately). Content, curriculum and UI flows differ between apps; we keep them separate because learners search for and buy one language at a time.
