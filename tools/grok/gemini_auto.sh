#!/bin/zsh
# Gemini 검수 자동 이어 돌리기(사용자 「완료되더라도 제미나이 검수는 제미나이 풀리면 계속 진행할 수 있도록 해」 2026-11-22).
#   screen -dmS kk-gem-auto zsh tools/grok/gemini_auto.sh
# 앱에 들어간 회화 중 Gemini 답(data/review/dialogues/<id>_gemini.md)이 없는 편을 찾아 M4 9226(chrome-grok-vi, 구글 로그인된 공용 프로필) 에서 돌린다.
# - data/review/dialogues/WAIT 가 있으면 기다린다(새 편을 앱에 넣는 중).
# - 9226 이 이미 켜져 있으면 남이 쓰는 중 → 30분 뒤. M4 부하 20↑·스왑 4GB↑ 이면 30분 뒤.
# - 끝나면(또는 한도로 실패하면) 크롬을 직접 끈다(Browser.close). 한도·모드 실패가 남으면 1시간 뒤 다시.
# - 남은 편이 0 이면 끝. 쿠키는 복사하지 않는다(프로필에 로그인돼 있음).
cd ${0:A:h}/../..
L=data/review/dialogues/auto.log
log() { echo "$(date '+%m-%d %H:%M') $*" >> $L; }
close9226() {
  /usr/bin/python3 - <<'P' 2>/dev/null
import json,urllib.request,websocket
v=json.load(urllib.request.urlopen('http://127.0.0.1:9226/json/version',timeout=5))['webSocketDebuggerUrl']
ws=websocket.create_connection(v.replace('localhost','127.0.0.1').replace(':9222/',':9226/'),timeout=10,suppress_origin=True)
ws.send(json.dumps({'id':1,'method':'Browser.close'})); ws.recv()
P
  sleep 3
  for p in $(pgrep -f "9226:127.0.0.1:9226 macmini4"); do kill $p; done
}
while true; do
  if [[ -f data/review/dialogues/WAIT ]]; then sleep 300; continue; fi
  python3 tools/grok/gemini_prompts.py > /dev/null
  n=$(grep -c . data/review/dialogues/list.tsv)
  if [[ $n -eq 0 ]]; then log "남은 편 0 — 끝"; exit 0; fi
  st=$(ssh macmini4 'curl -s -m 3 127.0.0.1:9226/json/version >/dev/null && echo busy; uptime | awk -F"load averages: " "{print \$2}" | cut -d" " -f1; sysctl -n vm.swapusage | awk "{print \$6}"')
  if echo "$st" | grep -q busy; then log "9226 누가 쓰는 중 — 30분 뒤 (남은 $n)"; sleep 1800; continue; fi
  load=$(echo "$st" | sed -n 1p | cut -d. -f1); swap=$(echo "$st" | sed -n 2p | tr -d M | cut -d. -f1)
  if [[ ${load:-0} -ge 20 || ${swap:-0} -ge 4096 ]]; then log "M4 부하 $load·스왑 ${swap}M — 30분 뒤"; sleep 1800; continue; fi
  log "시작 — 남은 $n"
  ssh macmini4 'open -na "Google Chrome" --args --user-data-dir=/Users/talkverse/chrome-grok-vi --remote-debugging-port=9226 --no-first-run --no-default-browser-check https://gemini.google.com/app'
  sleep 10
  ssh -fN -L 9226:127.0.0.1:9226 macmini4; sleep 2
  GEMINI_CDP_PORT=9226 /usr/bin/python3 tools/grok/gemini_batch.py data/review/dialogues/list.tsv -j 1 --gap 60 >> data/review/dialogues/gemini_run.log 2>&1
  close9226
  python3 tools/grok/gemini_prompts.py > /dev/null
  n2=$(grep -c . data/review/dialogues/list.tsv)
  log "끝남 — 남은 $n2 (크롬 끔)"
  [[ $n2 -eq 0 ]] && { log "남은 편 0 — 끝"; exit 0; }
  sleep 3600
done
