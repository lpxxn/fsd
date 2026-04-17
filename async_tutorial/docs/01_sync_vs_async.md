# 第 1 章 同步 vs 异步

## 问题引入

想象你写了一个 Flutter 按钮，点一下要"请求服务器 3 秒"才能拿到结果。

如果用**同步**的写法：

```dart
ElevatedButton(
  onPressed: () {
    sleep(const Duration(seconds: 3)); // 同步地睡 3 秒
    setState(() => result = '完成');
  },
  child: const Text('开始'),
);
```

这 3 秒内，整个 App **动画停了、滚动卡了、连返回键都没反应**。用户会以为死机。

换成**异步**写法：

```dart
ElevatedButton(
  onPressed: () async {
    await Future.delayed(const Duration(seconds: 3));
    setState(() => result = '完成');
  },
  child: const Text('开始'),
);
```

这 3 秒内，动画照跑、滚动照滚、返回键能按。3 秒后结果自动出来。

**这就是为什么要学异步。**

## 最小代码（可运行）

`lib/pure_dart/chapter_01.dart`：

```dart
import 'dart:io';

void blockingDemo() {
  print('[blocking] 开始');
  sleep(const Duration(seconds: 2)); // 真·卡住当前线程
  print('[blocking] 结束');
}

Future<void> nonBlockingDemo() async {
  print('[async] 开始');
  await Future.delayed(const Duration(seconds: 2)); // 让出控制权
  print('[async] 结束');
}

Future<void> main() async {
  blockingDemo();
  print('--- 分割线 ---');
  await nonBlockingDemo();
  print('main 结束');
}
```

运行 `dart run lib/pure_dart/chapter_01.dart`，注意：

- `blockingDemo` 期间，整个进程什么都做不了
- `nonBlockingDemo` 期间，事件循环会去处理别的事（你可以在那 2 秒里往队列里塞别的任务）

## 逐行拆解

- `sleep(...)`：来自 `dart:io` 的**同步**函数，真的把当前线程 hold 住
- `Future.delayed(...)`：**异步**工具，注册一个 2 秒后的定时事件，然后**立刻返回**一个 Future
- `await`：把当前函数暂停在这一行，把控制权交回事件循环；2 秒后事件触发，函数从这一行恢复执行

## 原理先看一眼

```text
主线程时间轴（同步 sleep）：
[ 代码 ]==sleep 2s==[ 代码 ]       ← 这 2s UI 线程被霸占

主线程时间轴（异步 delayed）：
[ 代码 ]---> 注册定时器 ---> [ 渲染 + 手势 + 别的 task ] ---2s到---> [ 恢复执行 ]
```

Dart 单线程里，异步函数**不会让代码更快**，但它会**让线程在等待 IO/定时器时不空转**，这段空闲时间可以渲染下一帧、响应点击、跑别的 Future。

## Flutter Demo 怎么玩

打开第 1 章 Demo 页：

- 页面上有两个按钮："同步 2s"、"异步 2s"
- 同时页面上有一个持续旋转的进度圈
- 点"同步"按钮 → 进度圈**卡住 2 秒**
- 点"异步"按钮 → 进度圈**正常转**，2 秒后弹出结果

这一下就直观感受到了"异步"在 UI 里的价值。

## 常见误解

- **误解 1**："加 async 代码就会变快" → 不会。异步改善的是 **吞吐/响应性**，不是计算速度。
- **误解 2**："async 函数就开了新线程" → 没有。Dart 默认在单个 Isolate 里跑，连"线程切换"都没有。
- **误解 3**："所有耗时操作都适合 async" → 不对。**CPU 密集**的计算 async 也救不了你，要用 Isolate（第 10 章）。

## 练习题

1. 把示例里的 `sleep` 换成一个 "死循环数到 1 亿"，再跑一次 Flutter Demo，看进度圈还会不会卡？你能解释为什么吗？（提示：事件循环只有一条）
2. 把 `await Future.delayed(...)` 前面的 `await` 去掉，会发生什么？函数会等 2 秒吗？

做完练习再继续到[第 2 章](02_future_basics.md)。
