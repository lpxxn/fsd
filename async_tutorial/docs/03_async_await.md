# 第 3 章 async / await

## 问题引入：回调地狱

用 `.then` 写一个 "先登录、再拉用户信息、再拉订单" 的流程：

```dart
login().then((token) {
  return fetchUser(token).then((user) {
    return fetchOrders(user.id).then((orders) {
      print('$user 有 ${orders.length} 张订单');
    });
  });
}).catchError((e) => print('出错 $e'));
```

缩进一层深似一层，这就是传说中的"回调地狱（callback hell）"。

## 换成 async / await

```dart
Future<void> loadEverything() async {
  try {
    final token = await login();
    final user = await fetchUser(token);
    final orders = await fetchOrders(user.id);
    print('$user 有 ${orders.length} 张订单');
  } catch (e) {
    print('出错 $e');
  }
}
```

代码读起来像同步，但实际每一行 `await` 都是异步的。**这只是语法糖**，编译器会把它还原成 `.then` 链。

## 规则速查

1. **`async` 修饰的函数，返回值一定是 `Future<T>`**
   即使你在函数里写 `return 1;`，调用方拿到的也是 `Future<int>`。

   ```dart
   Future<int> getOne() async => 1; // 返回 Future<int>
   ```

2. **`await` 只能在 `async` 函数里用**
   （顶层 `main` 可以写成 `Future<void> main() async { ... }`）

3. **`await` 只对 Future（或 `FutureOr`）生效**
   对一个普通的 int 用 `await`，它会直接返回这个 int。

4. **`await` 会"暂停"当前函数，但不会阻塞线程**
   暂停期间，事件循环去跑别的 task；当 Future 完成后，本函数从 `await` 这一行恢复。

## try / catch / finally 与异常

```dart
Future<void> demo() async {
  try {
    await Future.delayed(const Duration(milliseconds: 100),
        () => throw Exception('bad'));
  } on Exception catch (e) {
    print('接住 $e');
  } finally {
    print('收尾');
  }
}
```

对比 `.catchError`：
- `try/catch` 更像同步代码的错误处理，可读性高
- `.catchError` 在链式 API 中更灵活，比如只想接住中间某一步的错误

## `await` 的"伪暂停"究竟是什么

来看这段代码：

```dart
Future<void> fn() async {
  print('A');
  await Future.delayed(const Duration(seconds: 1));
  print('B');
}

void main() {
  fn();
  print('C');
}
```

输出：

```text
A
C
B
```

解读：
- 进入 `fn`，同步执行到 `await`
- `await` 把 **"1 秒后继续执行 B"** 这个动作登记到事件循环
- `fn` 立刻返回一个 Future（尚未完成）
- 控制权回到 `main`，接着打印 `C`
- 1 秒后，事件循环把 B 的执行恢复

**关键洞察**：`await` 不是 "停在这里"，而是 "把后面的代码包成回调，挂到 Future 上，然后立即返回"。

## 返回值的两种规则（容易搞混）

```dart
Future<int> a() async => 1;           // 值类型 → 包一层成 Future<int>
Future<int> b() async => Future.value(1); // Future → 自动摊平，还是 Future<int>
Future<Future<int>> c() async => Future.value(1); // 主动加一层，几乎从不这么写
```

**99% 的情况**你只要记住：`async` 函数返回 **"Future 里装着你 return 的那个值"**，即使 return 的本身是 Future 也会被摊平。

## 不要忘了 await！

这是 Dart 新手头号 bug：

```dart
Future<void> save() async {
  await writeToDisk();
}

Future<void> main() async {
  save();          // ← 没 await！main 不会等它写完
  await Future.delayed(const Duration(milliseconds: 1));
  print('结束');
}
```

`save()` 的 Future 被丢弃了，`main` 可能在 `save` 还没写完就结束，磁盘写入被"悬挂"着。**静态分析工具会警告 `discarded_futures`**，认真对待它。

## 小结

- `async/await` 只是 `.then` 链的语法糖，零运行时开销
- `async` 函数必定返回 `Future`；`await` 只能在 `async` 里
- `await` 暂停的是**函数**，不是**线程**
- `try/catch` 能接住 `await` 表达式抛出的异常
- 绝不"裸调用" async 函数（忘了 await）

## 练习题

1. 把第 2 章练习里的 `.then` 版本改写成 `async/await` 版本。
2. 写一个 async 函数 `Future<String> withTimeout(Future<String> f, Duration d)`，超过 d 时间就抛 `TimeoutException`。（提示：`f.timeout(d)`）
3. 故意忘了 await，观察 `flutter analyze` 的警告。

下一章讲 **怎么并行跑多个 Future** → [第 4 章](04_parallel_future.md)。
