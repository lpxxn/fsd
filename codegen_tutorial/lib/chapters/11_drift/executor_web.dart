import 'package:drift/drift.dart';

/// Web 平台: 不接真实数据库。Demo 页会走 kIsWeb 分支, 根本不会调到这里。
/// 这里只是为了让 web 编译通过。
QueryExecutor openExecutor() => throw UnsupportedError(
      'drift 在 Flutter Web 需要 drift_wasm + sqlite3.wasm 配置, '
      '本 Demo 只在原生平台启用。',
    );
