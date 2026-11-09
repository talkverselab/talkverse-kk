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
      expect(find.text('₩3,900'), findsOneWidget);
      expect(find.text('₩5,500'), findsOneWidget);
      expect(find.textContaining('카자흐어유니버스'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }
}
