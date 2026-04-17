# Flutter 代码生成教程 (codegen_tutorial)

这是 `async_tutorial` / `riverpod_tutorial` 之后的第三个教学工程, 系统讲解 Flutter/Dart 的代码生成生态。

> 一个主题 = 一篇 Markdown (docs/) + 一个可交互 Demo (lib/chapters/)。

## 如何跑

```bash
flutter pub get
# 生成所有 *.g.dart / *.freezed.dart / *.gr.dart
dart run build_runner build --delete-conflicting-outputs
# 启动 app
flutter run
```

监听模式 (推荐开发时开着):

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 章节

| # | 主题 | 文档 |
|---|------|------|
| 00 | 总览 | [docs/00_overview.md](docs/00_overview.md) |
| 01 | build_runner 内部原理 | [docs/01_build_runner_internals.md](docs/01_build_runner_internals.md) |
| 02 | 写自己的 Generator | [docs/02_write_your_own_generator.md](docs/02_write_your_own_generator.md) |
| 03 | json_serializable | [docs/03_json_serializable.md](docs/03_json_serializable.md) |
| 04 | freezed | [docs/04_freezed.md](docs/04_freezed.md) |
| 05 | built_value 对照 | [docs/05_built_value_compare.md](docs/05_built_value_compare.md) |
| 06 | riverpod_generator 精讲 | [docs/06_riverpod_generator.md](docs/06_riverpod_generator.md) |
| 07 | injectable + get_it | [docs/07_injectable_get_it.md](docs/07_injectable_get_it.md) |
| 08 | mockito / mocktail | [docs/08_mockito_mocktail.md](docs/08_mockito_mocktail.md) |
| 09 | retrofit | [docs/09_retrofit.md](docs/09_retrofit.md) |
| 10 | auto_route | [docs/10_auto_route.md](docs/10_auto_route.md) |
| 11 | drift | [docs/11_drift.md](docs/11_drift.md) |
| 12 | isar / hive 对照 | [docs/12_nosql_isar_hive.md](docs/12_nosql_isar_hive.md) |
| 13 | l10n / gen_l10n | [docs/13_l10n_gen_l10n.md](docs/13_l10n_gen_l10n.md) |
| 14 | flutter_gen 资源 | [docs/14_flutter_gen_assets.md](docs/14_flutter_gen_assets.md) |
| 15 | Dart Macros | [docs/15_dart_macros_future.md](docs/15_dart_macros_future.md) |

## 工程结构

```text
codegen_tutorial/
  docs/                       # 16 篇中文章节
  packages/my_generator/      # 第 2 章: 自己写的 source_gen generator
  lib/
    main.dart                 # 章节目录
    common/chapter_scaffold.dart
    chapters/                 # 每章一个 Demo 页
      chapter_XX_page.dart
      03_json/, 04_freezed/, 07_injectable/ ...  # 带代码生成的源文件按章分目录
  test/                       # 章节相关的测试
  assets/                     # 第 14 章 flutter_gen 演示
  lib/l10n/                   # 第 13 章 l10n ARB 文件
  build.yaml
  analysis_options.yaml
  pubspec.yaml
```

## 使用的版本

| 包 | 版本 | 用途 |
|----|------|------|
| build_runner | ^2.4.13 | 代码生成驱动 |
| json_serializable / json_annotation | ^6.8 / ^4.9 | JSON 序列化 |
| freezed / freezed_annotation | ^3.0 / ^3.0 | 不可变 data class / union |
| riverpod_generator | ^4.0.3 | @riverpod 代码生成 |
| injectable / injectable_generator | ^2.5 / ^2.6 | DI |
| retrofit / retrofit_generator | ^4.4 / ^10.2 | HTTP client codegen |
| auto_route / auto_route_generator | any | type-safe 路由 |
| drift / drift_dev | ^2.20 / ^2.20 | SQLite ORM |
| flutter_gen_runner | ^5.7 | 资源代码生成 |
| mockito / mocktail | ^5.4 / ^1.0 | 测试 mock |

## 已知限制

- **drift 在 Flutter Web 默认不可用**: 第 11 章 Demo 检测 `kIsWeb` 时做优雅降级提示。
- **auto_route / retrofit_generator 的版本要匹配 Dart analyzer**: 我们用的是 Dart 3.11.x 对应的最新组合。
- **Dart Macros 仍在实验阶段**: 第 15 章文档为主, Demo 可能需要 Dart ≥ 3.5 并加 `--enable-experiment=macros` 才能跑。
- **riverpod_lint / custom_lint**: 与 Riverpod 3.x 不兼容, 沿用 riverpod_tutorial 的做法不引入。

## 写作风格

- 全中文, 首次出现术语括英文原词。
- 不用 emoji。
- 每章强调 "**生成文件里到底多了什么**": 把生成代码关键片段贴进文档 + 逐行注释。
- 每章结尾 2–3 道练习题。
