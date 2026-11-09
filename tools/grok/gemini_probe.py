#!/usr/bin/python3
"""PC 크롬 9257 의 Gemini 로그인·모델 확인. 출력: READY <모델> | LOGIN | LITE <모델>. 백그라운드 탭을 열고 닫는다."""
import json, sys, time, urllib.request
sys.path.insert(0, '/Users/talkverse/Hanja/tools'); import grok_cdp as g
B = 'http://127.0.0.1:9257'; g.BASE = B
t = json.load(urllib.request.urlopen(urllib.request.Request(B + '/json/new?https://gemini.google.com/app', method='PUT')))
try:
    c = g.CDP(t); time.sleep(8)
    login = c.ev("[...document.querySelectorAll('a,button')].some(e=>/^(로그인|Sign in)$/.test(e.innerText.trim()))")
    m = c.ev("[...document.querySelectorAll('button')].map(b=>b.innerText.trim()).filter(t=>/Flash|Pro|Argon/.test(t))[0]||''")
    print('LOGIN' if login else ('LITE ' + m if 'Lite' in m or not m else 'READY ' + m))
finally:
    urllib.request.urlopen(B + '/json/close/' + t['id'])
