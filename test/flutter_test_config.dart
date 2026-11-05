import 'dart:async';
import 'dart:io';
import 'mock_http.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  HttpOverrides.global = TestHttpOverrides();
  await testMain();
}

