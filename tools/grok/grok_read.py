# -*- coding: utf-8 -*-
"""Grok 방의 마지막 코드 블록을 다시 읽기만 한다(새 요청 없음). 「빠른」 모드는 답이 늦게 채워져
TIMEOUT·줄 모자람이 오판일 수 있어(uk 공지 2026-11-18), 다시 요청하기 전에 이것으로 먼저 읽는다.
  /usr/bin/python3 tools/grok/grok_read.py <챗id> <답.txt>
"""
import os, sys, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('GROK_CDP_PORT', '9257')
import grok_cdp as G
from grok_text import new_tab, close_tab

chat, out = sys.argv[1], sys.argv[2]
t = new_tab('https://grok.com/c/' + chat)
try:
    c = G.CDP(t)
    time.sleep(12)
    codes = c.ev("[...document.querySelectorAll('pre code, pre')].map(e=>e.textContent)") or []
    if not codes:
        print('코드 블록 없음'); sys.exit(1)
    open(out, 'w', encoding='utf-8').write(codes[-1])
    print('저장', out, len(codes[-1]))
finally:
    close_tab(t)
