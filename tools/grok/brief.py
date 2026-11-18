#!/usr/bin/env python3
"""Claude 초안 → Grok 에 보낼 뼈대(2026-11-18 「클로드 지문 없애기」). 상황·인물·반전·배울 단어·턴 수만 남기고
대사(tl·rd·ko·note·segs)는 비운다.  brief.py <초안.json> <뼈대.json>"""
import json, sys
d = json.load(open(sys.argv[1]))
for t in d['turns']:
    for k in ('tl', 'rd', 'ko', 'note'):
        t[k] = ''
    t.pop('segs', None); t.pop('lemmas', None)
d['note_for_writer'] = '대사 칸(tl·ko·note)은 비어 있다 — 장면·인물·반전·new 단어를 보고 네가 처음부터 쓴다. 턴 수와 화자 순서는 바꿔도 된다.'
json.dump(d, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
