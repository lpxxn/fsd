# 第 5 章 Stream 基础

## Future vs Stream

| | 返回一个值 | 返回多个值 |
|--|-----------|-----------|
| 同步 | 普通函数 `int f()` | `Iterable<int>` |
| 异步 | `Future<int>` | `Stream<int>` |

**`Stream<T>` = 会陆续发出 0 ~ N 个 T 的异步序列**，比如：
- 每秒一次的心跳
- WebSocket 收到的消息
- 输入框的文本变化
- 文件按行读取

## 两种 Stream：单订阅 vs 广播

### 单订阅（single-subscription）

- **只能被 listen 一次**
- 第二次 listen 会抛异常
- 适合"一次性数据流"，比如读一个 HTTP 响应体

```dart
final s = Stream.fromIterable([1, 2, 3]);
s.listen(print);
s.listen(print); // Bad state: Stream has already been listened to.
```

### 广播（broadcast）

- **可以被多个订阅者同时监听**
- 类似事件总线

```dart
final controller = StreamController<int>.broadcast();
controller.stream.listen((v) => print('A: $v'));
controller.stream.listen((v) => print('B: $v'));
controller.add(1); // A 和 B 都会收到
```

**怎么把单订阅变广播**：

```dart
final broadcast = singleStream.asBroadcastStream();
```

## 创建 Stream 的几种方式

```dart
// 1. 从集合
Stream.fromIterable([1, 2, 3]);

// 2. 周期性发事件
Stream<int>.periodic(const Duration(seconds: 1), (i) => i);

// 3. 一次性 Future 变 Stream
Stream.fromFuture(Future.value(42));

// 4. 自己用 async* 生成（下一章讲细节）
Stream<int> countDown(int from) async* {
  for (var i = from; i >= 0; i--) {
    await Future.delayed(const Duration(seconds: 1));
    yield i;
  }
}

// 5. StreamController（手动往里塞事件，下一章详述）
```

## 消费 Stream 的两种写法

### `listen`（回调风格）

```dart
final sub = stream.listen(
  (data) => print('data=$data'),
  onError: (e, st) => print('err=$e'),
  onDone: () => print('done'),
  cancelOnError: false,
);

// 记得在不用时取消，否则 Stream 会一直发
await sub.cancel();
```

### `await for`（顺序风格，像循环）

```dart
await for (final data in stream) {
  print('data=$data');
  if (data == 3) break; // break 会自动取消订阅
}
print('循环结束');
```

两种写法等价。**`await for` 只能用在 async 函数里**，并且**只能消费单订阅 Stream**（广播 Stream 也行，但每次 await for 都会建立一次新的订阅）。

## StreamSubscription 的操作

```dart
final sub = s.listen(handler);
sub.pause();                        // 暂停（事件会被缓存）
sub.resume();                       // 恢复
await sub.cancel();                 // 取消（关键！别忘）
sub.onData(newHandler);             // 换处理器
```

**关键纪律**：**任何 listen 回来的 StreamSubscription，都要在离开作用域前 cancel**。在 Flutter 里常见做法：

```dart
class _MyState extends State<MyWidget> {
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _sub = someStream.listen((e) => ...);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
```

## 代码演示：listen vs await for

```dart
Stream<int> nums() async* {
  for (var i = 1; i <= 3; i++) {
    await Future.delayed(const Duration(milliseconds: 300));
    yield i;
  }
}

Future<void> demo() async {
  print('--- listen ---');
  nums().listen(
    (v) => print('listen 收到 $v'),
    onDone: () => print('listen done'),
  );
  // listen 不阻塞，main 继续

  await Future.delayed(const Duration(seconds: 2));

  print('--- await for ---');
  await for (final v in nums()) {
    print('await for 收到 $v');
  }
  print('await for 循环结束');
}
```

## Stream 的错误与完成

一个 Stream 可以：
- 发 0~N 次 `data` 事件
- 发 **任意次** `error` 事件（`error` 不会自动终止 Stream，除非 `cancelOnError: true`）
- 最终发 **1 次** `done` 事件（或永不 done，比如广播）

**`error` ≠ `done`**！这是很多新手的误区——错误事件之后，Stream 还能继续发数据。

## 小结

- Stream 是"多值 Future"
- 单订阅 vs 广播：**一个 Stream 对应一个订阅 vs 多个订阅**
- 消费用 `listen` 或 `await for`
- **永远记得 cancel 订阅**，在 Flutter 里通常在 `dispose` 里做

## 练习题

1. 写一个每秒发一次当前时间的 Stream，用 `listen` 打印前 5 次。
2. 把它转成广播 Stream，让两个 listener 都能收到。
3. 在 `await for` 里加一个 break，观察是不是真的停止收了。

下一章讲 **怎么自己造 Stream、怎么转换** → [第 6 章](06_stream_advanced.md)。
