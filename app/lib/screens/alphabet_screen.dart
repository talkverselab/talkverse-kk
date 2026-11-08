import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../data/kk_letters.dart';
import '../services/tts_service.dart';
import '../widgets/letter_sound_sheet.dart';

/// 「문자와 발음」 — 카자흐어 키릴 42자(일본어앱 「50음도와 발음」과 같은 구성, 공통 프롬프터 §5-3, 2026-11-08).
/// 격자 + 묶음 칩(전체·모음·고유 글자·모음조화·러시아어 낱말용) + 로마자 토글. 글자 탭 → 발음 시트(1초 뒤 자동 재생).
class AlphabetScreen extends StatefulWidget {
  const AlphabetScreen({super.key});

  @override
  State<AlphabetScreen> createState() => _AlphabetScreenState();
}

class _AlphabetScreenState extends State<AlphabetScreen> {
  int _set = 0; // 0 전체, 1 모음, 2 고유 글자, 3 모음조화, 4 러시아어 낱말용
  bool _showLatin = true;

  static const _frontColor = Color(0xFFD9669B); // 앞 모음(어순 맞대기 점 색과 같은 계열)

  static Color colorOf(KkLetter l) => switch (l.kind) {
        LetterKind.backVowel => AppColors.beni,
        LetterKind.frontVowel => _frontColor,
        LetterKind.consonant => AppColors.tinta,
        _ => AppColors.muted,
      };

  List<String> get _labels => [tr('전체 42'), tr('모음'), tr('고유 글자 9'), tr('모음조화'), tr('러시아어 낱말용')];

  List<KkLetter> _filtered() => switch (_set) {
        1 => kKkLetters.where((l) => l.isVowel).toList(),
        2 => kKkLetters.where((l) => l.native).toList(),
        4 => kKkLetters.where((l) => l.isLoan).toList(),
        _ => kKkLetters,
      };

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(tr('문자와 발음'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(tr('탭하면 발음·IPA 상세'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
        ]),
        actions: [
          IconButton(
            tooltip: tr('로마자'),
            icon: Text('Aa', style: TextStyle(fontWeight: FontWeight.w900, color: _showLatin ? AppColors.beni : AppColors.sumiLight)),
            onPressed: () => setState(() => _showLatin = !_showLatin),
          ),
        ],
      ),
      body: Column(children: [
        _chips(),
        Expanded(child: _set == 3 ? _harmony(context) : _grid(context, _filtered())),
      ]),
    );
  }

  Widget _chips() => Container(
        color: AppColors.washiDeep,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: List.generate(_labels.length, (i) {
              final sel = _set == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _set = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.beni : AppColors.washi,
                      border: Border.all(color: AppColors.beni, width: sel ? 1.5 : 0.8),
                    ),
                    child: Text(_labels[i],
                        style: TextStyle(color: sel ? AppColors.washi : AppColors.beni, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                ),
              );
            }),
          ),
        ),
      );

  Widget _legend() => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Wrap(spacing: 12, runSpacing: 4, children: [
          _dot(AppColors.beni, tr('뒤 모음')),
          _dot(_frontColor, tr('앞 모음')),
          _dot(AppColors.tinta, tr('자음')),
          _dot(AppColors.muted, tr('러시아어 낱말용')),
          _dot(AppColors.kazakh, tr('고유 글자(금색 테두리)')),
        ]),
      );

  Widget _dot(Color c, String s) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(s, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c)),
      ]);

  Widget _grid(BuildContext context, List<KkLetter> letters) => LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth - 24;
        final cols = w < 340 ? 5 : (w < 560 ? 6 : (w < 800 ? 7 : 9));
        return ListView(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 40 + bottomInset(context)),
          children: [
            _legend(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols, mainAxisSpacing: 6, crossAxisSpacing: 6, mainAxisExtent: 70),
              itemCount: letters.length,
              itemBuilder: (context, i) => _cell(context, letters[i]),
            ),
          ],
        );
      });

  Widget _cell(BuildContext context, KkLetter l) {
    final color = colorOf(l);
    return InkWell(
      onTap: () => showLetterSoundSheet(context, l, color),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.washi,
          border: Border.all(color: l.native ? AppColors.kazakh : color.withValues(alpha: 0.7), width: l.native ? 2 : 1),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 4, offset: const Offset(1, 2))],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('${l.upper}${l.lower}',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: l.isLoan ? AppColors.sumiLight : AppColors.sumi, height: 1.1)),
          ),
          if (_showLatin) Text(l.latin, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }

  Widget _harmony(BuildContext context) {
    KkLetter of(String lower) => kKkLetters.firstWhere((l) => l.lower == lower);
    Widget big(KkLetter l) => Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: SizedBox(height: 70, child: _cell(context, l)),
          ),
        );
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 40 + bottomInset(context)),
      children: [
        Text(tr('카자흐어 낱말은 모음이 뒤 모음끼리, 또는 앞 모음끼리 모입니다. 접사도 낱말의 마지막 모음에 맞춰 모양을 고릅니다.'),
            style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.sumi)),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: Center(child: Text(tr('뒤 모음'), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.beni)))),
          const SizedBox(width: 24),
          Expanded(child: Center(child: Text(tr('앞 모음'), style: const TextStyle(fontWeight: FontWeight.w800, color: _frontColor)))),
        ]),
        const SizedBox(height: 6),
        for (final (b, f) in kHarmonyPairs)
          Row(children: [
            big(of(b)),
            const SizedBox(width: 24, child: Icon(Icons.swap_horiz, size: 18, color: AppColors.sumiLight)),
            big(of(f)),
          ]),
        Row(children: [
          const Expanded(child: SizedBox()),
          const SizedBox(width: 24),
          big(of('е')),
        ]),
        const SizedBox(height: 14),
        Text(tr('짝을 이루는 자음도 있습니다: 뒤 모음 옆에는 қ·ғ, 앞 모음 옆에는 к·г.'),
            style: const TextStyle(fontSize: 13, height: 1.55, color: AppColors.sumi)),
        const SizedBox(height: 8),
        Row(children: [
          big(of('қ')),
          const SizedBox(width: 24, child: Icon(Icons.swap_horiz, size: 18, color: AppColors.sumiLight)),
          big(of('к')),
        ]),
        Row(children: [
          big(of('ғ')),
          const SizedBox(width: 24, child: Icon(Icons.swap_horiz, size: 18, color: AppColors.sumiLight)),
          big(of('г')),
        ]),
      ],
    );
  }
}
