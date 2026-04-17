# 第 10 章 Isolate：真正的并行

## 为什么 await 救不了 CPU 密集

```dart
Future<int> heavy() async {
  var s = 0;
  for (var i = 0; i < 1000000000; i++) {
    s += i;
  }
  return s;
}
```

这个函数标了 `async`，但里面是**纯 CPU 循环**。执行期间：
- 事件循环被霸占
- UI 不会渲染
- 手势不响应

`async/await` 只能让 **IO/定时器** 等待时线程不空转，**不能让 CPU 并行**。

想真并行，只能开 **Isolate**。

## Isolate 是什么

- Dart 的"独立执行体"——你可以把它当成"一个带自己内存和事件循环的协程"
- **Isolate 之间不共享内存**（根本拿不到对方的对象）
- 只能通过 **消息传递（message passing）** 通信
- 消息会被**深拷贝**（或 transfer）后发过去

这不是 JS 的 WebWorker，也不是 Java 的 Thread，更接近 Erlang 的 Actor 模型。

## 最简单的用法：`Isolate.run`

Dart 2.19+ 新增，**推荐大部分场景用它**：

```dart
final result = await Isolate.run(() {
  var s = 0;
  for (var i = 0; i < 1000000000; i++) s += i;
  return s;
});
print(result);
```

它背后会：
1. spawn 一个临时 Isolate
2. 运行你给的函数
3. 把结果通过消息传回
4. 销毁 Isolate

用起来就像 `await Future`，但实际在另一个 CPU 核跑。

## Flutter 里的捷径：`compute`

`compute` 是 Flutter 早期对 `Isolate` 的封装，现在功能被 `Isolate.run` 覆盖了，但依然常用：

```dart
import 'package:flutter/foundation.dart';

final result = await compute(_heavy, 1000000);

int _heavy(int n) {
  var s = 0;
  for (var i = 0; i < n; i++) s += i;
  return s;
}
```

**约束**：传给 `compute` 的函数必须是 **顶层函数或 static 方法**（闭包捕获的变量在 Isolate 里拿不到）。`Isolate.run` 在新版 Dart 里放宽了这个限制。

## 手动 spawn + 双向通信（进阶）

当你需要持续和 Isolate 交互（不是单次计算），用 `Isolate.spawn` + `SendPort/ReceivePort`：

```dart
import 'dart:isolate';

Future<void> main() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(_worker, receivePort.sendPort);

  // 子 Isolate 启动后会发一个它自己的 SendPort 回来，用于双向通信
  final workerSendPort = await receivePort.first as SendPort;

  final answer = ReceivePort();
  workerSendPort.send([5, answer.sendPort]);
  print(await answer.first); // 25
}

void _worker(SendPort mainPort) {
  final port = ReceivePort();
  mainPort.send(port.sendPort);
  port.listen((msg) {
    final (int x, SendPort reply) = (msg[0] as int, msg[1] as SendPort);
    reply.send(x * x);
  });
}
```

关键点：
- `ReceivePort` 用来**收**，本身是一个 Stream
- `SendPort` 用来**发**，可以跨 Isolate 传递
- 发送的对象会被**深拷贝**（Dart 3 后有 `TransferableTypedData` 可以零拷贝大二进制）

## 能传什么不能传什么

**可以传**：
- 基本类型、String、List、Map、Set
- 纯数据类（没有闭包引用）
- `SendPort`、`TransferableTypedData`
- 第 3.5+ 后的某些可传递对象

**不能传**：
- 含有闭包/函数引用的对象（在隔离里捕获不到原上下文）
- Isolate 之间共享的可变对象——**根本不共享**，永远是拷贝

## 何时该用 Isolate

| 场景 | 用什么 |
|------|--------|
| 网络请求、IO、定时器 | `async/await`，**不用 Isolate** |
| 一次性大 JSON 解析（几 MB 以上） | `compute` / `Isolate.run` |
| 图像/视频处理 | Isolate |
| 长期后台任务（心跳、WS 解码） | `Isolate.spawn` + 消息循环 |
| 粒度很细的小计算 | **不要**用，spawn 的开销比计算还大 |

## 一个实测数据感

在普通手机上：
- `Isolate.run` 冷启动大约 **5–20ms**
- 消息传递一次普通对象 **< 1ms**
- 所以只有当你要做的活 **超过 50ms** 时，开 Isolate 才划算

## 小结

- 单 Isolate 内是"并发"，多 Isolate 才是"并行"
- **CPU 密集 → Isolate；IO 密集 → async**
- 优先用 `Isolate.run`（或 Flutter 的 `compute`），复杂场景再 `Isolate.spawn`
- Isolate 之间**消息传递、不共享内存**

## 练习题

1. 用 `compute` 算斐波那契（递归版），对比放在主 Isolate 里 UI 会不会卡。
2. 用 `Isolate.spawn` 实现一个"乘方计算服务"，主 Isolate 可以发多次请求。
3. 测量启动 Isolate 的耗时，决定"多小的任务不值得开 Isolate"。

最后一章是避坑集合 → [第 11 章](11_pitfalls.md)。
