#!/bin/bash
# Grok 카자흐어 점검 회차 실행: bash tools/grok/check_run.sh <편수>  — 답이 없는 편부터 차례로, 한도면 멈춤.
cd "$(dirname "$0")/../.." || exit 1
N=${1:-10}; ROOM=$(cat data/grok/room_kk.txt); OUT=data/grok/check; mkdir -p $OUT; done=0
for f in $(ls app/assets/data/dialogues/R*/*/*.json | sort -t/ -k5,5 -k7,7V); do
  id=$(basename $f .json); [ -s $OUT/$id.json ] && continue
  [ $done -ge $N ] && break
  /usr/bin/python3 tools/grok/grok_text.py "$id.json" $OUT/$id.txt $f --chat $ROOM --wait 180; rc=$?
  [ $rc -eq 3 ] && { echo "한도 — 멈춤"; exit 3; }
  if python3 tools/grok/to_json.py $OUT/$id.txt $OUT/$id.json; then rm $OUT/$id.txt; echo "OK $id"; else echo "JSON 아님 $id"; fi
  done=$((done+1)); sleep 20
done
echo "회차 끝 $done편 · 누적 $(ls $OUT/*.json 2>/dev/null | wc -l)"
