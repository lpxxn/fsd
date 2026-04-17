# 第 2 章 写一个你自己的 Generator

## 目标

从零实现一个 "给 class 自动生成 toString" 的代码生成器。
要的效果:

```dart
// lib/chapters/02_custom/person.dart
import 'package:my_generator/my_generator.dart';

part 'person.g.dart';

@ToStringGen()
class Person {
  Person({required this.name, required this.age});
  final String name;
  final int age;
}

// 跑完 build_runner 后, .g.dart 里会出现:
//   String _$PersonToString(Person self) => 'Person(name=${self.name}, age=${self.age})';
// 于是我们能在类里加:
//   @override
//   String toString() => _$PersonToString(this);
```

## 包结构 (已在 `packages/my_generator/` 建好)

```text
packages/my_generator/
  pubspec.yaml
  build.yaml
  lib/
    my_generator.dart          # 对外导出: 注解 @ToStringGen
    builder.dart               # build_runner 的入口: toStringBuilder()
    src/
      to_string_generator.dart # 核心生成逻辑
```

## 逐文件讲解

### 1. `lib/my_generator.dart`: 注解

```dart
class ToStringGen {
  const ToStringGen();
}
const toStringGen = ToStringGen();
```

- 就是一个普通的 const class, 运行时根本没用。
- 它的唯一作用是 **给 generator "看" 的标记**。

### 2. `lib/src/to_string_generator.dart`: 干活的类

```dart
class ToStringGenerator extends GeneratorForAnnotation<ToStringGen> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@ToStringGen 只能用在 class 上。', element: element);
    }
    final className = element.name ?? '_Unknown';
    final fields = element.fields
        .where((f) => !f.isStatic && !f.isSynthetic)
        .toList();

    return '''
String _\$${className}ToString($className self) {
  return ${_buildStringExpression(className, fields)};
}
''';
  }
  ...
}
```

重点:

- 继承 `GeneratorForAnnotation<ToStringGen>` → source_gen 会自动帮我们筛出打了 `@ToStringGen` 的元素;
- 每找到一个, 就调用一次 `generateForAnnotatedElement`;
- 参数:
  - `element` 就是 analyzer 解析出的类/函数/字段对象, 这里是 `ClassElement`;
  - `annotation` 是注解参数 (我们这个注解无参, 没用到);
  - `buildStep` 能让你读更多文件、写额外文件, 进阶场景才用。
- 返回一个字符串, 就是生成文件的内容 (片段)。

### 3. `lib/builder.dart`: build_runner 入口

```dart
Builder toStringBuilder(BuilderOptions options) => SharedPartBuilder(
      [ToStringGenerator()],
      'to_string_gen',
    );
```

- `SharedPartBuilder`: 让多个 Generator 共享同一个 `.g.dart` 输出 (和 json_serializable 等行为一致)。
- 第二个参数 `'to_string_gen'` 是 builder 唯一名, 也决定临时文件扩展名 `.to_string_gen.g.part`。

### 4. `build.yaml` of my_generator: 注册 builder

```yaml
builders:
  to_string_gen:
    import: "package:my_generator/builder.dart"
    builder_factories: ["toStringBuilder"]
    build_extensions: { ".dart": [".to_string_gen.g.part"] }
    auto_apply: dependents      # 任何依赖 my_generator 的包自动启用
    build_to: cache             # 中间产物放到缓存, 等 combining_builder 合并
    applies_builders:
      - "source_gen|combining_builder"   # 让官方合并器帮忙做 .g.dart
```

- `auto_apply: dependents` = 只要主工程把 `my_generator` 写在依赖里, builder 就自动启用, **用户侧不需要再配 build.yaml**。
- `applies_builders: ["source_gen|combining_builder"]` = 我的 builder 产生 `.g.part` 后, 自动触发 source_gen 的合并器把它合到 `.g.dart`。

### 5. 主工程里的用法

```dart
// lib/chapters/02_custom/person.dart
import 'package:my_generator/my_generator.dart';

part 'person.g.dart';

@ToStringGen()
class Person {
  Person({required this.name, required this.age});
  final String name;
  final int age;

  @override
  String toString() => _\$PersonToString(this);
}
```

跑:

```bash
dart run build_runner build --delete-conflicting-outputs
```

会在同目录生成 `person.g.dart`, 里面就是那个 `_$PersonToString` 函数。

## 踩坑

1. **generator 包必须是 pure Dart, 不能依赖 flutter**。我们把它做成 `packages/my_generator/` 独立包, 走 path 依赖, 就是这个原因。
2. **`part '...g.dart';` 指令必须显式写**, 否则 source_gen 不知道把内容往哪合并。
3. **`build_runner` 跑不起来时**先看 `packages/my_generator/build.yaml` 里 `builder_factories` 的函数名有没有对上。
4. **注解类和 generator 类分开放**: 注解是对外的运行时依赖, generator 是 dev_dependency。这两者放一个包里也行 (我们图方便合到一起了), 生产级项目常见做法是拆成 `my_annotation` + `my_generator` 两包。
5. **analyzer 版本**: analyzer 的版本迭代快, 有时需要同步升 `source_gen` 版本以匹配。本工程 analyzer 9.x + source_gen 4.x。

## 练习

1. 扩展 `ToStringGenerator`, 支持从注解参数读一个 `include: []` 列表, 只把指定字段纳入 toString。
2. 照葫芦画瓢再写一个 `@EqualsGen` 注解, 自动生成 `_$XxxEquals` 和 `_$XxxHashCode`。
3. 思考: freezed 是怎么做到 "改一个字段, `copyWith`/`==`/`toString` 全自动更新" 的? 和我们这里的思路比, 差别在哪里?
