import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/umeng_verify_sdk.dart';

void main() {
  const MethodChannel channel = MethodChannel('umeng_verify_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UmengVerifySdk.VerifyVersion, '42');
  });
}
