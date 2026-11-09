#!/usr/bin/env python3
"""카자흐 키릴 → 한글 독음 결정론적 변환기 (2026-11-09).

모음 대응은 앱 「문자와 발음」(app/lib/data/kk_letters.dart)과 같다:
  а=아 ә=애 е=에(낱말 첫머리·모음 뒤 예) ё=요 и=이 і=이 ы=으 о=오 ө=외 ұ=우 ү=위 у=우(모음 앞 w) э=에 ю=유 я=야
자음: 모음 앞이면 초성, 아니면 받침(к қ г ғ→ㄱ, п б→ㅂ, л→ㄹ, м→ㅁ, н→ㄴ, ң→ㅇ) 또는 음절(т д→트·드, с→스, р→르, ж з→즈, ш щ→시, х һ→흐, ф→프, ц→츠, ч→치, в→브).
모음 사이 л 은 ㄹㄹ(сәлем 샐렘), ш+모음은 샤·셰·쇼·슈, 모음 뒤 й 는 「이」.
손으로 rd 를 고치지 말고 이 규칙·EXC 를 고친다.
usage: python3 scripts/normalize_pron.py "Сәлеметсіз бе?"   # 시험
"""
import re
import sys

CHO = {c: i for i, c in enumerate('ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎ')}
JONG = {'': 0, 'ㄱ': 1, 'ㄴ': 4, 'ㄹ': 8, 'ㅁ': 16, 'ㅂ': 17, 'ㅅ': 19, 'ㅇ': 21}
# 중성 index: ㅏ0 ㅐ1 ㅑ2 ㅒ3 ㅓ4 ㅔ5 ㅕ6 ㅖ7 ㅗ8 ㅘ9 ㅙ10 ㅚ11 ㅛ12 ㅜ13 ㅝ14 ㅞ15 ㅟ16 ㅠ17 ㅡ18 ㅢ19 ㅣ20
JUNG = {'а': 0, 'ә': 1, 'е': 5, 'ё': 12, 'и': 20, 'і': 20, 'ы': 18, 'о': 8, 'ө': 11,
        'ұ': 13, 'ү': 16, 'у': 13, 'э': 5, 'ю': 17, 'я': 2}
VOWELS = set(JUNG)
# й·ш 뒤 모음 → 이중모음
Y_JUNG = {'а': 2, 'ә': 3, 'е': 7, 'о': 12, 'ұ': 17, 'у': 17, 'ө': 11, 'ү': 16, 'ы': 20, 'і': 20, 'и': 20, 'э': 7}
# у + 모음 → w 이중모음
W_JUNG = {'а': 9, 'ә': 10, 'е': 15, 'и': 16, 'і': 16, 'о': 14}
CONS = {  # 초성, (받침 jamo | None), 받침이 안 될 때의 음절
    'б': ('ㅂ', 'ㅂ', '브'), 'п': ('ㅍ', 'ㅂ', '프'), 'в': ('ㅂ', None, '브'), 'ф': ('ㅍ', None, '프'),
    'г': ('ㄱ', 'ㄱ', '그'), 'ғ': ('ㄱ', 'ㄱ', '그'), 'к': ('ㅋ', 'ㄱ', '크'), 'қ': ('ㅋ', 'ㄱ', '크'),
    'д': ('ㄷ', None, '드'), 'т': ('ㅌ', None, '트'),
    'ж': ('ㅈ', None, '즈'), 'з': ('ㅈ', None, '즈'), 'с': ('ㅅ', None, '스'),
    'ш': ('ㅅ', None, '시'), 'щ': ('ㅅ', None, '시'), 'ч': ('ㅊ', None, '치'), 'ц': ('ㅊ', None, '츠'),
    'х': ('ㅎ', None, '흐'), 'һ': ('ㅎ', None, '흐'),
    'л': ('ㄹ', 'ㄹ', '르'), 'р': ('ㄹ', None, '르'),
    'м': ('ㅁ', 'ㅁ', '므'), 'н': ('ㄴ', 'ㄴ', '느'), 'ң': ('ㅇ', 'ㅇ', '응'),
}
# 고유명사·관용 표기(소문자 낱말 → 한글). 규칙보다 우선.
EXC = {
    'қазақстан': '카자흐스탄', 'қазақ': '카자흐', 'алматы': '알마티', 'астана': '아스타나',
    'айгерім': '아이게림', 'мадина': '마디나', 'ержан': '예르잔', 'дәурен': '대우렌',
    'кофе': '코페', 'такси': '탁시', 'сәлем': '샐렘',
}


def syl(cho, jung, jong=''):
    return [cho, jung, jong]


def compose(s):
    if isinstance(s, str):
        return s
    return chr(0xAC00 + (CHO[s[0]] * 21 + s[1]) * 28 + JONG[s[2]])


def word(w):
    lw = w.lower()
    if lw in EXC:
        return EXC[lw]
    ch = [c for c in lw if c not in 'ъь']
    out, i, n = [], 0, len(ch)
    while i < n:
        c, nx = ch[i], ch[i + 1] if i + 1 < n else ''
        prev = ch[i - 1] if i else ''
        if c in VOWELS:
            if c == 'у' and nx in W_JUNG and (not prev or prev in VOWELS):
                out.append(syl('ㅇ', W_JUNG[nx])); i += 2; continue
            j = JUNG[c]
            if c == 'е' and (not prev or prev in VOWELS):
                j = 7  # 예
            out.append(syl('ㅇ', j)); i += 1; continue
        if c == 'й':
            if nx in Y_JUNG:
                out.append(syl('ㅇ', Y_JUNG[nx])); i += 2; continue
            if prev not in ('и', 'і') and prev in VOWELS:
                out.append(syl('ㅇ', 20))
            i += 1; continue
        if c not in CONS:
            i += 1; continue
        cho, bat, alone = CONS[c]
        if nx in VOWELS:
            if c in ('ш', 'щ') and nx in Y_JUNG:
                out.append(syl('ㅅ', Y_JUNG[nx])); i += 2; continue
            if nx == 'у' and i + 2 < n and ch[i + 2] in W_JUNG:
                out.append(syl(cho, W_JUNG[ch[i + 2]])); i += 3; continue
            j = JUNG[nx]
            if c in ('л', 'ң') and out and isinstance(out[-1], list) and out[-1][2] == '' and prev in VOWELS:
                out[-1][2] = bat  # 모음 사이 л → ㄹㄹ, ң → ㅇ받침+ㅇ
            out.append(syl(cho, j)); i += 2; continue
        # 모음이 뒤따르지 않는 자음
        if bat and out and isinstance(out[-1], list) and out[-1][2] == '':
            out[-1][2] = bat
        else:
            out.append(alone)
        i += 1
    return ''.join(compose(s) for s in out)


TOKEN = re.compile(r"[А-Яа-яЁёӘәҒғҚқҢңӨөҰұҮүҺһІі-]+")


def transliterate(text):
    return TOKEN.sub(lambda m: '-'.join(word(p) for p in m.group(0).split('-') if p), text) \
        .replace('«', '').replace('»', '').replace('—', ' ')


if __name__ == '__main__':
    for a in sys.argv[1:] or ['Сәлеметсіз бе? Қалайсың? Рахмет, жақсымын. Бұл қанша тұрады? Шынымен бе? Ертең кездесейік. Уақыт жоқ. Тәуелсіздік']:
        print(transliterate(a))
