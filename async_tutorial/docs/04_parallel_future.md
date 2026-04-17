# 第 4 章 并行组合：Future.wait / Future.any

## 问题引入

假设你要拉 3 个接口，每个 1 秒。两种写法：

### 串行（错）：3 秒

```dart
final a = await fetchA(); // 1s
final b = await fetchB(); // 再 1s
final c = await fetchC(); // 再 1s
```

每个 `await` 都在等上一个，**总耗时 ≈ 3 秒**。

### 并行（对）：1 秒

```dart
final results = await Future.wait([fetchA(), fetchB(), fetchC()]);
final a = results[0], b = results[1], c = results[2];
```

3 个请求**同时发出**，总耗时 ≈ 最慢的那一个 ≈ 1 秒。

关键点：**三个 Future 在进入 `Future.wait` 之前就已经开始执行了**——`fetchA()` 一被调用就进入事件循环了，`await` 只影响"拿结果"的时间点，不影响"开始"的时间点。

## Future.wait 详解

```dart
// 全部成功
final list = await Future.wait([futureA, futureB, futureC]);

// 任何一个失败就整体失败（默认行为）
try {
  await Future.wait([goodFuture, badFuture]);
} catch (e) {
  // badFuture 的错误会在这里抛出
}

// 不让一个错误中断其它（eagerError: false 是默认，但想 "哪怕出错也等全部完成" 用它）
final list = await Future.wait(
  [goodFuture, badFuture],
  eagerError: false, // 等所有 future 完成再决定是否抛错
);
```

对照：
- `eagerError: true` → 第一个错误一出现就立刻 reject
- `eagerError: false`（默认）→ 等所有 future 都完成，再抛第一个错误

## Future.any：谁先谁赢

```dart
// 最快的那个 future 完成就返回，其它的被忽略（但并不会被取消）
final fastest = await Future.any([
  fetchFromCdn1(),
  fetchFromCdn2(),
  fetchFromCdn3(),
]);
```

典型用法：**同时请求多个 CDN，谁先回谁算**。注意：**Dart 没有"取消 Future"的原生机制**——慢的那几个仍然在跑，只是你不要了。需要真正取消时用第 5 章的 `StreamSubscription.cancel` 或自己设计。

## 在循环里 await 是串行的

```dart
for (final url in urls) {
  final data = await fetch(url); // 串行！
  process(data);
}
```

这和 `for` 里写多次 `await` 等价：等一个结束再发下一个。**这不是 bug，有时候就是你想要的行为**（按顺序、避免服务器被打爆）。

想要并行：

```dart
final results = await Future.wait(urls.map(fetch));
```

## Future.forEach：串行但更可控

```dart
await Future.forEach(urls, (url) async {
  final data = await fetch(url);
  process(data);
});
```

语义上和 `for+await` 差不多，都是串行，但把每次迭代包装成一个 Future，便于传递到更高阶的组合里。

## 实战：批量请求限并发

业务上常常需要"最多并行 N 个"，避免把服务器打爆。可以自己写一个小工具：

```dart
Future<List<R>> parallel<T, R>(
  Iterable<T> items,
  Future<R> Function(T) task, {
  int concurrency = 4,
}) async {
  final results = <R>[];
  final iter = items.iterator;
  final workers = List.generate(concurrency, (_) async {
    while (iter.moveNext()) {
      final item = iter.current;
      results.add(await task(item));
    }
  });
  await Future.wait(workers);
  return results;
}
```

（生产环境建议直接用 `package:pool` 或 `package:async`）

## 常用组合 API 速查

| API | 行为 |
|-----|------|
| `Future.wait(list)` | 全部完成后一起拿结果；任一失败→整体失败 |
| `Future.any(list)` | 第一个完成（成功或失败）立刻返回 |
| `Future.forEach(list, fn)` | 串行对每个元素执行 async fn |
| `Future.doWhile(fn)` | 循环执行 fn，返回 `false` 时停 |

## 小结

- `await a(); await b();` **串行**
- `Future.wait([a(), b()])` **并行**
- `Future.any([...])` **取最快**
- Dart 的 Future **没有原生取消**

## 练习题

1. 写个函数同时请求 3 个接口（用 `Future.delayed` 模拟），统计总耗时，验证和最慢那个几乎相等。
2. 模拟其中一个接口随机失败，用 `eagerError: true` 和 `false` 分别观察差别。
3. 写一个版本，要求"至少有 2 个成功就继续，哪怕第 3 个失败"。（提示：自己对着每个 Future `.catchError((_) => null)`，然后再统计）

下一章走向 **多值异步**：[第 5 章 Stream 基础](05_stream_basics.md)。
