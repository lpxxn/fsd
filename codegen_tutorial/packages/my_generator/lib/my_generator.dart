/// 对外导出给主工程用的 "注解"。
///
/// 真正的代码生成逻辑在 `builder.dart` + `src/to_string_generator.dart`，
/// 由 `build_runner` 解析 build.yaml 启动。
library;

/// 给一个 class 打上这个注解, build_runner 会为它生成一份 toString()。
///
/// 用法见第 2 章 Demo: lib/chapters/02_custom/person.dart。
class ToStringGen {
  const ToStringGen();
}

const toStringGen = ToStringGen();
