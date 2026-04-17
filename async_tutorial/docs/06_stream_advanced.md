# 第 6 章 Stream 进阶：造、转、控

## 自己造：StreamController

```dart
final ctrl = StreamController<int>();

ctrl.stream.listen(
  (v) => print('收到 $v'),
  onDone: () => print('done'),
);

ctrl.add(1);
ctrl.add(2);
ctrl.addError('uh oh');
ctrl.add(3);
await ctrl.close(); // 必须关闭，否则 onDone 永远不触发
```

要点：
- `StreamController<T>()` 默认是**单订阅**
- `StreamController<T>.broadcast()` 是**广播**
- **一定要 close**，否则下游 `await for` / `onDone` 永远等不到

## 自己造：async*（生成器）

```dart
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;          // 发一个事件
  }
  // 函数结束 = Stream 自动 done
}
```

`async*` 是写 Stream 的语法糖：
- 用 `yield value;` 发事件
- 用 `yield* otherStream;` 把另一个 Stream 的事件"转发"过来
- `return;` 或函数自然结束 → Stream done

对比：
| 关键字 | 返回值 | 发事件 |
|-------|-------|-------|
| `async` | `Future<T>` | 一次 `return` |
| `async*` | `Stream<T>` | 多次 `yield` |
| `sync*` | `Iterable<T>` | 多次 `yield`（同步） |

## 转换：map / where / expand / asyncMap

```dart
stream
  .where((e) => e.isValid)                      // 过滤
  .map((e) => e.value)                          // 同步映射
  .asyncMap((v) => fetchDetail(v))              // 异步映射（串行等待）
  .distinct()                                   // 连续相同值去重
  .take(10)                                     // 只取前 10 个
  .listen(print);
```

**`map` vs `asyncMap` 的核心差别**：
- `map(fn)`：`fn` 返回 `R` → 直接转为新事件
- `asyncMap(fn)`：`fn` 返回 `Future<R>` → **等 Future 完成** 再发下一个事件（串行）

```dart
stream.asyncMap((v) => heavyNetworkCall(v));
// 一次处理一个，保证顺序、不打爆
```

想并发处理每个事件用 `asyncExpand` + `Future.wait` 或 `package:rxdart`。

## 节流 / 防抖：实战

Dart 原生没有 `debounce` / `throttle`，常用 `package:rxdart`。也可以手写：

```dart
Stream<T> debounce<T>(Stream<T> source, Duration d) {
  final ctrl = StreamController<T>();
  Timer? timer;
  T? last;
  source.listen(
    (v) {
      last = v;
      timer?.cancel();
      timer = Timer(d, () => ctrl.add(last as T));
    },
    onDone: () {
      timer?.cancel();
      ctrl.close();
    },
  );
  return ctrl.stream;
}
```

## 背压：慢消费者遇到快生产者

**场景**：生产者每毫秒发 1 个事件，消费者每秒处理 1 个。

- 单订阅 Stream：**事件在订阅里排队**，内存持续涨
- 广播 Stream：**事件直接丢给当前所有监听者**，没有缓冲

处理策略（单订阅）：

```dart
// 1) 暂停订阅，让生产者等（但 Stream 默认不 "通知" 生产者）
sub.pause();

// 2) 在链路里 "抽样" 降低频率
stream.throttleTime(const Duration(seconds: 1)); // rxdart

// 3) 用 asyncMap 串行消费（自然限速）
stream.asyncMap((v) => slowHandle(v));
```

**关键原理**：Dart 的 Stream 是"推"模型（push），生产者决定节奏。消费者唯一的反压手段是 `pause` + 依赖生产者尊重 pause（`StreamController` 会尊重，网络 socket 也会）。

## 监听多个事件源：StreamGroup / merge

```dart
import 'package:async/async.dart';

final merged = StreamGroup.merge([streamA, streamB]);
merged.listen(print);
```

## 小结

- `StreamController` 是自己手动往外推事件的工具；**记得 close**
- `async*` + `yield` 是更优雅的 Stream 写法
- `map / where / asyncMap / distinct / take` 是最常用的转换
- **`asyncMap` 串行、不并发**
- 背压处理靠 `pause` / `throttle` / `asyncMap`

## 练习题

1. 用 `StreamController` 实现一个"计数器"，每次用户点按钮就往 stream 里加 1。
2. 用 `async*` 写一个 fibonacci 数列生成器，发前 20 项。
3. 在输入框的 `onChanged` 里构造一个 Stream，用你手写的 `debounce(300ms)` 过滤。

下一章进入 **Flutter 的 builder** → [第 7 章](07_flutter_builders.md)。
