# 第 11 章 常见陷阱与最佳实践

> 新人踩的坑 90% 都在这里。把这一章当速查表用。

## 1. 忘了 await

```dart
Future<void> save() async {
  saveToDisk();       // ❌ 没 await, Future 被丢弃
  print('保存完成');  // 谎言：可能磁盘还没写
}
```

**修复**：

```dart
Future<void> save() async {
  await saveToDisk(); // ✅
  print('保存完成');
}
```

**预防**：在 `analysis_options.yaml` 里开 `discarded_futures`、`unawaited_futures`：

```yaml
linter:
  rules:
    - discarded_futures
    - unawaited_futures
```

"我就是要 fire-and-forget" 的时候显式写：

```dart
import 'dart:async';
unawaited(saveToDisk());
```

## 2. for 循环里 await 导致串行

```dart
for (final url in urls) {
  await fetch(url); // 每次都等，N 个就是 N 倍时间
}
```

改并行：

```dart
await Future.wait(urls.map(fetch));
```

想限制并发数就用 `package:pool` 或自己写 worker 池（见第 4 章）。

## 3. 跨 await 之后 context / mounted 失效

```dart
Future<void> submit() async {
  await api.save();
  // ❌ 页面可能已被 pop
  Navigator.of(context).pop();
  // ❌ widget 可能已 dispose
  setState(() => _loading = false);
}
```

修复：

```dart
Future<void> submit() async {
  await api.save();
  if (!mounted) return;        // 或 context.mounted
  Navigator.of(context).pop();
  setState(() => _loading = false);
}
```

## 4. StreamSubscription 忘了取消

```dart
class _MyState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    stream.listen(_handle); // ❌ 页面销毁后仍在收事件、仍然 setState
  }
}
```

修复：保存并在 `dispose` 里 cancel。

```dart
late final StreamSubscription _sub;

@override
void initState() {
  super.initState();
  _sub = stream.listen(_handle);
}

@override
void dispose() {
  _sub.cancel();
  super.dispose();
}
```

## 5. 在 build 里新建 Future / Stream

```dart
@override
Widget build(BuildContext context) {
  return FutureBuilder(
    future: fetch(),             // ❌ 每次 build 都会请求
    builder: ...,
  );
}
```

修复：把 Future 放到 `State` 里只 build 一次（见第 7 章）。

## 6. 期望 `Future.value.then` 同步执行

```dart
int x = 0;
Future.value(1).then((_) => x = 99);
print(x); // 0, 不是 99
```

Dart 规范保证 `.then` 回调**至少异步一次**。要同步赋值就别用 Future。

## 7. 把 async 函数返回值当普通值

```dart
int compute() async { return 1; } // ❌ 编译报错
```

```dart
Future<int> compute() async => 1;       // ✅
int v = await compute();                // ✅ 在 async 里用
```

## 8. Stream 的错误没 catch 就冒到根 Zone

```dart
myStream.map((e) => riskyParse(e)).listen(print);
// riskyParse 抛错, listener 没有 onError
```

修复：

```dart
myStream
  .map(riskyParse)
  .listen(
    print,
    onError: (e, st) => logger.error(e, st),
  );
```

或者整体包在 `runZonedGuarded` 里兜底。

## 9. 把 CPU 密集误当成 IO 密集

```dart
Future<List<Item>> parse(String hugeJson) async {
  // 同步 decode 50MB, 以为 async 就不卡, 其实卡成 PPT
  return jsonDecode(hugeJson);
}
```

修复：放到 Isolate 里。

```dart
final items = await compute(jsonDecode, hugeJson);
```

## 10. setState 被 await 包住

```dart
Future<void> load() async {
  final d = await api.load();
  setState(() => _data = d); // ✅ 这是对的, 但前面如果有很多层 await...
}
```

小心**多次 setState 的时机**：每个 `setState` 都触发一次重建，连续 N 个 `setState` 会触发 N 次。合并它们：

```dart
Future<void> load() async {
  final d = await api.load();
  final e = await api.related(d);
  setState(() {
    _data = d;
    _extra = e;
  });
}
```

## 11. Future.wait 让人"全或无"

```dart
final all = await Future.wait([a(), b(), c()]);
// 如果 b 抛错, 你根本拿不到 a 和 c 的结果
```

如果你需要"谁成功就用谁"，改成逐个加 `.catchError((_) => null)`：

```dart
Future<T?> safe<T>(Future<T> f) => f.then<T?>((v) => v).catchError((_) => null);
final results = await Future.wait([a(), b(), c()].map(safe));
```

## 12. "异步构造器"不存在

```dart
class Foo {
  Foo() async { ... } // ❌ 构造器不能 async
}
```

替代：工厂函数。

```dart
class Foo {
  Foo._();
  static Future<Foo> create() async {
    final f = Foo._();
    await f._init();
    return f;
  }
  Future<void> _init() async { ... }
}

final foo = await Foo.create();
```

## 一张自查清单

写完每个异步函数，快速过一遍：

- [ ] 所有 `Future` 都 `await` 或显式 `unawaited()` 了吗？
- [ ] 循环里 `await` 是不是故意要串行？
- [ ] 跨 `await` 之后有 `mounted` 检查吗？
- [ ] 所有 `StreamSubscription` 都在 dispose 里 cancel 了吗？
- [ ] 有没有在 `build` 里创建一次性对象？
- [ ] CPU 密集任务有没有用 Isolate？
- [ ] 有没有全局的 `runZonedGuarded` 兜底？

## 结语

到这里你已经完整过了一遍 Dart/Flutter 异步的主干。剩下的就是**多写代码、多调 bug**。

建议：
- 每章的练习题都做一遍
- 给自己挑一个小 App（比如从网络加载图片列表），把这本教程里学到的东西都用上
- 读一读 [Dart 官方并发文档](https://dart.dev/guides/language/concurrency)

祝学习顺利。
