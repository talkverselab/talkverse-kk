#!/usr/bin/env python3
"""Grok 대사 작성 결과 형식 검사(대사는 고치지 않음).  check_rewrite.py <목록.txt>
턴 수·한 턴 낱말 수·감정 열·한국어 칸 키릴·초안과 똑같은 줄(비슷함 0.9 넘음, 인사 한 줄 같은 공식 표현도 잡힘)·고정 칸."""
import json, glob, re, difflib, os, sys
L = {'R1': (6, 8, 7), 'R2': (8, 12, 9), 'R3': (12, 16, 12)}
src = {os.path.basename(f)[:-5]: f for f in glob.glob('app/assets/data/dialogues/R*/*/*.json')}
CYR = re.compile('[А-Яа-яӘәҒғҚқҢңӨөҰұҮүІіЁё]')
ok = 0
for r in open(sys.argv[1]).read().split():
    i = r.split('/')[-1][:-5]; p = f'data/grok/rewrite/{i}.json'
    if not os.path.exists(p):
        print(i, ['없음']); continue
    a = json.load(open(src[i])); b = json.load(open(p)); lo, hi, w = L[a['region']]; bad = []
    n = len(b['turns'])
    if not lo <= n <= hi: bad.append(f'턴{n}')
    lw = [t['num'] for t in b['turns'] if len(t['tl'].split()) > w]
    if lw: bad.append(f'낱말초과{lw}')
    if any(not t.get('emotion') for t in b['turns']): bad.append('감정빈칸')
    if any(CYR.search(t.get('ko', '')) for t in b['turns']): bad.append('ko키릴')
    s = sum(1 for t in b['turns'] if max(difflib.SequenceMatcher(None, x['tl'], t['tl']).ratio() for x in a['turns']) > 0.9)
    if s >= 2: bad.append(f'똑같은줄{s}')
    bad += [f'{k}바뀜' for k in ('id', 'region', 'island', 'kind', 'twist_type') if a.get(k) != b.get(k)]
    if bad: print(i, bad)
    else: ok += 1
print('통과', ok)
