#!/usr/bin/env python3
"""언어감각 과정(app/assets/data/grammar/sense_course.json) 만들기 — 2026-11-22.
카자흐어 문장은 새로 쓰지 않는다(2026-11-18 원칙): 앱 회화(Grok 이 쓴 대사)에서 그 급의 접사가 든 줄을 골라
「외울 대화」(한 편에서 이어지는 줄을 우선)와 「참고」 예문으로 쓴다. 접사 부분만 {…|n} 로 표시(글자는 그대로).
설명(tip·note·footnotes)은 한국어 설명문이다. 회화가 바뀌면 다시 돌리고 --publish 로 서버에 올린다.
  python3 tools/build_sense_course.py"""
import glob, json, re, pathlib
R = pathlib.Path(__file__).resolve().parents[1]
D = R / 'app/assets/data/dialogues'
OUT = R / 'app/assets/data/grammar/sense_course.json'
W = re.compile(r"[А-Яа-яЁёӘәҒғҚқҢңӨөҰұҮүҺһІі]+")

LEVELS = [
 ('L1', '격어미 1 — 어디로·어디서·어디부터', [('여격 -ға/-ге/-қа/-ке', 'ға ге қа ке', '가는 곳·받는 사람(-에/-에게). 앞 소리가 무성 자음이면 қа/ке.'),
   ('처격 -да/-де/-та/-те', 'да де та те', '있는 곳·때(-에/-에서).'), ('탈격 -дан/-ден/-тан/-тен/-нан/-нен', 'дан ден тан тен нан нен', '출발점·비교(-에서/-부터/-보다).')],
  '한국어 조사처럼 낱말 끝에 붙지만, 앞 모음(뒤 모음 а·о·ұ·ы / 앞 모음 ә·е·ө·ү·і)과 앞 소리에 맞춰 꼴이 바뀌어요.',
  ['모음조화: 낱말의 마지막 모음이 뒤 모음이면 -ға·-да·-дан, 앞 모음이면 -ге·-де·-ден.', '무성 자음(п·т·к·қ·с·ш) 뒤에서는 д→т, ғ→қ, г→к 로 바뀌어요.']),
 ('L2', '격어미 2 — 을/를·의·와 함께', [('대격 -ны/-ні/-ды/-ді/-ты/-ті', 'ны ні ды ді ты ті', '정해진 목적어(-을/를). 정해지지 않은 목적어는 그냥 둬요.'),
   ('속격 -ның/-нің/-дың/-дің/-тың/-тің', 'ның нің дың дің тың тің', '「A 의 B」 — B 쪽에는 3인칭 소유 -сы/-сі 가 함께 붙어요.'), ('조격 -мен/-бен/-пен', 'мен бен пен', '함께·수단(-와 함께/-로). 모음조화가 없어요.')],
  '목적어와 소유를 표시하는 격어미예요. 한국어와 달리 「정해진 것」에만 -ны 를 붙여요.',
  ['кітап оқимын(책을 읽어요, 아무 책) / кітапты оқимын(그 책을 읽어요).', 'менің досым = 내 친구 — 속격 + 소유 접사가 짝으로 다녀요.']),
 ('L3', '소유 접사 — 내 것·네 것·당신 것', [('1인칭 -ым/-ім/-м', 'ым ім', '내 ~.'), ('2인칭 -ың/-ің · 높임 -ыңыз/-іңіз', 'ың ің ыңыз іңіз ңыз ңіз', '네 ~ / 당신의 ~.'), ('3인칭 -сы/-сі/-ы/-і', 'сы сі', '그의 ~, 「A 의 B」의 B.')],
  '「내」「네」를 앞에 따로 쓰지 않아도 낱말 끝 접사로 누구 것인지 알 수 있어요.',
  ['소유 접사 뒤에 격어미가 오면 꼴이 조금 바뀌어요: үйіне(그의 집에), үйінде(그의 집에서).']),
 ('L4', '동사 — 지금·늘·곧 하는 일', [('1인칭 -амын/-емін/-ймын', 'амын емін ймын ймін', '나는 ~해요.'), ('2인칭 높임 -асыз/-есіз', 'асыз есіз йсыз йсіз', '당신은 ~해요?'), ('3인칭 -ады/-еді/-йды/-йді', 'ады еді йды йді', '그는 ~해요.')],
  '카자흐어 현재형은 지금 하는 일·습관·곧 할 일을 모두 나타내요. 동사 끝 인칭 어미로 주어를 알 수 있어 주어를 자주 빼요.',
  ['어간이 모음으로 끝나면 -й-: ойлаймын(생각해요). 자음이면 -а-/-е-: барамын(가요), келемін(와요).']),
 ('L5', '동사 — 지난 일', [('과거 -ды/-ді/-ты/-ті + 인칭', 'дым дім тым тім дың дің тың тің ды ді ты ті дық дік тық тік', '말하는 사람이 겪거나 본 지난 일(-했다).')],
  '과거 -ды/-ді 뒤에 인칭(-м 나·-ң 너·-ңыз 당신·-қ/-к 우리)이 붙어요.',
  ['келдім(왔어요) · келдің(왔어) · келдіңіз(오셨어요) · келді(왔어요, 그) · келдік(왔어요, 우리).']),
 ('L6', '묻기와 부정', [('의문 첨사 ма/ме/ба/бе/па/пе', '', '예/아니오 질문 — 문장 끝 따로 쓴 낱말.'), ('부정 -ма/-ме/-ба/-бе/-па/-пе', 'мады меді байды пайды мадым медім маймын меймін маймыз', '안 ~해요 — 동사 어간 바로 뒤.'), ('жоқ · емес', '', '없다·아니다.')],
  '질문은 문장 끝에 ма/ме 를 따로 붙이고, 부정은 동사 어간 뒤에 -ма/-ме 를 넣어요.',
  ['앞 소리에 따라 ма/ба/па 셋 중 하나: Шынымен бе?(정말?), Қымбат па?(비싸요?), Келесің бе?(올 거야?).']),
 ('L7', '높임말 익히기 — Сіз 와 Сен', [('Сіз 높임', 'сіз сыз ңыз ңіз', '처음 보는 사람·가게·윗사람.'), ('Сен 반말', 'сен сың сің', '친구·연인·가족.')],
  '카자흐어는 「당신」을 두 가지로 써요. 처음 만나는 사람·가게에서는 Сіз, 친해지면 Сен.',
  ['동사 어미도 따라 바뀌어요: барасыз ба?(가세요?) / барасың ба?(가?).', '부탁: ~ беріңізші(~ 주시겠어요?) — -шы/-ші 를 붙이면 더 부드러워요.']),
]
WORD_MARK = {'L6q': r'(?<![А-Яа-яӘәҒғҚқҢңӨөҰұҮүҺһІі])(ма|ме|ба|бе|па|пе)(?=[?!.,…]|\s*$)'}

def lines():
    out = []
    for f in sorted(glob.glob(str(D / 'R*/*/*.json'))):
        d = json.load(open(f, encoding='utf-8'))
        for t in d['turns']:
            if '{' in t['tl']:
                continue
            out.append((d['id'], t['num'], t['tl'], t['rd'], t['ko']))
    return out

def mark(tl, forms, n=1):
    """forms 중 하나로 끝나는 낱말(어간 3자 이상)의 접사 부분만 {접사|n}. 글자는 바꾸지 않는다."""
    hit = False
    def rep(m):
        nonlocal hit
        w = m.group(0); lw = w.lower()
        for f in sorted(forms, key=len, reverse=True):
            if lw.endswith(f) and len(lw) - len(f) >= 3:
                hit = True
                return w[:len(w) - len(f)] + '{' + w[len(w) - len(f):] + f'|{n}}}'
        return w
    return W.sub(rep, tl), hit

def qmark(tl, n):
    s, k = re.subn(WORD_MARK['L6q'], lambda m: '{' + m.group(1) + f'|{n}}}', tl)
    return s, k > 0

def word(tl, words, n):
    hit = False
    def rep(m):
        nonlocal hit
        if m.group(0).lower() in words:
            hit = True; return '{' + m.group(0) + f'|{n}}}'
        return m.group(0)
    return W.sub(rep, tl), hit

def main():
    L = lines()
    levels = []
    for lid, title, points, note, foot in LEVELS:
        tagged = []  # (ep, num, marked, rd, ko, point index)
        for ep, num, tl, rd, ko in L:
            s = tl; hits = []
            for i, (head, forms, tip) in enumerate(points, 1):
                if forms:
                    s2, h = mark(s, forms.split(), i)
                elif lid == 'L6' and i == 1:
                    s2, h = qmark(s, i)
                elif lid == 'L6' and i == 3:
                    s2, h = word(s, {'жоқ', 'емес'}, i)
                else:
                    s2, h = s, False
                if h: s = s2; hits.append(i)
            if hits:
                tagged.append((ep, num, s, rd, ko, hits))
        # 외울 대화: 줄이 가장 많이 걸린 편에서 이어지는 줄(최대 10) — 모자라면 다른 편에서 채움
        by = {}
        for x in tagged: by.setdefault(x[0], []).append(x)
        eps = sorted(by, key=lambda e: (-len({h for x in by[e] for h in x[5]}), -len(by[e]), e))
        mem = []
        for e in eps:
            for x in sorted(by[e], key=lambda x: x[1]):
                if len(mem) < 10: mem.append(x)
            if len(mem) >= 8: break
        sentences = [{'tl': x[2], 'rd': x[3], 'ko': x[4]} for x in mem]
        pts = []
        for i, (head, forms, tip) in enumerate(points, 1):
            ex = [x for x in tagged if i in x[5] and x not in mem][:2] or [x for x in tagged if i in x[5]][:2]
            pts.append({'head': head, 'tip': tip, 'sentences': [{'tl': re.sub(r'\{([^|}]+)\|\d+\}', r'\1', x[2]), 'rd': x[3], 'ko': x[4]} for x in ex]})
        levels.append({'id': lid, 'title': title, 'lessons': [
            {'id': f'{lid}-1', 'title': title, 'kind': 'memorize', 'video': '', 'note': note, 'sentences': sentences, 'footnotes': foot},
            {'id': f'{lid}-ref', 'kind': 'ref', 'title': f'{title.split(" — ")[0]} 한눈에', 'points': pts}]})
        print(lid, '외울 줄', len(sentences), '· 참고', [len(p['sentences']) for p in pts], '· 걸린 줄', len(tagged))
    # L8~ — Claude 가 쓴 급(사용자 「언어감각 10급은 클로드로만 진행」 2026-11-22). 문장은 data/sense/claude_levels.json, rd 는 결정론 변환.
    import sys; sys.path.insert(0, str(R / 'scripts')); from normalize_pron import transliterate
    plain = lambda s: re.sub(r'\{([^|}]+)\|\d+\}', r'\1', s)
    for c in json.load(open(R / 'data/sense/claude_levels.json', encoding='utf-8')):
        sents = [{'tl': x['tl'], 'rd': transliterate(plain(x['tl'])), 'ko': x['ko']} for x in c['sentences']]
        pts = [{'head': p['head'], 'tip': p['tip'], 'sentences': [{'tl': plain(x['tl']), 'rd': transliterate(plain(x['tl'])), 'ko': x['ko']}
                for x in c['sentences'] if x['pt'] == i][:2]} for i, p in enumerate(c['points'], 1)]
        levels.append({'id': c['id'], 'title': c['title'], 'lessons': [
            {'id': f"{c['id']}-1", 'title': c['title'], 'kind': 'memorize', 'video': '', 'note': c['note'], 'sentences': sents, 'footnotes': c['footnotes']},
            {'id': f"{c['id']}-ref", 'kind': 'ref', 'title': f"{c['title']} 한눈에", 'points': pts}]})
        print(c['id'], '외울 줄', len(sents), '(Claude)')
    # 앱 묶음·서버 공개 원고에는 작업 기록(출처 편·작성 도구)을 넣지 않는다(uk 심사 점검 2026-11-23 — 공개 주소로 열림).
    OUT.parent.mkdir(parents=True, exist_ok=True)
    json.dump({'title': '언어감각 익히기', 'subtitle': '정규과정 · 대화 통째로 외우기 → 참고', 'levels': levels},
              open(OUT, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)

if __name__ == '__main__':
    main()
