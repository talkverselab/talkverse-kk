#!/bin/bash
# 로그인·Pro 선택을 5분마다 확인(최대 6시간) → 되면 gemini_batch 시작(-j 1 --gap 60).
cd "$(dirname "$0")/../.."
for i in $(seq 72); do
  s=$(/usr/bin/python3 tools/grok/gemini_probe.py 2>&1 | tail -1); echo "$(date +%H:%M) $s"
  if [[ $s == READY* ]]; then
    python3 tools/grok/gemini_prompts.py
    GEMINI_CDP_PORT=9257 /usr/bin/python3 tools/grok/gemini_batch.py data/review/dialogues/list.tsv -j 1 --gap 60
    exit 0
  fi
  sleep 300
done
echo GAVEUP
