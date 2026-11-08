#!/usr/bin/env python3
"""카자흐어 절벽구간 산출 — 일본어·몽골어앱과 같은 방식(누적 55·60·70·80% 에 처음 닿는 순위 = R1~R4 끝).

  python cliff_kk.py <자막 말뭉치.zip> <출력 폴더>

- 말뭉치: 공개 자막 묶음의 카자흐어 판(작품당 1판). 키릴 2,000자 미만이거나 카자흐어 고유 글자(ә ғ қ ң ө ұ ү һ і) 비율 3% 미만인 판은 뺀다.
  공개 저장소라 제공처 이름은 적지 않는다.
- 단위: 형태소 분석기(stanza kk)로 낱말의 기본형(동사는 사전형 -у) 하나 + 붙은 굴절 접사 하나하나(복수·소유·격·부정·시제·인칭·부동사·분사·동명사)를
  각각 한 토큰으로 세어 분자·분모 모두에 넣는다(몽골어 「격접사·어미는 각각 한 토큰」과 같은 뜻). 접사 토큰은 대표형(「-да (처격)」 식)으로 묶는다.
- 문장부호·숫자·라틴 문자 낱말은 뺀다. 고유명사·감탄사는 남긴다. 청각장애인용 소리 설명(괄호·대괄호·♪)은 지운다.
출력: lang_kk_top2500.csv(rank,word,pos,frequency,cum_pct,region — 인명이 섞여 저장소 밖에 둘 것) · kk_cliff_summary.json
"""
import csv, json, re, sys, time, zipfile
from collections import Counter

import stanza

src, out = sys.argv[1], sys.argv[2]
MODEL_DIR = sys.argv[3] if len(sys.argv) > 3 else None
TAG_RE = re.compile(r'<[^>]+>')
SDH = re.compile(r'\([^)]*\)|\[[^\]]*\]|♪[^♪]*♪?|^\s*-\s*')
CYR = re.compile(r'[а-яёәғқңөұүһі]', re.I)
KKL = re.compile(r'[әғқңөұүһі]', re.I)

CASE = {'Gen': '-ның (속격)', 'Acc': '-ны (대격)', 'Dat': '-ға (여격)', 'Loc': '-да (처격)', 'Abl': '-дан (탈격)', 'Ins': '-мен (조격)'}
PSOR = {('1', 'Sing'): '-ым (소유 1)', ('1', 'Plur'): '-ымыз (소유 1복)', ('2', 'Sing'): '-ың (소유 2)', ('2', 'Plur'): '-ың (소유 2)', ('3', None): '-ы (소유 3)'}
PERS = {('1', 'Sing'): '-мын (인칭 1)', ('1', 'Plur'): '-мыз (인칭 1복)', ('2', 'Sing'): '-сың (인칭 2)', ('2', 'Plur'): '-сыңдар (인칭 2복)'}


def dict_form(stem):
    """동사 어간 → 사전형(-у)."""
    if not stem:
        return stem
    last = stem[-1]
    if last in 'ыі':
        return stem[:-1] + 'у'
    if last == 'и':
        return stem + 'ю'
    if last == 'у':
        return stem + 'ю' if len(stem) <= 2 else stem
    return stem + 'у'


def feats(w):
    return dict(kv.split('=', 1) for kv in w.feats.split('|')) if w.feats else {}


def tokens(w):
    """낱말 하나 → [(토큰, 품사)]."""
    t = w.text.lower()
    if w.upos in ('PUNCT', 'SYM', 'NUM', 'X') or not CYR.search(t) or re.search(r'[a-z0-9]', t):
        return []
    f = feats(w)
    lem = (w.lemma or t).lower()
    out = []
    if w.upos == 'VERB':
        out.append((dict_form(lem), 'VERB'))
    else:
        out.append((lem, w.upos))
    # 명사류 접사
    if f.get('Number') == 'Plur' and w.upos in ('NOUN', 'PROPN', 'ADJ'):
        out.append(('-лар (복수)', 'SUFF'))
    if 'Person[psor]' in f:
        p = f['Person[psor]']
        key = (p, None) if p == '3' else (p, f.get('Number[psor]', 'Sing'))
        out.append((PSOR.get(key, '-ы (소유 3)'), 'SUFF'))
    if f.get('Case') in CASE:
        out.append((CASE[f['Case']], 'SUFF'))
    # 동사 접사
    if w.upos in ('VERB', 'AUX'):
        if f.get('Polarity') == 'Neg':
            out.append(('-ма (부정)', 'SUFF'))
        vf = f.get('VerbForm')
        if vf == 'Fin':
            if f.get('Mood') == 'Cnd':
                out.append(('-са (조건)', 'SUFF'))
            elif f.get('Mood') in ('Imp', 'Opt', 'Des'):
                out.append(('-сын/-айын (명령·의지)', 'SUFF')) if f.get('Person') != '2' else None
            elif f.get('Tense') == 'Past':
                out.append(('-ды (과거)', 'SUFF'))
            elif f.get('Tense') == 'Fut':
                out.append(('-ар (미래)', 'SUFF'))
            elif f.get('Tense') == 'Pres' and w.upos == 'VERB':
                out.append(('-а (현재·미래)', 'SUFF'))
            pk = (f.get('Person'), f.get('Number', 'Sing'))
            if pk in PERS and f.get('Mood') != 'Imp':
                out.append((PERS[pk], 'SUFF'))
        elif vf in ('Conv', 'Inf'):
            out.append(('-ып (부동사)' if f.get('Aspect') == 'Perf' else '-а (부동사)', 'SUFF'))
        elif vf == 'Part':
            out.append({'Past': ('-ған (과거 분사)', 'SUFF'), 'Fut': ('-атын (분사)', 'SUFF')}.get(f.get('Tense'), ('-атын (분사)', 'SUFF')))
        elif vf in ('Vnoun', 'Ger'):
            out.append(('-у (동명사)', 'SUFF'))
    return out


def docs(zf):
    seen = set()
    for name in sorted(zf.namelist()):
        if not name.endswith('.xml'):
            continue
        key = name.rsplit('/', 1)[0]
        if key in seen:
            continue
        text = zf.read(name).decode('utf-8', 'ignore')
        body = TAG_RE.sub(' ', text)
        c = len(CYR.findall(body))
        if c < 2000 or len(KKL.findall(body)) / c < 0.03:
            continue
        seen.add(key)
        lines = [SDH.sub(' ', TAG_RE.sub(' ', l)) for l in re.findall(r'<s\b[^>]*>(.*?)</s>', text, re.S)]
        yield key, [re.sub(r'\s+', ' ', l).strip() for l in lines if l.strip()]


nlp = stanza.Pipeline('kk', processors='tokenize,pos,lemma', dir=MODEL_DIR, verbose=False, download_method=None, tokenize_no_ssplit=True)
cnt = Counter(); pos = {}; total = 0; ndoc = 0; t0 = time.time()
with zipfile.ZipFile(src) as zf:
    for key, lines in docs(zf):
        lines = [l for l in lines if l]
        for i in range(0, len(lines), 400):
            d = nlp('\n\n'.join(lines[i:i + 400]))
            for s in d.sentences:
                for w in s.words:
                    for tok, p in tokens(w):
                        cnt[tok] += 1; total += 1; pos.setdefault(tok, p)
        ndoc += 1
        print(f'{ndoc} docs · {total} tokens · {time.time() - t0:.0f}s', flush=True)

ranked = cnt.most_common()
rows = []; cum = 0.0; cuts = {}
for r, (wd, n) in enumerate(ranked, 1):
    fr = n / total; cum += fr
    for i, th in enumerate((55, 60, 70, 80)):
        if f'R{i + 1}' not in cuts and cum * 100 >= th:
            cuts[f'R{i + 1}'] = (r, round(cum * 100, 1))
    if r <= 2500:
        rows.append([r, wd, pos[wd], f'{fr:.6f}', f'{cum * 100:.2f}', None])
ends = [cuts[k][0] for k in ('R1', 'R2', 'R3', 'R4')]
for row in rows:
    row[5] = next((f'R{i + 1}' for i, e in enumerate(ends) if row[0] <= e), 'R5')
import os
os.makedirs(out, exist_ok=True)
with open(f'{out}/lang_kk_top2500.csv', 'w', newline='') as fo:
    wr = csv.writer(fo); wr.writerow(['rank', 'word', 'pos', 'frequency', 'cum_pct', 'region']); wr.writerows(rows)
cum_at = lambda k: float(rows[min(k, len(rows)) - 1][4])
summary = {'docs': ndoc, 'tokens': total, 'types': len(cnt), 'cuts': cuts, 'cum_1500': cum_at(1500), 'cum_2500': cum_at(2500),
           'suffix_share_pct': round(100 * sum(n for w, n in cnt.items() if pos[w] == 'SUFF') / total, 1)}
json.dump(summary, open(f'{out}/kk_cliff_summary.json', 'w'), ensure_ascii=False, indent=1)
print('CLIFF_DONE', json.dumps(summary, ensure_ascii=False))
