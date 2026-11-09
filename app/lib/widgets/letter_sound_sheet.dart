import '../core/embed_env.dart';
import 'dart:async';

import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../data/kk_letters.dart';
import '../services/tts_service.dart';
import 'vowel_compare_chart.dart';

/// 글자 탭 → 발음 상세 시트(일본어앱 kana_sound_sheet 와 같은 구성, 2026-11-08).
/// 열리면 1초 뒤 자동 재생(TtsService.speak 가 1초 지연), IPA·소리 나는 곳·모음 위치·조음 위치 그림·한국어 비교, 다시 듣기.
Future<void> showLetterSoundSheet(BuildContext context, KkLetter l, Color color) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.washi,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (_) => _LetterSoundSheet(letter: l, color: color),
  );
}

class _LetterSoundSheet extends StatefulWidget {
  final KkLetter letter;
  final Color color;
  const _LetterSoundSheet({required this.letter, required this.color});

  @override
  State<_LetterSoundSheet> createState() => _LetterSoundSheetState();
}

class _LetterSoundSheetState extends State<_LetterSoundSheet> {
  bool _showChart = false;

  @override
  void initState() {
    super.initState();
    if (widget.letter.hasSound) unawaited(TtsService.instance.speak(widget.letter.say));
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  String _kindLabel(KkLetter l) => switch (l.kind) {
        LetterKind.backVowel => tr('뒤 모음'),
        LetterKind.frontVowel => tr('앞 모음'),
        LetterKind.vowelLoan => tr('모음 · 러시아어 낱말용'),
        LetterKind.consonant => tr('자음'),
        LetterKind.consonantLoan => tr('자음 · 주로 러시아어 낱말'),
        LetterKind.sign => tr('부호 · 소리 없음'),
      };

  @override
  Widget build(BuildContext context) {
    final l = widget.letter;
    final color = widget.color;
    final vc = kVowelCharts[l.lower];
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scroll) => SafeArea(
        top: false,
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.fromLTRB(20, 12, 20, 32 + bottomInset(context)),
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: AppColors.sumiLight.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
                child: Text('${l.upper}${l.lower}',
                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppColors.washi)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(l.latin, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 4),
                  if (l.hasSound)
                    Text('IPA [${l.ipa}]', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                  const SizedBox(height: 2),
                  Text(_kindLabel(l) + (l.native ? tr(' · 카자흐어 고유 글자') : ''),
                      style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, fontWeight: FontWeight.w600)),
                ]),
              ),
              if (l.hasSound)
                IconButton(
                  iconSize: 44,
                  color: color,
                  tooltip: tr('다시 듣기'),
                  icon: const Icon(Icons.play_circle_fill),
                  onPressed: () => TtsService.instance.speak(l.say),
                ),
            ]),
            if (l.hasSound && l.say != l.lower) ...[
              const SizedBox(height: 6),
              Text(trf('들려주는 소리: {0}', [l.say]), style: const TextStyle(fontSize: 11.5, color: AppColors.sumiLight)),
            ],
            const SizedBox(height: 20),
            _section(tr('👄 소리 나는 곳 · 입 모양'), l.place, color),
            if (vc != null) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.washiDeep,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.35)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(tr('📍 모음 위치 — 카자흐어 vs 한국어'), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
                  const SizedBox(height: 10),
                  VowelCompareChart(data: vc),
                ]),
              ),
            ],
            if (!l.isVowel && l.hasSound) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => setState(() => _showChart = !_showChart),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Icon(_showChart ? Icons.expand_less : Icons.expand_more, size: 18, color: color),
                    Text(tr('자음 조음 위치 그림 보기'), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                  ]),
                ),
              ),
              if (_showChart)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(assetPath('assets/images/ipa/places_of_articulation.png'), fit: BoxFit.contain),
                  ),
                ),
            ],
            const SizedBox(height: 14),
            _section(tr('🇰🇷 한국어와 비교'), trf('비슷한 소리: {0}\n\n{1}', [l.korSim, l.korDiff]), color),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body, Color color) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.washiDeep,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.sumi)),
        ]),
      );
}
