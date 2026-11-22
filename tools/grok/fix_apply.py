#!/usr/bin/env python3
"""data/grok/fix/<id>.json(Grok 이 받아들인 Gemini 지적) → 앱 회화 JSON 에 반영.
  python3 tools/grok/fix_apply.py [--write]     (없으면 검사만)
바꾸는 칸: 그 줄의 tl·ko·note(Grok 글 그대로). rd 는 반영 뒤 tools/check_dialogues.py --fix-rd 로 다시 만든다.
건너뜀: 없는 줄 번호, 한국어 칸(ko)에 키릴이 섞인 줄, 빈 tl. 반영 기록 data/grok/fix/applied.md.
"""
import glob, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
D = ROOT + '/app/assets/data/dialogues'
F = ROOT + '/data/grok/fix'
CYR = re.compile(r'[Ѐ-ӿ]')
write = '--write' in sys.argv
log, nchg, nskip = [], 0, 0
for fp in sorted(glob.glob(F + '/*.json')):
    fx = json.load(open(fp, encoding='utf-8'))
    id_ = os.path.basename(fp)[:-5]
    src = glob.glob(f'{D}/R*/*/{id_}.json')
    if not src:
        print('원본 없음', id_); continue
    d = json.load(open(src[0], encoding='utf-8'))
    by = {t['num']: t for t in d['turns']}
    log.append(f'## {id_}')
    for c in fx.get('changed', []):
        t = by.get(c.get('num'))
        tl, ko, note = (c.get('tl') or '').strip(), (c.get('ko') or '').strip(), (c.get('note') or '').strip()
        if not t or not tl or (ko and CYR.search(ko)):
            nskip += 1; log.append(f'- 건너뜀 {c.get("num")}줄: {"줄 없음" if not t else "빈 tl" if not tl else "ko 에 키릴"}'); continue
        log.append(f'- {t["num"]}줄 {t["tl"]} → {tl}  ({c.get("why", "")})')
        t['tl'] = tl
        if ko: t['ko'] = ko
        if note: t['note'] = note
        t['rd'] = ''
        nchg += 1
    for k in fx.get('kept', []):
        log.append(f'  - 둠: {k}')
    if write:
        json.dump(d, open(src[0], 'w', encoding='utf-8'), ensure_ascii=False, indent=1); open(src[0], 'a').write('\n')
if write:
    open(F + '/applied.md', 'w', encoding='utf-8').write('# Gemini 지적 → Grok 반영 기록\n\n' + '\n'.join(log) + '\n')
print(f'바꾼 줄 {nchg} · 건너뜀 {nskip}' + ('' if write else ' (검사만 — --write 로 반영)'))
