import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kk_app/screens/sense_course_screen.dart';
import 'package:kk_app/services/script_sync.dart';

/// 문법(언어감각) 내용 = 앱 묶음 기본값 → 서버 원고가 있으면 그것(2026-11-23 사용자 「스텝 10 까지 미리 만들어놓고 DB 업데이트 하면서 업뎃」).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Map<String, dynamic> lesson(String id, int n) => {
        'id': id,
        'kind': 'memorize',
        'sentences': [for (var i = 0; i < n; i++) {'tl': 'Сөз$i', 'ko': '뜻$i'}],
      };

  test('빈 스텝은 숨기고, 내용이 생기면 나타난다', () {
    final d = {
      'levels': [
        for (var i = 1; i <= 10; i++)
          {'id': 'L$i', 'title': '급 $i', 'lessons': [lesson('L$i-1', i <= 7 ? 3 : 0), {'id': 'L$i-ref', 'kind': 'ref', 'points': <dynamic>[]}]},
      ],
    };
    expect(SenseCourse.levels(d).map((l) => l['id']), ['L1', 'L2', 'L3', 'L4', 'L5', 'L6', 'L7']);
    expect(SenseCourse.flat(d).length, 7); // 빈 참고 회차도 빠짐
    ((d['levels'] as List)[8] as Map)['lessons'] = [lesson('L9-1', 2)];
    expect(SenseCourse.levels(d).map((l) => l['id']).last, 'L9');
  });

  test('서버 원고에 문법 파일이 있으면 그것, 없으면 앱 묶음', () async {
    final dir = Directory.systemTemp.createTempSync('grammar_sync');
    addTearDown(() => dir.deleteSync(recursive: true));
    const rel = 'grammar/sense_course.json';
    final server = json.encode({'levels': [{'id': 'L1', 'title': '서버판', 'lessons': [lesson('L1-1', 1)]}]});
    final sha = sha1.convert(utf8.encode(server)).toString().substring(0, 12);
    final s = ScriptSync.forTest(
      dir: dir,
      fetch: (url) async => url.endsWith('/index.json') ? json.encode({'rev': 2, 'files': {rel: sha}}) : (url.contains(rel) ? server : null),
      baseline: {'rev': 1, 'files': {rel: 'old'}},
    );
    expect(await s.refresh(), isTrue);
    expect(json.decode(await s.load(rel))['levels'][0]['title'], '서버판');

    final none = ScriptSync.forTest(dir: Directory.systemTemp.createTempSync('grammar_none'), fetch: (_) async => null, baseline: {'rev': 1, 'files': {rel: 'x'}});
    await none.init();
    final bundled = json.decode(await none.load(rel)) as Map<String, dynamic>;
    expect(SenseCourse.levels(bundled).length, 10); // 앱 묶음 = 10급 모두 내용 있음
  });
}
