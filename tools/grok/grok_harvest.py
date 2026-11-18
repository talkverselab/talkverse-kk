# -*- coding: utf-8 -*-
"""Grok 방의 코드 블록을 모두 읽어 JSON 의 id 로 <폴더>/<id>.json 에 저장(없는 것만). 「빠른」 모드에서 답이 늦게 채워져
놓친 편을 다시 요청 없이 건지려고.  /usr/bin/python3 tools/grok/grok_harvest.py <챗id> <폴더>"""
import json, os, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('GROK_CDP_PORT', '9257')
import grok_cdp as G
from grok_text import new_tab, close_tab

chat, out = sys.argv[1], sys.argv[2]
t = new_tab('https://grok.com/c/' + chat)
try:
    c = G.CDP(t); time.sleep(15)
    for _ in range(40):  # 긴 방은 위쪽이 늦게 그려짐 — 맨 위까지 올리며 모은다
        c.ev("window.scrollTo(0,0);document.querySelectorAll('*').forEach(e=>{if(e.scrollHeight>e.clientHeight+50)e.scrollTop=0})")
        time.sleep(1.5)
    codes = c.ev("[...document.querySelectorAll('pre code, pre')].map(e=>e.textContent)") or []
    seen = {}
    for s in codes:
        try:
            d = json.loads(s[s.index('{'):s.rindex('}') + 1]); seen[d['id']] = d  # 같은 id 는 뒤의 것(다시 받은 판)
        except Exception:
            pass
    for i, d in seen.items():
        p = os.path.join(out, i + '.json')
        if not os.path.exists(p):
            json.dump(d, open(p, 'w', encoding='utf-8'), ensure_ascii=False, indent=1); print('건짐', i)
    print('코드 블록', len(codes), 'id', len(seen))
finally:
    close_tab(t)
