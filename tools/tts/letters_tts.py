#!/usr/bin/env python3
"""「문자와 발음」 글자 소리 합성 — app/lib/data/kk_letters.dart 의 say 를 읽어 app/assets/audio/letters/<id>.mp3 를 만들고
app/assets/audio/manifest.json 에 {say: "audio/letters/<id>.mp3"} 를 합친다.
  ~/.venvs/kk-corpus/bin/python tools/tts/letters_tts.py [--force]
"""
import asyncio, json, re, sys
from pathlib import Path
import edge_tts

ROOT = Path(__file__).resolve().parents[2] / 'app'
VOICE = 'kk-KZ-AigulNeural'
src = (ROOT / 'lib/data/kk_letters.dart').read_text()
items = re.findall(r"KkLetter\('[^']*', '[^']*', '([^']+)', '[^']*', '[^']*', LetterKind\.\w+, '([^']*)'", src)
out = ROOT / 'assets/audio/letters'; out.mkdir(parents=True, exist_ok=True)
man_p = ROOT / 'assets/audio/manifest.json'
man = json.loads(man_p.read_text() or '{}')
force = '--force' in sys.argv

async def one(i, say):
    f = out / f'{i}.mp3'
    if f.exists() and not force:
        return
    for t in range(4):
        try:
            await edge_tts.Communicate(say, VOICE, rate='-15%').save(str(f)); return
        except Exception as e:
            await asyncio.sleep(2 + t)
    print('FAIL', i, say)

async def main():
    todo = [(i, s) for i, s in items if s]
    await asyncio.gather(*(one(i, s) for i, s in todo))
    for i, s in todo:
        man[s] = f'audio/letters/{i}.mp3'
    man_p.write_text(json.dumps(man, ensure_ascii=False, indent=1) + '\n')
    print(len(todo), 'letters')

asyncio.run(main())
