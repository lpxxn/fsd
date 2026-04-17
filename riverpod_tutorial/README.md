# Riverpod 3 深入教程

> 面向 Flutter 开发者的 **可运行** 中文 Riverpod 教程。先教**手写 Provider**理解原理，再切到 `@riverpod` **代码生成**对照。最后一章是综合实战项目。
>
> 和同仓库的 [`../async_tutorial`](../async_tutorial) 风格一致：一章一 Markdown、一章一个可点的 Demo 页。

## 使用的版本

| 包 | 版本 | 用途 |
|----|------|------|
| `flutter_riverpod` | ^3.3.1 | 运行时 |
| `riverpod_annotation` | ^4.0.2 | `@riverpod` 注解 |
| `riverpod_generator` | ^4.0.3 | 代码生成 |
| `build_runner` | ^2.x | 运行生成器 |

关于 `riverpod_lint` / `custom_lint`：截止本教程写作时，这两个包尚未适配 Riverpod 3.x（与 `flutter_riverpod ^3.3.1` 的版本约束冲突）。我们使用 `flutter_lints` 作为替代。等生态跟进后可以再加。

## 学习路线

| 章 | 主题 | 难度 |
|----|------|------|
| 00 | [总览与选型](docs/00_overview.md) | ⭐ |
| 01 | [第一个 Provider](docs/01_first_provider.md) | ⭐ |
| 02 | [ref 三件套：watch / read / listen](docs/02_ref_watch_read_listen.md) | ⭐⭐ |
| 03 | [Notifier 可变状态](docs/03_notifier_mutable.md) | ⭐⭐ |
| 04 | [FutureProvider 与 AsyncValue](docs/04_future_async_value.md) | ⭐⭐ |
| 05 | [AsyncNotifier 异步可变状态](docs/05_async_notifier.md) | ⭐⭐⭐ |
| 06 | [StreamProvider](docs/06_stream_provider.md) | ⭐⭐ |
| 07 | [依赖组合与 family 带参数](docs/07_dependency_and_family.md) | ⭐⭐⭐ |
| 08 | [autoDispose 与生命周期](docs/08_autodispose_lifecycle.md) | ⭐⭐⭐ |
| 09 | [代码生成 @riverpod](docs/09_codegen_riverpod.md) | ⭐⭐⭐ |
| 10 | [测试与 override](docs/10_testing_override.md) | ⭐⭐⭐ |
| 11 | [内部原理：Scope/Element/依赖图](docs/11_internals_scope_graph.md) | ⭐⭐⭐⭐ |
| 12 | [架构分层 data/application/presentation](docs/12_architecture_layering.md) | ⭐⭐⭐ |
| 13 | [综合实战：Todo App](docs/13_project_todo_app.md) | ⭐⭐⭐⭐ |

## 怎么跑

```bash
cd riverpod_tutorial
flutter pub get

# 运行代码生成（第 9 章及之后的章节需要）
dart run build_runner build --delete-conflicting-outputs
# 或开启 watch 模式
dart run build_runner watch --delete-conflicting-outputs

# 启动 App（首页是章节目录）
flutter run

# 跑测试（第 10 章引入）
flutter test
```

## 项目结构

```text
riverpod_tutorial/
  docs/           每章一篇教程 Markdown
  lib/
    main.dart     入口 (ProviderScope + 目录索引)
    common/       公共 UI
    chapters/     每章一个 Demo 页 (chapter_01_page.dart ... chapter_13_page.dart)
    project/      第 13 章综合项目 (Todo App, 三层架构)
  test/           第 10、13 章引入的单元 / Widget 测试
```

## 学习建议

- 第 1–8 章：**全部手写** Provider，搞清楚每种 Provider 的本质
- 第 9 章：把手写的全部一一改写成 codegen；两种写法的语义映射记在心里
- 第 11 章：和第 7、8 章的内容相互印证，此时原理应该自然贯通
- 第 13 章：综合项目，把前面学的都用上；建议看完再自己从头写一遍
