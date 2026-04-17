/// build_runner 发现 builder 的入口。
///
/// build.yaml 里通过 `factories: [toStringBuilder]` 指向这里。
library;

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/to_string_generator.dart';

/// PartBuilder = 生成 part-of 文件 (*.g.dart), 复用 source_gen 的合并逻辑。
Builder toStringBuilder(BuilderOptions options) => SharedPartBuilder(
      [ToStringGenerator()],
      'to_string_gen',
    );
