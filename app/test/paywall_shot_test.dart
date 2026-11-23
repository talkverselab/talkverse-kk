import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kk_app/core/theme.dart';
import 'package:kk_app/data/purchase.dart';
import 'package:kk_app/screens/paywall_screen.dart';

void main() {
  for (final w in [320.0, 744.0]) {
    testWidgets('paywall fits at $w', (t) async {
      Purchase.plans = const [
        Plan('lang_kk_1m', 1, 3900, listKrw: 5500),
        Plan('lang_kk_3m', 3, 9000, listKrw: 12900),
        Plan('lang_kk_1y', 12, 19900, listKrw: 28500),
        Plan('lang_kk_life', 0, 49000, listKrw: 69900),
        Plan('all_1y', 12, 79000, listKrw: 112900, bundle: true),
        Plan('all_life', 0, 329000, listKrw: 469000, bundle: true),
      ];
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(w, 1800);
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const Scaffold(body: PaywallScreen())));
      await t.pump();
      // 가격은 스토어 값만 — 스토어를 못 받은 테스트에서는 원화·할인 표시가 없어야 한다(PAYWALL_SPEC §3)
      expect(find.textContaining('₩'), findsNothing);
      expect(find.textContaining('할인'), findsNothing);
      expect(find.textContaining('Talkverse → '), findsOneWidget); // 해지 안내는 Talkverse 이름
      expect(find.textContaining('커리큘럼 2단계부터'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
