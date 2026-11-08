/// 카자흐어 키릴 문자 42자 — 「문자와 발음」 화면용(2026-11-08, 공통 프롬프터 §5-3 「50음도와 발음」 기준).
///
/// 기준: 카자흐어 음운의 표준 기술(IPA)과 한국어 표준 발음 비교. 로마자는 2021년 라틴 문자안 기준이고,
/// 러시아어에서 온 낱말에만 쓰는 글자(ё ц ч щ ъ ь э 등)는 소리대로 적었다.
/// 소리 파일 = `assets/audio/letters/<id>.mp3`(글자 소리 [say] 를 합성), 매핑은 `assets/audio/manifest.json`.
enum LetterKind { backVowel, frontVowel, vowelLoan, consonant, consonantLoan, sign }

class KkLetter {
  final String upper, lower;
  final String id; // 파일 이름(라틴)
  final String latin; // 로마자
  final String ipa;
  final LetterKind kind;
  final bool native; // 카자흐어 고유 글자 9자(ә ғ қ ң ө ұ ү һ і)
  final String say; // 들려줄 소리(자음은 모음을 붙인 음절)
  final String place; // 소리 나는 곳·입 모양
  final String korSim; // 비슷한 한국어 소리
  final String korDiff; // 한국어 화자에게 다른 점
  const KkLetter(this.upper, this.lower, this.id, this.latin, this.ipa, this.kind, this.say, this.place, this.korSim, this.korDiff,
      {this.native = false});

  bool get isVowel => kind == LetterKind.backVowel || kind == LetterKind.frontVowel || kind == LetterKind.vowelLoan;
  bool get isLoan => kind == LetterKind.vowelLoan || kind == LetterKind.consonantLoan || kind == LetterKind.sign;
  bool get hasSound => kind != LetterKind.sign;
}

const List<KkLetter> kKkLetters = [
  KkLetter('А', 'а', 'a', 'A', 'ɑ', LetterKind.backVowel, 'а',
      '입을 크게 벌리고 혀를 낮고 뒤쪽에 둔다(후설 저모음). 입술은 둥글리지 않는다.',
      '아', '한국어 「아」보다 조금 더 입 안쪽에서 낸다. 뒤 모음 — 이 모음이 든 낱말에는 뒤 모음 접사(-лар, -да …)가 붙는다.'),
  KkLetter('Ә', 'ә', 'ae', 'Ä', 'æ', LetterKind.frontVowel, 'ә',
      '입을 「아」만큼 벌리면서 혀는 앞으로 내민다(전설 저모음).',
      '애', '한국어 「애」보다 입을 더 크게 벌린다. 「아」와 「애」 사이로 들린다. 앞 모음 — а 의 짝.',
      native: true),
  KkLetter('Б', 'б', 'b', 'B', 'b', LetterKind.consonant, 'ба',
      '두 입술을 닫았다가 터뜨리며 목청을 울린다(유성 양순 파열음).',
      'ㅂ', '한국어 낱말 첫 「ㅂ」은 울림이 없지만 카자흐어 б 는 처음부터 목청이 떨린다. 낱말 끝에서는 [p] 로 약해진다.'),
  KkLetter('В', 'в', 'v', 'V', 'v', LetterKind.consonantLoan, 'ва',
      '윗니를 아랫입술에 가볍게 대고 울리며 바람을 낸다(유성 순치 마찰음).',
      '(없음) ㅂ', '한국어에 없는 소리. 두 입술을 붙이는 「ㅂ」이 아니라 윗니와 아랫입술 사이로 낸다. 주로 러시아어에서 온 낱말.'),
  KkLetter('Г', 'г', 'g', 'G', 'ɡ', LetterKind.consonant, 'ге',
      '혀 뒤쪽을 여린입천장에 붙였다 떼며 목청을 울린다(유성 연구개 파열음). 앞 모음과 함께 쓴다.',
      'ㄱ', '한국어 「ㄱ」보다 확실히 울린다. 뒤 모음 옆에서는 같은 자리에 ғ 를 쓴다.'),
  KkLetter('Ғ', 'ғ', 'gh', 'Ğ', 'ʁ', LetterKind.consonant, 'ға',
      '혀뿌리를 목젖 쪽으로 올려 좁은 틈으로 울리며 바람을 낸다(유성 구개수 마찰음). 뒤 모음과 함께 쓴다.',
      '(없음) ㄱ·ㅎ 사이', '한국어에 없는 소리. 가글할 때처럼 목 안쪽에서 「ㄱ」을 막지 않고 흘려 울린다. г 의 뒤 모음 짝.',
      native: true),
  KkLetter('Д', 'д', 'd', 'D', 'd', LetterKind.consonant, 'да',
      '혀끝을 윗잇몸에 붙였다 떼며 목청을 울린다(유성 치경 파열음).',
      'ㄷ', '한국어 낱말 첫 「ㄷ」보다 울림이 분명하다.'),
  KkLetter('Е', 'е', 'e', 'E', 'e', LetterKind.frontVowel, 'е',
      '입을 반쯤 벌리고 혀를 앞쪽에 둔다(전설 중고모음). 낱말 첫머리에서는 앞에 [j] 가 붙는다.',
      '에 / 예', '한국어 「에」와 거의 같다. 낱말 첫머리에서는 「예」처럼 들린다. 앞 모음.'),
  KkLetter('Ё', 'ё', 'yo', 'Io', 'jo', LetterKind.vowelLoan, 'ё',
      '[j] 다음에 「오」를 잇는다.',
      '요', '러시아어에서 온 낱말에만 쓴다.'),
  KkLetter('Ж', 'ж', 'zh', 'J', 'ʒ', LetterKind.consonant, 'жа',
      '혀끝을 잇몸 뒤로 가까이 대고 막지 않은 채 울리며 바람을 낸다(유성 후치경 마찰음).',
      '(없음) ㅈ', '「ㅈ」처럼 막았다 터뜨리지 않고 흘려 낸다. 영어 measure 의 s 와 같은 소리.'),
  KkLetter('З', 'з', 'z', 'Z', 'z', LetterKind.consonant, 'за',
      '혀끝을 윗잇몸 가까이 두고 울리며 바람을 낸다(유성 치경 마찰음).',
      '(없음) ㅅ', '「ㅅ」에 목청 울림을 더한 소리. 「ㅈ」으로 바꾸지 않는다.'),
  KkLetter('И', 'и', 'i', 'İ', 'ɪj / əj', LetterKind.frontVowel, 'и',
      '짧은 모음 다음에 [j] 로 끝나는 이중 소리(ій·ый). 러시아어에서 온 낱말에서는 [i].',
      '이', '한국어 「이」보다 끝이 [j] 로 닫힌다. 길게 「이이」처럼 들린다.'),
  KkLetter('Й', 'й', 'y', 'İ', 'j', LetterKind.consonant, 'ай',
      '혀 앞쪽을 센입천장 가까이 올려 낸다(경구개 접근음). 모음 뒤에 붙어 이중 소리를 만든다.',
      'ㅣ 반모음', '「아이」의 「이」를 짧게 붙인 소리. ай = 「아이」를 한 음절로.'),
  KkLetter('К', 'к', 'k', 'K', 'k', LetterKind.consonant, 'ке',
      '혀 뒤쪽을 여린입천장에 붙였다 떼며 울리지 않는다(무성 연구개 파열음). 앞 모음과 함께 쓴다.',
      'ㅋ·ㄲ', '한국어 「ㅋ」보다 바람이 약하다. 「ㅋ」과 「ㄲ」 사이. 뒤 모음 옆에서는 қ 를 쓴다.'),
  KkLetter('Қ', 'қ', 'q', 'Q', 'q', LetterKind.consonant, 'қа',
      '혀뿌리를 목젖에 붙였다 떼며 울리지 않는다(무성 구개수 파열음). 뒤 모음과 함께 쓴다.',
      '(없음) ㅋ', '한국어 「ㅋ」보다 훨씬 깊은 목 안쪽에서 낸다. 「카」를 목구멍 가까이에서 내는 느낌. к 의 뒤 모음 짝.',
      native: true),
  KkLetter('Л', 'л', 'l', 'L', 'l', LetterKind.consonant, 'ла',
      '혀끝을 윗잇몸에 붙이고 옆으로 소리를 흘린다(치경 설측 접근음). 뒤 모음 옆에서는 혀 뒤가 올라가 어둡게 들린다.',
      'ㄹ(받침)', '한국어 받침 「ㄹ」처럼 혀끝을 붙인 채 낸다. 모음 사이에서도 「ㄹ」을 굴리지 않는다.'),
  KkLetter('М', 'м', 'm', 'M', 'm', LetterKind.consonant, 'ма',
      '두 입술을 닫고 코로 소리를 낸다(양순 비음).',
      'ㅁ', '한국어 「ㅁ」과 같다.'),
  KkLetter('Н', 'н', 'n', 'N', 'n', LetterKind.consonant, 'на',
      '혀끝을 윗잇몸에 붙이고 코로 소리를 낸다(치경 비음).',
      'ㄴ', '한국어 「ㄴ」과 같다.'),
  KkLetter('Ң', 'ң', 'ng', 'Ñ', 'ŋ', LetterKind.consonant, 'аң',
      '혀 뒤쪽을 여린입천장에 붙이고 코로 소리를 낸다(연구개 비음). 낱말 첫머리에는 오지 않는다.',
      'ㅇ(받침)', '한국어 받침 「ㅇ」과 같은 소리. 모음 사이에서도 「ㅇ」 그대로 낸다(аңыз = 앙으즈).',
      native: true),
  KkLetter('О', 'о', 'o', 'O', 'o', LetterKind.backVowel, 'о',
      '입술을 둥글게 하고 혀를 뒤쪽 중간 높이에 둔다(후설 원순 중모음). 낱말 첫머리에서는 앞에 [w] 가 살짝 붙는다.',
      '오', '한국어 「오」와 비슷하다. 낱말 첫머리에서는 「워」처럼 들리기도 한다. 뒤 모음.'),
  KkLetter('Ө', 'ө', 'oe', 'Ö', 'ø', LetterKind.frontVowel, 'ө',
      '입술은 「오」처럼 둥글게, 혀는 「에」처럼 앞으로(전설 원순 중모음).',
      '(없음) 외', '한국어 단모음 「외」에 가깝다. 「오에」로 나누지 말고 한 번에 낸다. 앞 모음 — о 의 짝.',
      native: true),
  KkLetter('П', 'п', 'p', 'P', 'p', LetterKind.consonant, 'па',
      '두 입술을 닫았다가 울리지 않고 터뜨린다(무성 양순 파열음).',
      'ㅍ·ㅃ', '한국어 「ㅍ」보다 바람이 약하다.'),
  KkLetter('Р', 'р', 'r', 'R', 'r', LetterKind.consonant, 'ра',
      '혀끝을 윗잇몸에 대고 여러 번 떨게 한다(치경 전동음).',
      'ㄹ(굴림)', '한국어 모음 사이 「ㄹ」은 한 번 튕기지만 카자흐어 р 는 혀끝을 떨어 굴린다.'),
  KkLetter('С', 'с', 's', 'S', 's', LetterKind.consonant, 'са',
      '혀끝을 윗잇몸 가까이 두고 울리지 않고 바람을 낸다(무성 치경 마찰음).',
      'ㅅ·ㅆ', '「ㅅ」과 「ㅆ」 사이. 「이」 앞에서도 「시」처럼 혀를 올리지 않는다.'),
  KkLetter('Т', 'т', 't', 'T', 't', LetterKind.consonant, 'та',
      '혀끝을 윗잇몸에 붙였다 울리지 않고 뗀다(무성 치경 파열음).',
      'ㅌ·ㄸ', '한국어 「ㅌ」보다 바람이 약하다.'),
  KkLetter('У', 'у', 'u', 'U', 'w / ʊw', LetterKind.backVowel, 'у',
      '모음 뒤에서는 반모음 [w], 홀로 쓰이면 짧은 「우」 다음 [w] 로 닫힌다. 러시아어에서 온 낱말에서는 [u].',
      '우 / ㅜ 반모음', '「우우」처럼 끝이 입술을 오므린 채 닫힌다. ау = 「아우」를 한 음절로.'),
  KkLetter('Ұ', 'ұ', 'uu', 'Ū', 'ʊ', LetterKind.backVowel, 'ұ',
      '입술을 둥글게, 혀는 뒤쪽 높이 — 짧고 느슨하게(후설 원순 근고모음).',
      '우', '한국어 「우」보다 짧고 입술 힘을 뺀다. 뒤 모음 — ү 의 짝.',
      native: true),
  KkLetter('Ү', 'ү', 'ue', 'Ü', 'ʏ', LetterKind.frontVowel, 'ү',
      '입술은 「우」처럼 둥글게, 혀는 「이」처럼 앞으로(전설 원순 근고모음).',
      '(없음) 위', '한국어 단모음 「위」에 가깝다. 「우이」로 나누지 말고 한 번에. 앞 모음 — ұ 의 짝.',
      native: true),
  KkLetter('Ф', 'ф', 'f', 'F', 'f', LetterKind.consonantLoan, 'фа',
      '윗니를 아랫입술에 대고 울리지 않고 바람을 낸다(무성 순치 마찰음).',
      '(없음) ㅍ', '「ㅍ」이 아니라 윗니와 아랫입술 사이로 바람을 낸다. 주로 러시아어·외래어.'),
  KkLetter('Х', 'х', 'kh', 'H', 'χ', LetterKind.consonantLoan, 'ха',
      '혀뿌리를 목젖 가까이 올려 울리지 않고 바람을 낸다(무성 구개수 마찰음).',
      'ㅎ', '「ㅎ」보다 목 안쪽에서 마찰이 거칠게 난다. 주로 러시아어·아랍어에서 온 낱말.'),
  KkLetter('Һ', 'һ', 'h', 'H', 'h', LetterKind.consonant, 'һа',
      '목청 사이로 바람만 내보낸다(성문 마찰음).',
      'ㅎ', '한국어 「ㅎ」과 같다. 아랍어·페르시아어에서 온 몇몇 낱말에만 쓴다.',
      native: true),
  KkLetter('Ц', 'ц', 'ts', 'Ts', 'ts', LetterKind.consonantLoan, 'ца',
      '혀끝을 윗잇몸에 붙였다가 「ㅅ」으로 풀어 낸다(무성 치경 파찰음).',
      'ㅉ', '「ㅉ」과 비슷하지만 끝에 「ㅅ」 바람이 남는다. 러시아어에서 온 낱말에만.'),
  KkLetter('Ч', 'ч', 'ch', 'Ch', 'tʃ', LetterKind.consonantLoan, 'ча',
      '혀를 잇몸 뒤에 붙였다가 마찰로 푼다(무성 후치경 파찰음).',
      'ㅊ', '한국어 「ㅊ」과 비슷하다. 러시아어에서 온 낱말에만.'),
  KkLetter('Ш', 'ш', 'sh', 'Ş', 'ʃ', LetterKind.consonant, 'ша',
      '혀를 잇몸 뒤로 가까이 두고 입술을 조금 내밀며 바람을 낸다(무성 후치경 마찰음).',
      '시·쉬', '「사」가 아니라 「샤」에 가깝다. 영어 she 의 sh.'),
  KkLetter('Щ', 'щ', 'shch', 'Şş', 'ɕː', LetterKind.consonantLoan, 'ща',
      '혀 앞쪽을 센입천장 가까이 올려 길게 바람을 낸다.',
      '씨(길게)', '「쉬」를 길고 부드럽게 끈다. 러시아어에서 온 낱말에만.'),
  KkLetter('Ъ', 'ъ', 'hard', '—', '—', LetterKind.sign, '',
      '소리가 없는 표시(경음 부호). 앞뒤 소리를 끊어 읽게 한다.',
      '—', '러시아어에서 온 낱말에만 쓴다. 소리 없음.'),
  KkLetter('Ы', 'ы', 'y_', 'Y', 'ə / ɯ', LetterKind.backVowel, 'ы',
      '입술을 둥글리지 않고 혀를 뒤쪽 가운데에 둔다 — 짧고 약하게(후설 비원순).',
      '으·어', '한국어 「으」와 「어」 사이. 아주 짧아서 빠른 말에서는 거의 사라진다. 뒤 모음 — і 의 짝.'),
  KkLetter('І', 'і', 'i_', 'I', 'ɪ', LetterKind.frontVowel, 'і',
      '입술을 펴고 혀를 앞쪽에 두되 「이」보다 낮고 느슨하게(전설 근고모음).',
      '이·으', '한국어 「이」보다 짧고 힘이 빠져 「이」와 「으」 사이로 들린다. 앞 모음 — ы 의 짝.',
      native: true),
  KkLetter('Ь', 'ь', 'soft', '—', '—', LetterKind.sign, '',
      '소리가 없는 표시(연음 부호). 앞 자음을 부드럽게 한다.',
      '—', '러시아어에서 온 낱말에만 쓴다. 소리 없음.'),
  KkLetter('Э', 'э', 'e_', 'E', 'e', LetterKind.vowelLoan, 'э',
      '입을 반쯤 벌리고 혀를 앞쪽에 둔다.',
      '에', '러시아어에서 온 낱말 첫머리에 쓴다. 카자흐어 낱말은 е 를 쓴다.'),
  KkLetter('Ю', 'ю', 'yu', 'Iu', 'jʊw / ju', LetterKind.vowelLoan, 'ю',
      '[j] 다음에 「우」를 잇는다.',
      '유', '「유」와 같다.'),
  KkLetter('Я', 'я', 'ya', 'Ia', 'jɑ', LetterKind.vowelLoan, 'я',
      '[j] 다음에 「아」를 잇는다.',
      '야', '「야」와 같다.'),
];

/// 모음조화 짝 — 뒤 모음 ↔ 앞 모음.
const List<(String, String)> kHarmonyPairs = [('а', 'ә'), ('о', 'ө'), ('ұ', 'ү'), ('ы', 'і')];

/// IPA 모음 사다리꼴 위의 좌표 (x: 0=전설 → 1=후설, y: 0=고모음 → 1=저모음)
class VowelPoint {
  final double x, y;
  final String ipa;
  final String label;
  const VowelPoint(this.x, this.y, this.ipa, this.label);
}

/// 카자흐어 모음 1개 vs 이웃한 한국어 모음들.
class VowelChartData {
  final VowelPoint tl;
  final List<VowelPoint> ko;
  final String note;
  const VowelChartData({required this.tl, required this.ko, required this.note});
}

const Map<String, VowelChartData> kVowelCharts = {
  'а': VowelChartData(tl: VowelPoint(0.92, 0.97, 'ɑ', 'а'), ko: [VowelPoint(0.55, 1.0, 'a', '아')],
      note: 'а 는 한국어 「아」보다 뒤쪽. 입을 크게 벌린다.'),
  'ә': VowelChartData(tl: VowelPoint(0.08, 0.85, 'æ', 'ә'), ko: [VowelPoint(0.06, 0.48, 'e', '애·에'), VowelPoint(0.55, 1.0, 'a', '아')],
      note: 'ә 는 「애」보다 훨씬 낮다 — 「아」만큼 입을 벌리고 혀만 앞으로.'),
  'е': VowelChartData(tl: VowelPoint(0.05, 0.38, 'e', 'е'), ko: [VowelPoint(0.06, 0.48, 'e', '에')],
      note: 'е 는 한국어 「에」와 거의 같은 자리.'),
  'о': VowelChartData(tl: VowelPoint(0.97, 0.40, 'o', 'о'), ko: [VowelPoint(0.97, 0.36, 'o', '오'), VowelPoint(0.90, 0.62, 'ʌ', '어')],
      note: 'о 는 한국어 「오」와 비슷하다. 「어」로 열리지 않게 입술을 둥글게.'),
  'ө': VowelChartData(tl: VowelPoint(0.18, 0.40, 'ø', 'ө'), ko: [VowelPoint(0.06, 0.48, 'e', '에'), VowelPoint(0.97, 0.36, 'o', '오')],
      note: 'ө 는 「에」 자리에서 입술만 「오」처럼 둥글게.'),
  'ұ': VowelChartData(tl: VowelPoint(0.85, 0.15, 'ʊ', 'ұ'), ko: [VowelPoint(1.0, 0.02, 'u', '우')],
      note: 'ұ 는 「우」보다 조금 낮고 느슨하다.'),
  'ү': VowelChartData(tl: VowelPoint(0.15, 0.15, 'ʏ', 'ү'), ko: [VowelPoint(0.0, 0.02, 'i', '이'), VowelPoint(1.0, 0.02, 'u', '우')],
      note: 'ү 는 「이」 자리에서 입술만 「우」처럼 둥글게.'),
  'ы': VowelChartData(tl: VowelPoint(0.62, 0.40, 'ə', 'ы'), ko: [VowelPoint(0.80, 0.05, 'ɯ', '으'), VowelPoint(0.90, 0.62, 'ʌ', '어')],
      note: 'ы 는 「으」와 「어」 사이. 짧고 약하게.'),
  'і': VowelChartData(tl: VowelPoint(0.15, 0.18, 'ɪ', 'і'), ko: [VowelPoint(0.0, 0.02, 'i', '이'), VowelPoint(0.80, 0.05, 'ɯ', '으')],
      note: 'і 는 「이」보다 낮고 느슨해 「으」 쪽으로 기운다.'),
};
