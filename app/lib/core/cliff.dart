/// 카자흐어 절벽 값 — 코드 한 곳(단어 화면·앱 소개가 함께 쓴다).
/// 범위(2026-11-08, 소수언어로 결정 — 몽골어와 같음): 절벽 단어 약 1,500, 회화 150편(R3 까지).
/// ⚠ 경계 순위(누적 55/60/70/80%에 처음 닿는 순위)는 아직 산출 전 — 단어 목록 작업 때 채우고 [kCliffReady] 를 true 로.
/// 비어 있는 동안 regionOf 는 모두 R5, 앱 소개는 표 대신 「산출 전」 안내.
const bool kCliffReady = false;
const List<int> kCliffs = [];
const int kWordCap = 1500;
const double kWordCapPct = 0;
const int kUnit = 20;

String regionOf(int rank) {
  for (var i = 0; i < kCliffs.length; i++) {
    if (rank <= kCliffs[i]) return 'R${i + 1}';
  }
  return 'R5';
}
