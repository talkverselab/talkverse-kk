#!/usr/bin/env python3
"""Grok 답과 초안의 카자흐어 줄 비교 — 거의 같은 줄(비슷함 0.7 넘음) 수를 출력.  same_lines.py <초안.json> <답.json>"""
import json, sys, difflib
a = [t['tl'] for t in json.load(open(sys.argv[1]))['turns']]
b = [t['tl'] for t in json.load(open(sys.argv[2]))['turns']]
print(sum(1 for y in b if max((difflib.SequenceMatcher(None, x, y).ratio() for x in a), default=0) > 0.7))
