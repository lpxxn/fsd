# 第 1 章 第一个 Provider

## 目标

跑起来最小的 Riverpod 示例：**定义一个 Provider，在 Widget 里读它**。

## 三个步骤

### 1. 根部套上 `ProviderScope`

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}
```

`ProviderScope` 是 Riverpod 的"根容器"。它内部持有一个 `ProviderContainer`，所有 Provider 的实例都住在这个容器里。**只要不套就报错**。

### 2. 定义 Provider（顶层变量）

```dart
final greetingProvider = Provider<String>((ref) {
  return 'Hello, Riverpod!';
});
```

拆解：
- `Provider<String>`：声明这个 Provider 产出一个 `String`
- `((ref) => ...)`：一个"工厂函数"，第一次被读的时候会跑一次，结果会被缓存
- `ref`：用来读**别的** Provider（后面会讲）
- **顶层 `final`**：Provider 本身是无状态的定义，真正的数据住在容器里

### 3. 在 Widget 里读

换用 `ConsumerWidget` 替代 `StatelessWidget`：

```dart
class GreetingPage extends ConsumerWidget {
  const GreetingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(greetingProvider);
    return Scaffold(body: Center(child: Text(text)));
  }
}
```

变化：
- 继承 `ConsumerWidget`，`build` 多一个 `WidgetRef ref` 参数
- `ref.watch(greetingProvider)` = "读值 + 订阅它的后续变化"

## 完整可运行代码

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final greetingProvider = Provider<String>((ref) => 'Hello, Riverpod!');

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(home: GreetingPage());
}

class GreetingPage extends ConsumerWidget {
  const GreetingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(greetingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('First Provider')),
      body: Center(child: Text(text, style: const TextStyle(fontSize: 24))),
    );
  }
}
```

## 三种 Consumer，同一件事

```dart
// 1) ConsumerWidget：推荐，最常用
class A extends ConsumerWidget { ... }

// 2) ConsumerStatefulWidget：需要 StatefulWidget 能力（有 initState/dispose）时用
class B extends ConsumerStatefulWidget { ... }
class _BState extends ConsumerState<B> {
  @override
  Widget build(BuildContext context) {
    final v = ref.watch(greetingProvider); // ConsumerState 里可以直接用 ref
    return ...;
  }
}

// 3) Consumer：局部套一层，常用于只想让"某个子树"依赖某 Provider，减少重建范围
Widget build(BuildContext context) {
  return Column(children: [
    const Text('头部不随 Provider 变化'),
    Consumer(
      builder: (context, ref, child) => Text(ref.watch(greetingProvider)),
    ),
  ]);
}
```

**选择规则**：
- 整页都依赖 Provider → `ConsumerWidget`
- 需要生命周期钩子 → `ConsumerStatefulWidget`
- 大部分子树不需要重建，只有一小块要响应 → `Consumer`

## 为什么 Provider 要写成顶层变量

新手常问：顶层变量不是"全局变量"吗？全局变量不是反模式吗？

Riverpod 的回答：**Provider 只是"标识符（identifier）"**，它本身不持有状态。真正的状态在 `ProviderContainer`（也就是 `ProviderScope`）里。

类比：
- Provider 就像一把"钥匙"
- `ProviderContainer` 就像"储物柜"
- 同一把钥匙 + 不同储物柜 → 拿到不同的东西（这是测试时 override 的本质）

所以"顶层变量 Provider"在 Riverpod 里是**零副作用的**，放心用。

## 常见坑

- **忘了加 `ProviderScope`**：`ProviderScope is not found` → 立刻加到 `runApp` 外层
- **在 `StatelessWidget` 里直接读 `ref`**：没有 `ref`，要继承 `ConsumerWidget`
- **在 `initState` 里 `ref.watch`**：不允许，要用 `ref.read`（第 2 章讲）

## 练习

1. 打开本章 Demo 页，在代码里把 `greetingProvider` 改成 `Provider<int>((ref) => 42)`，观察编译报错——这就是类型安全。
2. 把 `Text(ref.watch(greetingProvider))` 改成 `Text(greetingProvider.toString())`，观察屏幕打印什么（会是一个 Provider 对象的 `toString()`，说明 Provider 不是值，它是个"标识"）。

下一章讲 `ref` 的三种基本用法 → [第 2 章](02_ref_watch_read_listen.md)。
