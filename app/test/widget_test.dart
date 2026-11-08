import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kk_app/core/theme.dart';
import 'package:kk_app/screens/about_screen.dart';

void main() {
  aboutFits(320);
  aboutFits(744);

  testWidgets('Theme builds', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(body: Text('hola')),
    ));
    expect(find.text('hola'), findsOneWidget);
  });

  test('conjColor maps groups', () {
    expect(conjColor('ar'), AppColors.ar);
    expect(conjColor('irregular'), AppColors.irregular);
    expect(conjColor(null), AppColors.neutral);
  });
}

void aboutFits(double width) => testWidgets('About screen fits at $width', (t) async {
      t.view.devicePixelRatio = 1;
      t.view.physicalSize = Size(width, 900);
      addTearDown(t.view.reset);
      await t.pumpWidget(MaterialApp(theme: AppTheme.light(), home: const AboutScreen()));
      await t.pump();
      expect(find.textContaining('준비 중'), findsOneWidget); // 절벽 산출 전(초기 빌드)
      expect(t.takeException(), isNull);
    });
