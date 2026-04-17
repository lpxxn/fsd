# 第 15 章 Dart Macros: 静态元编程 (实验性)

> **重要声明**: 截止 2026 年初, Dart Macros 仍然是 experimental feature, API 在变动, 并非所有 Dart 版本默认可用。本章以了解和对比为主。

## 什么是 Dart Macros

Dart Macros 是 Dart 语言团队正在推进的 **语言级元编程** 机制。
**核心差异**: 和 `build_runner` 不同, macros **不产出 `.g.dart` 文件**, 也不需要单独跑命令 —— 它们 **在编译器里** 直接为你生成额外的代码, 然后和你手写的代码一起编译。

一句话对比:

| 项 | build_runner + source_gen | Dart Macros |
|----|--------------------------|-------------|
| 何时工作 | 编译前 (开发时) | 编译中 (编译器自己跑) |
| 产物 | 可读的 `.g.dart` 文件 | 无文件, 注入到内存 AST |
| 额外命令 | `dart run build_runner build` | 无 |
| 语言集成度 | 第三方约定 | 官方, 长期路线图 |
| 生态成熟度 | 高, 全家桶已有 | 低, 还在 experimental |

## 一个大家关心的例子: `@JsonCodable`

Dart 团队给出的明星案例:

```dart
import 'package:json/json.dart';

@JsonCodable()
class User {
  final String name;
  final int age;
}

// ☝️ 什么都不用写, 编译时自动合成:
//    User.fromJson(Map<String, Object?> json)
//    Map<String, Object?> toJson()
```

对比 `json_serializable`:

- 不用写 `part 'user.g.dart';`
- 不用写 `fromJson` / `toJson` 的 factory
- 不用跑 `build_runner`

## 用的是哪个 API

当前 Dart SDK (3.5+ 实验通道) 里, 写 macro 的接口大概长这样:

```dart
import 'dart:async';
import 'package:_macros/macros.dart';

macro class JsonCodable implements ClassDeclarationsMacro, ClassDefinitionMacro {
  const JsonCodable();

  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    builder.declareInType(DeclarationCode.fromParts([
      '  external ${clazz.identifier.name}.fromJson(Map<String, Object?> json);\n',
      '  external Map<String, Object?> toJson();\n',
    ]));
  }

  @override
  FutureOr<void> buildDefinitionForClass(
    ClassDeclaration clazz,
    TypeDefinitionBuilder builder,
  ) async {
    // ... 读字段, 给上面 external 方法填上真正的实现
  }
}
```

结构上两个阶段:

1. **Declarations**: 宣布要加什么成员 (还是 external 占位)。
2. **Definitions**: 给占位填上具体实现。

编译器在编译你用宏的文件时, 会把宏实例化、把返回的代码注入 AST, 然后继续编译。用户侧几乎感知不到。

## 为什么还没取代 source_gen

- **实现复杂**: 编译器要把"运行 Dart 代码" (macro) 嵌进 "编译 Dart 代码" 的过程, 增量编译、错误定位都要重做。
- **工具链支持**: IDE (VS Code / Android Studio) 要实时看到生成成员, 对 analyzer 要求极高。
- **Flutter 版本绑定**: Flutter 对特定 Dart SDK 的 macros 支持有延迟。
- **向后兼容**: 社区常用的 `build_runner` 方案仍然可用, 不急。

当前 (2026 初) 官方给出的路线:

1. `json` 包做官方 showcase。
2. 随 Dart 3.x 持续稳定 macros API。
3. 等一批明星库 (freezed/injectable/retrofit 等) 逐个迁移到 macros, 用户再慢慢转。

## 本章 Demo (只读演示)

工程里 **不** 真正启用 macros (版本和平台都不稳定), 只把一个 "如果用 macros 会是什么样" 的对比贴在 Demo 页。
想亲自试:

```bash
# 需要 Dart SDK >= 3.5 并开实验
dart --enable-experiment=macros run your_file.dart
```

## 和本课前面章节的关系

读完前 14 章, 你已经理解:

- **注解 = 打标记给 generator 看**
- **Generator = 读 LibraryElement / 字段 / 类型**
- **输出 = Dart 字符串**
- **整合 = build_runner 调度, source_gen 封装, 产出 .g.dart**

Dart Macros 的宏本质上做的还是同一件事, 只是**把这套流水线搬进了编译器内部**, 没有中间文件。
所以理解 build_runner 的机制, 你对未来 macros 的心智模型已经搭好了一大半。

## 何时可以押注 macros

保守建议:

- **现在 (2026 初)**: 学习、浅尝, 不要在生产项目里用。
- **Dart 3.7 / 3.8**: 如果官方出了 "macros 稳定" 的公告 + IDE 全面支持, 可以在新项目小范围试。
- **多家大型库迁移后**: 再考虑大面积替换, 享受 "无 `build_runner`" 的工作流。

## 练习

1. 在网上搜最新的 Dart macros 实验进度 (比如 dart-lang/language 的 discussion), 看现在官方示范 macros 能干什么。
2. 在 `riverpod_tutorial/` 第 9 章找一个你写过的 `@riverpod` provider, 想一下: 如果 macros 彻底取代 build_runner, 代码上会看到什么差异? (答: 大概是 `part '...g.dart';` 消失, 其它体感不变。)
3. 思考: 在"显式中间产物 (`.g.dart`)"和"编译器自动注入" 两种方案里, 团队协作更看重哪种? 为什么? (提示: 代码 review 易读性、排查问题、构建速度。)
