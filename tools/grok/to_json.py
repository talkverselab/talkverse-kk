#!/usr/bin/env python3
"""Grok 답 글 → JSON(앞뒤 화면 글자를 떼고 첫 { 부터 마지막 } 까지). 실패하면 종료 코드 1."""
import json, sys
s = open(sys.argv[1], encoding='utf-8').read()
try:
    e = json.loads(s[s.index('{'):s.rindex('}') + 1])
except Exception as x:
    print('파싱 실패', x); sys.exit(1)
json.dump(e, open(sys.argv[2], 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
