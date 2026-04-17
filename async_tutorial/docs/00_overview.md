# 第 0 章 总览与学习路线

## 一句话先说清楚

**Dart 是单线程的，但并不意味着它只能做一件事。**

Dart 用 "事件循环（event loop）" 让一个线程也能处理网络请求、定时器、IO、动画、手势等"同时发生"的事情。`async` / `await` / `Future` / `Stream` / `Isolate`，本质上都是围绕这个事件循环的工具。

## 学习路线图

```text
第 1 章  同步 vs 异步        ← 直观感受 "为什么要异步"
   ↓
第 2 章  Future 基础          ← 异步值的抽象：一张未来的票
   ↓
第 3 章  async / await        ← 写法糖：让异步代码像同步一样读
   ↓
第 4 章  并行组合             ← 多个 Future 一起等 / 择一而返
   ↓
第 5 章  Stream 基础          ← 异步的"多值"：一连串的事件
   ↓
第 6 章  Stream 进阶          ← 自己发事件、转换事件、控制流量
   ↓
第 7 章  Flutter 集成         ← FutureBuilder / StreamBuilder
   ↓
第 8 章  事件循环原理 ★       ← 看懂这章才算入门完成
   ↓
第 9 章  Zone 与错误          ← 全局兜底
   ↓
第 10 章 Isolate 真并发       ← CPU 密集任务怎么办
   ↓
第 11 章 常见陷阱              ← 避坑大全
```

## 异步的两个核心心智模型

在开始之前先记住两句话，后面所有章节都是对这两句话的展开：

1. **异步不是"同时"，而是"轮流"**
   单个 Isolate 里，代码永远是"一段一段"执行的。`await` 只是把函数暂停、让事件循环先干别的，等事情办完再回来接着执行。

2. **Future 是"一张票"，await 是"去兑票"**
   `Future<int>` 不是 int，是"将来会给你一个 int 的承诺"。你可以把票传来传去（当参数、当返回值），真正需要数字时才用 `await` 或 `.then` 把它兑出来。

## 单线程的"并发" vs 真正的"并行"

| 名词 | 是什么 | Dart 里怎么用 |
|------|--------|----------------|
| 并发（concurrency） | 一个人身兼多职，轮流处理 | 单 Isolate + 事件循环 |
| 并行（parallelism） | 多个人同时干活 | 多个 Isolate（或 WebWorker） |

**大部分"异步"问题（网络、IO、定时器）用并发就够了**；只有 CPU 死算（图像处理、大 JSON 解析）才需要并行，也就是 Isolate。

## 推荐的实操方式

- 每章配套两份代码：`lib/pure_dart/chapter_XX.dart` 和 `lib/chapters/chapter_XX_page.dart`
- 建议先 `dart run lib/pure_dart/chapter_XX.dart` 看控制台输出，理解原理
- 再打开 Flutter Demo 页看"动起来是什么样"
- 关键章节（特别是 **第 8 章 事件循环**）**一定要自己改代码**、改一行看一眼输出，才记得住

准备好了？翻到[第 1 章](01_sync_vs_async.md)。
