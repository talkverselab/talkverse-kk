#!/bin/zsh
# Gemini 검수 지적 → Grok 이 받아들인 줄만 새로 씀(2026-11-22, 원칙: 고칠 때도 Grok 에게 다시 묻는다). 「빠른」 모드, PC 크롬 9257.
#   zsh tools/grok/fix_run.sh <편id 목록.txt> [방당 편 수=15]
# 첨부 = 앱 회화 JSON + data/review/dialogues/<id>_gemini.md. 답 data/grok/fix/<id>.txt → .json (tools/grok/fix_apply.py 로 반영).
cd ${0:A:h}/../..
LIST=$1; PER=${2:-15}; D=app/assets/data/dialogues; O=data/grok/fix; G=data/review/dialogues; RULE=tools/prompts/fix_grok_kk.md
mkdir -p $O; chat=""; n=0
for id in $(cat $LIST); do
  [[ -f $O/$id.json ]] && continue
  src=$(ls $D/R*/*/$id.json | head -1); rv=$G/${id}_gemini.md
  [[ -f $src && -f $rv ]] || { echo "$id 파일 없음"; continue; }
  if [[ -z $chat || $n -ge $PER ]]; then
    chat=""; n=0
    line="첨부한 fix_grok_kk.md 규칙을 이 방 전체에 적용하세요. 앞으로는 회화 JSON 과 Gemini 검수 .md 를 첨부하고 편 id 한 줄만 보냅니다. 첫 편: $id"
    res=$(/usr/bin/python3 tools/grok/grok_text.py "$line" $O/$id.txt $RULE $src $rv); rc=$?
  else
    res=$(/usr/bin/python3 tools/grok/grok_text.py "$id" $O/$id.txt $src $rv --chat $chat); rc=$?
  fi
  echo "$(date +%H:%M) $id rc=$rc $res"
  [[ $rc -eq 3 ]] && { echo LIMIT 멈춤; exit 3; }
  url=$(echo $res | grep -o 'grok.com/c/[^ ?]*' | tail -1); [[ -n $url ]] && chat=${url#grok.com/c/}
  if [[ $rc -eq 2 && -n $chat ]]; then sleep 40; /usr/bin/python3 tools/grok/grok_read.py $chat $O/$id.txt; fi
  /usr/bin/python3 tools/grok/to_json.py $O/$id.txt $O/$id.json || rm -f $O/$id.json
  n=$((n+1)); sleep 20
done
echo 끝
