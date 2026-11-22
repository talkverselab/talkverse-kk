#!/usr/bin/env python3
"""R1~R3 회화(앱 assets/data/dialogues/R<n>/<섬>/<id>.json)를 옛 L1~L3.json 꼴로 묶는다.
문장 카드·문장 말하기·청크 검색·홈 '오늘의 학습'은 아직 옛 L 파일(→ DB turns 표)만 읽어서,
L 파일이 비면 그 화면이 통째로 빈다(2026-11-22 통합 앱 심사 전 점검에서 발견). 회화 원본은 R 파일 하나 — 이 스크립트로만 만든다.
  python3 tools/build_legacy_levels.py     # 회화를 바꾸면 다시 돌리고 version.json db 번호를 올린다
"""
import json, glob, os

APP = os.path.join(os.path.dirname(__file__), '..', 'app', 'assets', 'data', 'dialogues')
ORDER = ['survival', 'life', 'friends', 'love', 'culture']


def key(p):
    d = json.load(open(p, encoding='utf-8'))
    isl = d.get('island', '')
    tail = d['id'].rsplit('_', 1)[-1]
    num = int(''.join(c for c in tail if c.isdigit()) or 0)
    return (ORDER.index(isl) if isl in ORDER else 99, tail[:1], num)


for n in (1, 2, 3):
    files = sorted(glob.glob(f'{APP}/R{n}/*/*.json'), key=key)
    eps = []
    for p in files:
        d = json.load(open(p, encoding='utf-8'))
        eps.append({
            'id': d['id'], 'title': d.get('title', d['id']), 'emoji': d.get('emoji', '💬'),
            'scene': d.get('scene', ''),
            'turns': [{'num': t['num'], 'speaker': t['speaker'], 'es': t['tl'], 'rd': t.get('rd'),
                       'ko': t.get('ko'), 'note': t.get('note'), 'tags': t.get('tags') or []}
                      for t in d['turns']],
        })
    turns = sum(len(e['turns']) for e in eps)
    out = {
        'level': f'L{n}', 'variety': 'kk_KZ', 'version': 'from-R', 'schema': 'v2-from-R',
        'title': f'L{n} — 카자흐어 회화 (R{n} 에서 생성)',
        'description': 'tools/build_legacy_levels.py 가 R 회화에서 만든 파일 — 직접 고치지 말 것.',
        'kpi': {'episodes_target': len(eps), 'turns_total_current': turns},
        'characters': {'A': {'name': '나', 'gender': 'male'}},
        'function_words': [], 'episodes': eps,
    }
    json.dump(out, open(f'{APP}/L{n}.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f'L{n}: {len(eps)}편 {turns}턴')
