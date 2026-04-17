import 'package:drift/drift.dart';

/// 不存在 dart:ffi 也不存在 dart:html 的兜底。理论上不会被触发。
QueryExecutor openExecutor() =>
    throw UnsupportedError('drift 在此平台不可用, 请在原生平台跑本章 Demo。');
