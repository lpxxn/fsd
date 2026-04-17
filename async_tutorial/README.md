# Flutter / Dart 异步编程教程（由浅入深）

> 面向 Flutter 新手的一套 **可运行** 的中文异步教程。每一章都有：
>
> - 一篇讲原理的 Markdown（在 `docs/`）
> - 一个可点可交互的 Flutter Demo 页（在 `lib/chapters/`）
> - 一份可用 `dart run` 直接跑的纯 Dart 脚本（在 `lib/pure_dart/`）
>
> 不只告诉你"怎么写"，更告诉你"为什么这么写"和"底层是怎么跑的"。

## 学习路径

| 章节 | 主题 | 难度 |
|------|------|------|
| 00 | [总览与学习路线](docs/00_overview.md) | ⭐ |
| 01 | [同步 vs 异步：为什么需要异步](docs/01_sync_vs_async.md) | ⭐ |
| 02 | [Future 基础：then/catchError/whenComplete](docs/02_future_basics.md) | ⭐ |
| 03 | [async / await 语法糖与错误处理](docs/03_async_await.md) | ⭐⭐ |
| 04 | [并行组合：Future.wait / any / 串并对比](docs/04_parallel_future.md) | ⭐⭐ |
| 05 | [Stream 基础：单订阅、广播、await for](docs/05_stream_basics.md) | ⭐⭐ |
| 06 | [Stream 进阶：StreamController、转换、背压](docs/06_stream_advanced.md) | ⭐⭐⭐ |
| 07 | [Flutter 集成：FutureBuilder / StreamBuilder](docs/07_flutter_builders.md) | ⭐⭐ |
| 08 | [事件循环原理（核心）：微任务 vs 事件队列](docs/08_event_loop.md) | ⭐⭐⭐⭐ |
| 09 | [Zone 与全局错误处理](docs/09_zone_and_errors.md) | ⭐⭐⭐ |
| 10 | [Isolate 与真并发：compute / Isolate.run](docs/10_isolate.md) | ⭐⭐⭐⭐ |
| 11 | [常见陷阱与最佳实践](docs/11_pitfalls.md) | ⭐⭐⭐ |

## 怎么跑

### 1. 跑 Flutter UI 版

```bash
cd async_tutorial
flutter pub get
flutter run
```

启动后首页是一个**章节目录**，点进去就是对应章节的可交互 Demo。

### 2. 跑纯 Dart 脚本（推荐配合章节阅读）

```bash
cd async_tutorial
dart run lib/pure_dart/chapter_02.dart
dart run lib/pure_dart/chapter_08.dart   # 这一章必须看控制台输出
```

纯 Dart 脚本不依赖 UI，专门用来在控制台观察 `print` 顺序，验证书里讲的规律。

## 写作原则

每一章都遵循：**问题引入 → 最小代码 → 逐行拆解 → 原理/图示 → 踩坑 → 练习题**。

术语第一次出现时都会括注英文原词，例如："微任务（microtask）"、"事件循环（event loop）"，方便你以后查英文资料。

## 推荐阅读顺序

- **只想会写业务**：0 → 1 → 2 → 3 → 4 → 7 → 11
- **想搞懂原理**：完整读完 0 → 11，重点反复看 8、10
- **临时救火查 bug**：直接看 11
