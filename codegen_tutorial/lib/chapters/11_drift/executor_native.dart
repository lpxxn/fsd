import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// 原生平台 (iOS / Android / macOS / Windows / Linux): 用 in-memory sqlite。
QueryExecutor openExecutor() => NativeDatabase.memory();
