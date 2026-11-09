# -*- coding: utf-8 -*-
"""Grok 글 요청 한 건(PC 크롬 9257, M6 터널 ssh -fN -L 9257:127.0.0.1:9257 Administrator@100.127.143.37).

  /usr/bin/python3 tools/grok/grok_text.py "<한 줄>" <답.txt> [첨부 ...] [--chat <챗id>] [--wait 180]
- 첨부는 PC D:\\grok_att\\kk\\ 로 scp 한 뒤 그 경로로 붙인다(크롬이 PC 에서 돌기 때문).
- 답: 마지막 응답의 마지막 코드 블록(없으면 응답 글 전체)을 <답.txt> 에 저장, 챗 주소를 출력.
- 한도 문구면 종료 코드 3, 시간 초과 2. 끝나면 연 탭을 닫는다.
- 답은 3분까지만 기다리고 넘으면 생성을 중지한다(사용자 지시 2026-11-10 「그록 3분만, 넘어가면 대화방 중지 — 토큰 낭비」). --wait 로 늘리지 말 것.
"""
import json, os, subprocess, sys, time, urllib.request
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('GROK_CDP_PORT', '9257')
import grok_cdp as G

PC = 'Administrator@100.127.143.37'
PC_DIR = 'D:/grok_att/kk/'
LAST_MSG = "(()=>{const m=[...document.querySelectorAll('[class*=message-bubble], [class*=message]')];return m.length?m[m.length-1]:null})()"


def new_tab(url):
    return json.load(urllib.request.urlopen(urllib.request.Request(G.BASE + '/json/new?' + url, method='PUT')))


def close_tab(t):
    try:
        urllib.request.urlopen(G.BASE + '/json/close/' + t['id'])
    except Exception:
        pass


def main():
    a = sys.argv[1:]
    opt = {}
    for k in ('--chat', '--wait'):
        if k in a:
            i = a.index(k); opt[k] = a[i + 1]; del a[i:i + 2]
    line, out, atts = a[0], a[1], a[2:]
    wait = min(int(opt.get('--wait', 180)), 180)
    remote = []
    for p in atts:
        subprocess.run(['scp', '-q', p, PC + ':' + PC_DIR], check=True)
        remote.append(PC_DIR.replace('/', '\\') + os.path.basename(p))
    t = new_tab('https://grok.com/c/' + opt['--chat'] if '--chat' in opt else 'https://grok.com/')
    try:
        c = G.CDP(t)
        c.call('Page.bringToFront')
        for _ in range(30):
            if c.ev("!!(%s)" % G.FIND):
                break
            time.sleep(1)
        time.sleep(4)
        if remote:
            doc = c.call('DOM.getDocument', depth=-1, pierce=True)
            node = c.call('DOM.querySelector', nodeId=doc['root']['nodeId'], selector='input[type=file]')
            if not node.get('nodeId'):
                raise SystemExit('파일 입력 없음')
            c.call('DOM.setFileInputFiles', nodeId=node['nodeId'], files=remote)
            time.sleep(4 + 2 * len(remote))
        n0 = c.ev("document.querySelectorAll('pre code, pre').length")
        lim0 = c.ev("(document.body.innerText.match(/한도에 도달|limit reached/g)||[]).length")
        c.ev("(()=>{const e=%s;e.focus();return 1})()" % G.FIND)
        c.call('Input.insertText', text=line)
        time.sleep(1)
        for typ in ('keyDown', 'keyUp'):
            c.call('Input.dispatchKeyEvent', type=typ, key='Enter', code='Enter', windowsVirtualKeyCode=13, nativeVirtualKeyCode=13)
        time.sleep(3)
        left = c.ev("(()=>{const e=%s;return e?(e.value||e.innerText||'').trim().length:-1})()" % G.FIND)
        if left and left > 0:
            c.ev("(()=>{const b=[...document.querySelectorAll('button')].find(x=>/제출|Submit|보내기|Send/.test(x.getAttribute('aria-label')||''));if(b){b.click();return 1}return 0})()")
            time.sleep(3)
        t0, last, stable = time.time(), '', 0
        while time.time() - t0 < wait:
            time.sleep(10)
            if c.ev("(document.body.innerText.match(/한도에 도달|limit reached/g)||[]).length") > lim0:
                print('LIMIT'); sys.exit(3)
            body = c.ev("document.body.innerText.slice(-800)")
            busy = c.ev("/생각 중|Thinking|생성 중|Generating/.test(document.body.innerText.slice(-500))")
            stable = stable + 1 if body == last and not busy else 0
            last = body
            if stable >= 2:
                break
        else:
            hit = c.ev("""(()=>{const b=[...document.querySelectorAll('button')].find(e=>/중지|stop/i.test((e.getAttribute('aria-label')||'')+' '+e.innerText));if(b){b.click();return 1}return 0})()""")
            if not hit:
                for typ in ('keyDown', 'keyUp'):
                    c.call('Input.dispatchKeyEvent', type=typ, key='Escape', code='Escape', windowsVirtualKeyCode=27, nativeVirtualKeyCode=27)
            time.sleep(2)
            print('TIMEOUT 생성 중지', c.ev('location.href')); sys.exit(2)
        codes = c.ev("[...document.querySelectorAll('pre code, pre')].map(e=>e.textContent)") or []
        ans = codes[-1] if len(codes) > n0 else (c.ev("(()=>{const m=%s;return m?m.innerText:''})()" % LAST_MSG) or '')
        open(out, 'w', encoding='utf-8').write(ans)
        print('저장', out, len(ans), '·', c.ev('location.href'))
    finally:
        close_tab(t)


if __name__ == '__main__':
    main()
