import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kk_app/core/embed_env.dart';
import 'package:kk_app/embed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('옛 저장 이름 → kk_ 접두로 한 번 이전', () async {
    final dir = Directory.systemTemp.createTempSync('kkmig');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('plugins.flutter.io/path_provider'), (_) async => dir.path);
    Directory('${dir.path}/art').createSync();
    SharedPreferences.setMockInitialValues({
      'achievements_v1': '{"x":1}', 'db_version': 1, 'speak_best_42': 3, 'memo:p1:0': 'hi', 'iap_pending': ['r'],
      'learner_name': 'Mina', 'app_lang': 'ko',
    });
    await migrateStorage();
    final p = await SharedPreferences.getInstance();
    expect(p.getString('kk_achievements_v1'), '{"x":1}');
    expect(p.getInt('kk_db_version'), 1);
    expect(p.getInt('kk_speak_best_42'), 3);
    expect(p.getString('kk_memo:p1:0'), 'hi');
    expect(p.getStringList('kk_iap_pending'), ['r']);
    expect(p.containsKey('achievements_v1'), false);
    expect(p.getString('learner_name'), 'Mina'); // 공유 값은 그대로
    expect(p.getString('app_lang'), 'ko');
    expect(Directory('${dir.path}/kk_art').existsSync(), true);
    await p.setString('dialogue_last', 'new');
    await migrateStorage(); // 두 번째는 아무것도 안 한다
    expect(p.getString('dialogue_last'), 'new');
  });

  test('assetPath 는 통합 모드에서만 패키지 접두', () {
    expect(assetPath('assets/x.json'), 'assets/x.json');
    Embed.embedded = true;
    expect(assetPath('assets/x.json'), 'packages/kk_app/assets/x.json');
    expect(audioAssetPrefix, 'packages/kk_app/assets/');
    Embed.embedded = false;
  });
}
