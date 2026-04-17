# 第 2 章 Future 基础

## 什么是 Future

> `Future<T>` = **未来某个时刻会给你一个 T，或者给你一个错误**。

它是一张"兑奖券"：
- 现在手里只有券（`Future<int>`），没有数字
- 票到期（完成）时，要么拿到 **值** （`int`），要么拿到 **异常**
- 你可以把券转给别人（当参数、返回值）

关键点：**一个 Future 只完成一次**（要么成功一次，要么失败一次，永远不会再变）。

## 三种创建方式

```dart
// 1. 立即就有值的 Future（一般用于测试、占位）
final f1 = Future<int>.value(42);

// 2. 延迟后完成（等时间到了才有值）
final f2 = Future<String>.delayed(
  const Duration(seconds: 1),
  () => 'hello',
);

// 3. 用默认构造：把一段代码扔到事件队列里异步跑
final f3 = Future<int>(() {
  // 这里的代码不是立刻跑的，而是被排进事件队列，下一轮才跑
  return 1 + 2;
});

// 4. 失败的 Future
final f4 = Future<int>.error(Exception('boom'));
```

## 拿结果的两种写法

### .then / .catchError / .whenComplete（回调风格）

```dart
Future<int> fetchNumber() => Future.delayed(
      const Duration(seconds: 1),
      () => 42,
    );

void main() {
  fetchNumber()
      .then((value) => print('拿到 $value'))          // 成功分支
      .catchError((e, st) => print('出错 $e'))        // 失败分支
      .whenComplete(() => print('不管成功失败都执行')); // 类似 finally
  print('main 还在继续跑，没被挡住');
}
```

输出：

```text
main 还在继续跑，没被挡住
拿到 42
不管成功失败都执行
```

注意：**`main` 里的同步代码先打印，然后事件循环才去处理 Future 回调**。这是第 8 章要讲的核心。

### async / await（顺序风格，下一章讲）

先剧透一下：上面的代码可以写成：

```dart
Future<void> main() async {
  try {
    final value = await fetchNumber();
    print('拿到 $value');
  } catch (e) {
    print('出错 $e');
  } finally {
    print('不管成功失败都执行');
  }
}
```

是不是像同步代码一样好读？但**两种写法等价**，编译器最终还是转成回调。

## 链式调用：返回值会"解包"

```dart
Future<int> step1() => Future.value(1);
Future<int> step2(int v) => Future.value(v + 10);

void main() {
  step1()
      .then((v) => step2(v))   // .then 的回调返回 Future<int>
      .then((v) => print(v));  // 这里的 v 是 int，不是 Future<int>
}
// 输出: 11
```

重要规则：`.then` 的回调如果返回一个 **Future**，会自动被"摊平"，下一个 `.then` 拿到的是里面的值，不是套娃。

## 错误如何传播

```dart
Future.value(1)
    .then((_) => throw Exception('x'))
    .then((_) => print('不会执行到这里'))
    .catchError((e) => print('在这里接住: $e'));
```

**一旦某一步抛错，后面的 `.then` 都会被跳过**，直到遇到 `.catchError`。这和同步的 try/catch 思路一致。

## 一个容易踩的坑

```dart
Future<void> main() async {
  Future.delayed(const Duration(seconds: 1), () => print('到期'));
  print('main 结束');
}
```

上面的 Future **没被 await**。会打印什么？

```text
main 结束
到期       ← 1 秒后
```

但是！如果你在 Flutter 里的 `build` 方法里这么写：

```dart
@override
Widget build(BuildContext context) {
  Future.delayed(const Duration(seconds: 1), () => print('到期')); // 每次 build 都会新建一个 Future
  return ...;
}
```

每次重建就多一个定时器，可能会反复触发。**永远不要在 build 里"裸"创建 Future**（第 7、11 章会展开讲）。

## 小结

- Future 是**一次性**的异步值占位符
- 可以用 `.then/.catchError/.whenComplete` 或 `async/await` 取出结果
- `.then` 返回的 Future 会被自动摊平
- 异常沿着链传播，直到被 `.catchError` / `try-catch` 接住
- **不要**在 `build` 里裸创建 Future

## 练习题

1. 写一个 `Future<int> randomAfter(int ms)` 函数，ms 毫秒后返回一个随机整数；然后用 `.then` 打印两次调用的结果。
2. 把练习 1 改成用 `async/await` 写。
3. 故意让它失败（比如随机数是偶数就 throw），用 `.catchError` 接住。

做完练习去[第 3 章](03_async_await.md)。
