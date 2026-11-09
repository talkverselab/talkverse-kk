#!/usr/bin/env python3
"""Gemini 검수 프롬프트 150편 만들기(2026-11-09). data/review/dialogues/prompts/<id>.md + list.tsv(<프롬프트>\t<저장>, 이미 받은 편은 뺌)."""
import json, pathlib
R = pathlib.Path(__file__).resolve().parents[2]
T = (R / 'tools/prompts/review_gemini_kk.md').read_text(encoding='utf-8')
P = R / 'data/review/dialogues/prompts'; P.mkdir(parents=True, exist_ok=True)
rows = []
for f in sorted((R / 'app/assets/data/dialogues').glob('R*/*/*.json'), key=lambda p: (p.parts[-3], p.parts[-2], int(p.stem.rsplit('a', 1)[1]))):
    d = json.load(open(f, encoding='utf-8'))
    roles = ', '.join('%s=%s' % (k, '학습자' if v == '{name}' else v) for k, v in d['speakers'].items())
    lines = '\n'.join('%d %s: %s / %s' % (t['num'], t['speaker'], t['tl'].replace('{name}', 'Сәуле'), t['ko'].replace('{name}', '사울레')) for t in d['turns'])
    p = P / (d['id'] + '.md')
    p.write_text(T.replace('{id}', d['id']).replace('{roles}', roles).replace('{scene}', d['scene']).replace('{lines}', lines), encoding='utf-8')
    out = R / 'data/review/dialogues' / (d['id'] + '_gemini.md')
    if not out.exists(): rows.append('%s\t%s' % (p.relative_to(R), out.relative_to(R)))
(R / 'data/review/dialogues/list.tsv').write_text('\n'.join(rows) + '\n', encoding='utf-8')
print('프롬프트', len(list(P.glob('*.md'))), '· 남은', len(rows))
