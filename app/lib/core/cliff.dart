/// 카자흐어 절벽 값 — 코드 한 곳(단어 화면·앱 소개가 함께 쓴다).
/// 2026-11-08 산출(`tools/corpus/cliff_kk.py`, 결과 `data/corpus/cliff_v1/`): 공개 자막 167편·59.6만 토큰,
/// 누적 55/60/70/80%에 처음 닿는 순위. 격접사·어미는 각각 한 토큰, 동사는 사전형(-у).
/// 범위 = 소수언어(몽골어와 같음): 단어 목록 약 1,500 → R5 는 1,500위에서 끊는다(1,500개 누적 88.5%).
const bool kCliffReady = true;
const List<int> kCliffs = [45, 62, 160, 477];
const int kWordCap = 1500;
const double kWordCapPct = 88.5;
const int kUnit = 20;

String regionOf(int rank) {
  for (var i = 0; i < kCliffs.length; i++) {
    if (rank <= kCliffs[i]) return 'R${i + 1}';
  }
  return 'R5';
}
