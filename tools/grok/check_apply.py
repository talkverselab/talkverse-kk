#!/usr/bin/env python3
"""Grok 카자흐어 점검 결과 반영(2026-11-09).
  python3 tools/grok/check_apply.py [--write]
data/grok/check/<id>.json 을 원본과 맞춰 본다: id·턴 수·화자·twist_type 이 같고 검사기를 통과하면 반영 대상.
--write 면 원본 파일에 쓰고(rd 는 검사기가 다시 채움) 반영 표시 data/grok/check/<id>.applied 를 남긴다.
고친 줄 목록은 data/grok/check_fixes.md 에(사람·Claude 검토용).
"""
import glob, json, pathlib, subprocess, sys
ROOT = pathlib.Path(__file__).resolve().parents[2]
DLG = ROOT / 'app/assets/data/dialogues'
CHK = ROOT / 'data/grok/check'
write = '--write' in sys.argv
md, ok, bad = ['# Grok 카자흐어 점검 — 고친 줄\n'], 0, []
for p in sorted(CHK.glob('*.json')):
    g = json.load(open(p, encoding='utf-8'))
    src = next(DLG.glob('R*/*/%s.json' % p.stem))
    o = json.load(open(src, encoding='utf-8'))
    fixes = g.pop('grok_fixes', [])
    why = []
    if g.get('id') != o['id']: why.append('id')
    if len(g.get('turns', [])) != len(o['turns']): why.append('턴 수')
    elif [t['speaker'] for t in g['turns']] != [t['speaker'] for t in o['turns']]: why.append('화자')
    if g.get('twist_type') != o['twist_type']: why.append('twist_type')
    if not why:
        listed = {f.get('num') for f in fixes}
        silent = [a['num'] for a, b in zip(o['turns'], g['turns']) if a['num'] not in listed and (a['tl'] != b.get('tl') or a['ko'] != b.get('ko'))]
        if silent: why.append('목록에 없는 변경 %s' % silent)
    if not why:
        g['draft'] = True
        for t in g['turns']:
            t['rd'] = ''
        tmp = ROOT / ('data/grok/check/_tmp_%s.json' % p.stem)
        json.dump(g, open(tmp, 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
        r = subprocess.run([sys.executable, str(ROOT / 'tools/check_dialogues.py'), '--fix-rd', str(tmp)], capture_output=True, text=True)
        if r.returncode:
            why.append('검사기: ' + ' / '.join(l for l in r.stdout.splitlines() if ':' in l))
        elif write and not (CHK / (p.stem + '.applied')).exists():
            src.write_text(tmp.read_text(encoding='utf-8'), encoding='utf-8')
            (CHK / (p.stem + '.applied')).write_text('')
        tmp.unlink()
    if why:
        bad.append('%s: %s' % (p.stem, ', '.join(why)))
        continue
    ok += 1
    if fixes:
        md.append('\n## %s (%d줄)\n' % (p.stem, len(fixes)))
        for f in fixes:
            md.append('- %s턴 `%s` → `%s` — %s' % (f.get('num'), f.get('before'), f.get('after'), f.get('why', '')))
(ROOT / 'data/grok/check_fixes.md').write_text('\n'.join(md) + '\n', encoding='utf-8')
print('반영 가능 %d · 문제 %d' % (ok, len(bad)) + (' (쓰기)' if write else ' (미리보기)'))
for b in bad:
    print('  ', b)
