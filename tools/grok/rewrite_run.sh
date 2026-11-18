#!/bin/zsh
# Grok 대사 작성(2026-11-18 원칙: Claude 초안 → Grok 이 모든 줄 새로 씀 → 그대로 붙임). 「빠른」 모드, PC 크롬 9257.
#   zsh tools/grok/rewrite_run.sh <목록.txt> [방당 편 수=23]
# 방 첫 메시지 = 규칙 파일 + 첫 회화, 이후 파일 이름 한 줄. 답 data/grok/rewrite/<id>.txt → .json.
# 이미 .json 이 있으면 건너뜀. LIMIT 이면 멈춤. TIMEOUT 이면 방에서 다시 읽고(grok_read) 그래도 없으면 다음 편.
cd ${0:A:h}/../..
LIST=$1; PER=${2:-23}; D=app/assets/data/dialogues; O=data/grok/rewrite; RULE=tools/prompts/rewrite_grok_kk.md
B=data/grok/brief; mkdir -p $O $B; chat=""; n=0
for rel in $(cat $LIST); do
  id=${rel:t:r}
  [[ -f $O/$id.json ]] && continue
  python3 tools/grok/brief.py $D/$rel $B/$id.json
  if [[ -z $chat || $n -ge $PER ]]; then
    chat=""; n=0
    line="첨부한 rewrite_grok_kk.md 규칙을 이 방 전체에 적용하세요. 앞으로는 회화 JSON 하나를 첨부하고 파일 이름 한 줄만 보냅니다. 첫 회화: $id.json"
    res=$(/usr/bin/python3 tools/grok/grok_text.py "$line" $O/$id.txt $RULE $B/$id.json); rc=$?
  else
    res=$(/usr/bin/python3 tools/grok/grok_text.py "$id.json" $O/$id.txt $B/$id.json --chat $chat); rc=$?
  fi
  echo "$(date +%H:%M) $id rc=$rc $res"
  [[ $rc -eq 3 ]] && { echo LIMIT 멈춤; exit 3; }
  url=$(echo $res | grep -o 'grok.com/c/[^ ?]*' | tail -1); [[ -n $url ]] && chat=${url#grok.com/c/}
  if [[ $rc -eq 2 && -n $chat ]]; then sleep 40; /usr/bin/python3 tools/grok/grok_read.py $chat $O/$id.txt; fi
  /usr/bin/python3 tools/grok/to_json.py $O/$id.txt $O/$id.json || rm -f $O/$id.json
  # 초안과 거의 같은 줄이 2개 이상이면 같은 방에서 한 번 다시 요청(uk 공지 2026-11-18)
  if [[ -f $O/$id.json && -n $chat ]]; then
    s=$(python3 tools/grok/same_lines.py $D/$rel $O/$id.json)
    if [[ $s -ge 2 ]]; then
      sleep 20; echo "  초안과 같은 줄 $s — 다시 요청"
      /usr/bin/python3 tools/grok/grok_text.py "$id.json 에 초안 문장과 거의 같은 줄이 $s 개 있습니다. 규칙 4 대로 모든 줄을 처음부터 다르게 새로 써서 JSON 전체를 다시 주세요." $O/$id.txt --chat $chat
      /usr/bin/python3 tools/grok/to_json.py $O/$id.txt $O/$id.json || rm -f $O/$id.json
      [[ -f $O/$id.json ]] && echo "  다시 받은 뒤 같은 줄 $(python3 tools/grok/same_lines.py $D/$rel $O/$id.json)"
    fi
  fi
  n=$((n+1)); sleep 20
done
echo 끝
